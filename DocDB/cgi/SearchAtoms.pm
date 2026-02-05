#
#        Name: $RCSfile$
# Description: Bits of code to do various searches. Some specific, some generic
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

use HTML::Entities qw(encode_entities_numeric);

%SearchWeights = ( # These weights are used to order documents from the simple search
                  "Document"        => 100,
                  "Author"          => 4,
                  "Topic"           => 3,
                  "DocType"         => 2,
                  "Event"           => 3,
                  "EventGroup"      => 2,
                  "File"            => 3,
                  "FileContent"     => 1,
                  "Revision"        => 3,
#                  "Title"           => 4,
#                  "Abstract"        => 3,
#                  "Keyword"         => 3,
#                  "RevisionNote"    => 2,
#                  "PubInfo"         => 3,
#                  "Age"             => 1, #  * (1-Age/MaxAge)
              );

sub TextSearch {
  my ($Field,$Mode,$Words) = @_;

  my $Phrase = "";
  my $Join;
  my $Delimit;
  my @Atoms = ();

  if ($Mode eq "anysub" || $Mode eq "allsub" || $Mode eq "anyword" || $Mode eq "allword") {
    my @Words = split /\s+/,$Words;
    foreach my $Word (@Words) {
      if ($Mode eq "anysub" || $Mode eq "allsub") {
        my $RegExp = RegExpSearchAtom($Word);
        push @Atoms, "$Field rlike $RegExp";
      } elsif ($Mode eq "anyword" || $Mode eq "allword") {
        my $RegExp = RegExpSearchAtom($Word, $TRUE);
        push @Atoms, "$Field rlike $RegExp";
      }
    }
  }

  if      ($Mode eq "anysub" || $Mode eq "anyword") {
    $Join = " OR ";
  } elsif ($Mode eq "allsub" || $Mode eq "allword") {
    $Join = " AND ";
  }

  $Phrase = join $Join,@Atoms;

  if ($Phrase) {$Phrase = "($Phrase)";}

  return $Phrase;
}

sub RegExpSearchAtom {
  my ($Word, $RequireWord) = @_;

  my @RegExpParts = ();
  my $RegExpAtom  = '';

  my $SimpleWord = $Word;
  $SimpleWord =~ s/\W//g;
  if ($SimpleWord eq $Word) { # No special characters found
    push @RegExpParts, $Word;
  } else {
    my $Escaped = $Word;                                         # First take care of regexp special characters
    $Escaped =~ s/([\[\\\^\$\.\|\?\*\+\(\)])/\\\1/g;             # Prepend \ to regexp safe characters [\^$.|?*+()
    push @RegExpParts, $Escaped;

    $Escaped = HTML::Entities::encode($Word);                    # &amp;
    if ($Escaped ne $Word) {
      push @RegExpParts, $Escaped;
    }

    $Escaped = HTML::Entities::encode_entities_numeric($Word);   # &#xab;
    if ($Escaped ne $Word) {
      push @RegExpParts, $Escaped;
    }

    $Escaped = $Word;
    $Escaped =~ s{(\W)}{"%".sprintf("%x", unpack(U,$1))}ge;      # %20
    push @RegExpParts, $Escaped;

    $Escaped = $Word;
    $Escaped =~ s{(\W)}{"&#".unpack(U,$1).";"}ge;                # &#1234;
    push @RegExpParts, $Escaped;
  }

  if ($RequireWord) {
    if ($MySQLVersion < 8) {
      $RegExpAtom .= '[[:<:]]';
    } else {
      $RegExpAtom .= '\\b';
    }
  }
  $RegExpAtom .= '(';
  $RegExpAtom .= join '|', @RegExpParts;
  $RegExpAtom .= ')';
  if ($RequireWord) {
    if ($MySQLVersion < 8) {
      $RegExpAtom .= '[[:>:]]';
    } else {
      $RegExpAtom .= '\\b';
    }
  }

  my $SafeAtom = $dbh->quote($RegExpAtom);
  return $SafeAtom;
}

sub IDSearch {
  my ($Table,$Field,$Mode,@IDs) = @_;

  my $Phrase = "";
  my $Join;
  my $Delimit;
  my @Atoms = ();

  $Join = $Mode;

  foreach $ID (@IDs) {
    push @Atoms," $Field=$ID ";
  }

  $Phrase = join $Join,@Atoms;

  if ($Phrase) {$Phrase = "($Phrase)";}

  return $Phrase;
}

sub TopicSearch ($) {
  my ($ArgRef) = @_;

  my $Logic      = exists $ArgRef->{-logic}     ?   $ArgRef->{-logic}     : "AND";
  my $SubTopics  = exists $ArgRef->{-subtopics} ?   $ArgRef->{-subtopics} : $FALSE;
  my @InitialIDs = exists $ArgRef->{-topicids}  ? @{$ArgRef->{-topicids}} : ();

  require "TopicUtilities.pm";
  require "Utilities.pm";
  require "Sorts.pm";

  if ($Logic eq "AND" && $SubTopics) { # Break up and call recursively
    my %Revisions = ();
    foreach my $TopicID (@InitialIDs) {
      my %TopicRevisions = ();
      my @ChildIDs  = TopicAndSubTopics({-topicid => $TopicID});
      my @Revisions = TopicSearch({-logic => "OR", -topicids => \@ChildIDs});
      @Revisions = Unique(@Revisions);
      foreach my $DocRevID (@Revisions) {
        ++$Revisions{$DocRevID};
      }
    }
    my @Revisions = ();
    foreach my $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == scalar(@InitialIDs)) {
        push @Revisions,$DocRevID;
      }
    }
    return @Revisions;
  }

  # Other cases handled non-recursively

  my $List = $dbh -> prepare("select DocRevID from RevisionTopic where TopicID=?");

  my @TopicIDs = ();
  my @Revisions = ();
  my %Revisions = ();

  if ($Logic eq "OR" && $SubTopics) {
    foreach my $TopicID (@InitialIDs) {
      my @ChildIDs = TopicAndSubTopics({-topicid => $TopicID});
      push @TopicIDs,@ChildIDs;
    }
    @TopicIDs = Unique(@TopicIDs);
  } else {
    @TopicIDs = @InitialIDs;
  }

  foreach $TopicID (@TopicIDs) {
    $List -> execute($TopicID );
    $List -> bind_columns(undef, \($DocRevID));
    my %TopicRevisions = ();
    while ($List -> fetch) { # Make sure each topic only matches once
      ++$TopicRevisions{$DocRevID};
    }
    foreach $DocRevID (keys %TopicRevisions) {
      ++$Revisions{$DocRevID};
    }
  }

  if ($Logic eq "AND") {
    foreach $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == $#TopicIDs+1) { # Require a match for each topic
        push @Revisions,$DocRevID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Revisions = keys %Revisions;
  }
  return @Revisions;
}

sub EventSearch {
  my $List;
  my ($Logic,$Type,@IDs) = @_;
  if ($Type eq "event") {
    $List = $dbh -> prepare("select DocRevID from RevisionEvent where ConferenceID=?");
  } elsif ($Type eq "group") {
    $List = $dbh -> prepare(
      "select DocRevID from RevisionEvent,Conference ".
      "where RevisionEvent.ConferenceID=Conference.ConferenceID ".
      "and Conference.EventGroupID=?");
  }

  my %Revisions = ();
  my @Revisions = ();
  my $DocRevID;

  foreach $ID (@IDs) {
    $List -> execute($ID);
    $List -> bind_columns(undef, \($DocRevID));
    my %EventRevisions = ();
    while ($List -> fetch) { # Make sure each event only matches once
      ++$EventRevisions{$DocRevID};
    }
    foreach $DocRevID (keys %EventRevisions) {
      ++$Revisions{$DocRevID};
    }
  }
  if ($Logic eq "AND") {
    foreach $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == scalar(@IDs)) { # Require a match for each topic
        push @Revisions,$DocRevID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Revisions = keys %Revisions;
  }

  return @Revisions;
}

sub AuthorSearch {
  my $revtopic_list;
  my ($Logic,@AuthorIDs) = @_;
  $revauthor_list = $dbh -> prepare("select DocRevID from RevisionAuthor where AuthorID=?");

  my %Revisions = ();
  my @Revisions = ();
  my $DocRevID;

  foreach my $AuthorID (@AuthorIDs) {
    $revauthor_list -> execute($AuthorID);
    $revauthor_list -> bind_columns(undef, \($DocRevID));
    while ($revauthor_list -> fetch) {
      ++$Revisions{$DocRevID};
    }
  }
  if ($Logic eq "AND") {
    foreach $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == $#AuthorIDs+1) { # Require a match for each topic
        push @Revisions,$DocRevID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Revisions = keys %Revisions;
  }

  return @Revisions;
}

sub TypeSearch {
  my ($Logic,@TypeIDs) = @_;
  my $List = $dbh -> prepare("select DISTINCT(DocumentID) from DocumentRevision where DocTypeID=? and Obsolete=0");

  my %Documents = ();
  my @Documents = ();
  my $DocumentID;

  foreach my $TypeID (@TypeIDs) {
    $List -> execute($TypeID);
    $List -> bind_columns(undef, \($DocumentID));
    while ($List -> fetch) {
      ++$Documents{$DocumentID};
    }
  }
  if ($Logic eq "AND") {
    foreach $DocumentID (keys %Documents) {
      if ($Documents{$DocumentID} == scalar(@TypeIDs)) { # Require a match for each type
        push @Documents,$DocumentID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Documents = keys %Documents;
  }

  return @Documents;
}

sub ValidateRevisions {
  require "RevisionSQL.pm";

  my (@RevisionIDs) = @_;
  my %DocumentIDs = ();
  my @DocumentIDs = ();

  foreach my $RevID (@RevisionIDs) {
    &FetchDocRevisionByID($RevID);
    unless ($DocRevisions{$RevID}{Obsolete}) {
      $DocumentIDs{$DocRevisions{$RevID}{DOCID}} = 1;
    }
  }
  @DocumentIDs = keys %DocumentIDs;
  return @DocumentIDs;
}

sub AddSearchWeights ($) {
  my ($ArgRef) = @_;
  my @Revisions   = exists $ArgRef->{-revisions}   ? @{$ArgRef->{-revisions}}   : ();
  my @Topics      = exists $ArgRef->{-topics}      ? @{$ArgRef->{-topics}}      : ();
  my @Events      = exists $ArgRef->{-events}      ? @{$ArgRef->{-events}}      : ();
  my @EventGroups = exists $ArgRef->{-eventgroups} ? @{$ArgRef->{-eventgroups}} : ();
  my @Authors     = exists $ArgRef->{-authors}     ? @{$ArgRef->{-authors}}     : ();
  my @DocTypes    = exists $ArgRef->{-doctypes}    ? @{$ArgRef->{-doctypes}}    : ();
  my @Files       = exists $ArgRef->{-files}       ? @{$ArgRef->{-files}}       : ();
  my @Contents    = exists $ArgRef->{-contents}    ? @{$ArgRef->{-contents}}     : ();

  foreach my $DocumentID (@Revisions) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Revision"};
  }
  foreach my $DocumentID (@Topics) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Topic"};
  }
  foreach my $DocumentID (@Events) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Event"};
  }
  foreach my $DocumentID (@EventGroups) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"EventGroup"};
  }
  foreach my $DocumentID (@Authors) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Author"};
  }
  foreach my $DocumentID (@DocTypes) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"DocType"};
  }
  foreach my $DocumentID (@Files) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"File"};
  }
  foreach my $DocumentID (@Contents) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"FileContent"};
  }
}

1;
