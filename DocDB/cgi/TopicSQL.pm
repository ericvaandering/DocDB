#
#        Name: $RCSfile$
# Description: Routines to do DB accesses related to topics
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:

# Copyright 2001-2011 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub GetTopics {
  if ($GotAllTopics) {return;}

  require "TopicUtilities.pm";

  %Topics        = ();
  %TopicCounts   = ();
  %TopicParents  = ();
  %TopicChildren = ();

  my ($TopicID,$ShortDescription,$LongDescription,$ParentTopicID);

  my $TopicList     = $dbh -> prepare("select TopicID,ShortDescription,LongDescription from Topic");
  my $HierarchyList = $dbh -> prepare("select TopicID,ParentTopicID from TopicHierarchy");
  $TopicList -> execute();
  $TopicList -> bind_columns(undef, \($TopicID,$ShortDescription,$LongDescription));
  while ($TopicList -> fetch) {
    $Topics{$TopicID}{Short} = $ShortDescription;
    $Topics{$TopicID}{Long}  = $LongDescription;
  }

  $HierarchyList -> execute();
  $HierarchyList -> bind_columns(undef, \($TopicID,$ParentTopicID));
  while ($HierarchyList -> fetch) {
    push @{$TopicParents{$TopicID}}       ,$ParentTopicID;
    push @{$TopicChildren{$ParentTopicID}},$TopicID;
  }

  # Count how many times each topic is listed
  my $TopicCount = $dbh -> prepare("select DISTINCT RevisionTopic.TopicID,DocumentRevision.DocumentID ".
                                   "from RevisionTopic ".
                                   "LEFT JOIN DocumentRevision on (RevisionTopic.DocRevID=DocumentRevision.DocRevID)");
  $TopicCount -> execute();
  $TopicCount -> bind_columns(undef, \($TopicID,$Count));
  while ($TopicCount -> fetch) {
    $TopicCounts{$TopicID}{Exact} = $Count;
    $TopicCounts{$TopicID}{Total} = $Count;
    # May want to add children to Total
  }

  BuildTopicProvenance();
  $GotAllTopics = 1;
};

sub GetRevisionTopics {
  my ($ArgRef) = @_;
  my $DocRevID = exists $ArgRef->{-docrevid} ? $ArgRef->{-docrevid} : 0;

  require "Utilities.pm";

  my @TopicIDs = ();
  my ($RevTopicID,$TopicID);
  my $List = $dbh->prepare(
    "select RevTopicID,TopicID from RevisionTopic where DocRevID=?");
  $List -> execute($DocRevID);
  $List -> bind_columns(undef, \($RevTopicID,$TopicID));
  while ($List -> fetch) {
    if (FetchTopic( {-topicid => $TopicID} )) {
      push @TopicIDs,$TopicID;
    }
  }
  @TopicIDs = Unique(@TopicIDs);
  return @TopicIDs;
}

sub ClearTopics {
  %Topics        = ();
  %TopicParents  = ();
  %TopicChildren = ();
  $GotAllTopics  = 0;
  return;
}

sub FetchTopic { # Fetches an Topic by ID, adds to $Topics{$TopicID}{}
  my ($ArgRef) = @_;
  my $TopicID = exists $ArgRef->{-topicid} ? $ArgRef->{-topicid} : 0;

  my ($ShortDescription,$LongDescription);
  if ($Topics{$TopicID}{Short}) { # We already have this one
    return $TopicID;
  }
  if ($GotAllTopics) { # We already have them all, but not this one
    return undef;
  }

  my $Fetch   = $dbh -> prepare(
    "select ShortDescription,LongDescription ".
    "from Topic where TopicID=?");
  $Fetch -> execute($TopicID);
  ($ShortDescription,$LongDescription) = $Fetch -> fetchrow_array;
  $Topics{$TopicID}{Short} = $ShortDescription;
  $Topics{$TopicID}{Long}  = $LongDescription;

  if ($Topics{$TopicID}{Short}) { # We already have this one
    return $TopicID;
  } else {
    return undef;
  }
}

sub FetchTopicParents { # Returns parent IDs of topics
  my ($ArgRef) = @_;
  my $TopicID = exists $ArgRef->{-topicid} ? $ArgRef->{-topicid} : 0;

  unless (@{$TopicParents{$TopicID}}) {
    my $Fetch   = $dbh -> prepare("select ParentTopicID from TopicHierarchy where TopicID=?");
    $Fetch -> execute($TopicID);
    my @ParentIDs = ();
    while (my ($ParentID) = $Fetch -> fetchrow_array) {
      push @ParentIDs,$ParentID;
    }
    $TopicParents{$TopicID} = \@ParentIDs;
  }
  return @{$TopicParents{$TopicID}};
}

sub GetTopicDocuments {
  my ($TopicID) = @_;

  require "RevisionSQL.pm";

  my $DocumentID;
  my $DocRevID;
  my %DocumentIDs;

# FIXME: Use the relational DB!
#  This routine has a bug in that it still returns DocumentIDs (or something, like the keys of a hash with
#  null keys) in the case where topics are associated with obsolete revisions of documents. Fixing this would expose a bug
#  in DeleteTopic and would allow the user to delete topics that just had historical information, but no current associations
#  so that routine would also have to be changed to do a search on RevisionTopic directly.

  my $RevisionList = $dbh -> prepare("select DocRevID from RevisionTopic where TopicID=?");
  my $DocumentList = $dbh -> prepare("select DocumentID from DocumentRevision where DocRevID=? and Obsolete=0");
  $RevisionList -> execute($TopicID);
  $RevisionList -> bind_columns(undef, \($DocRevID));

  while ($RevisionList -> fetch) {
    FetchDocRevisionByID($DocRevID);
    if ($DocRevisions{$DocRevID}{Obsolete}) {next;}
    $DocumentList -> execute($DocRevID);
    ($DocumentID) = $DocumentList -> fetchrow_array;
    $DocumentIDs{$DocumentID} = 1; # Hash removes duplicates
  }
  my @DocumentIDs = keys %DocumentIDs;
  return @DocumentIDs;
}

sub MatchTopic ($) {
  my ($ArgRef) = @_;
  my $Short      = exists $ArgRef->{-short}    ? $ArgRef->{-short}    : "";
  my $Long       = exists $ArgRef->{-long}     ? $ArgRef->{-long}     : "";
  my $ParentID   = exists $ArgRef->{-parent}   ? $ArgRef->{-parent}   : 0;
  my $AncestorID = exists $ArgRef->{-ancestor} ? $ArgRef->{-ancestor} : 0;
  my $TopicID;
  my @TopicIDs = ();
  if ($Short) {
    $Short =~ tr/[A-Z]/[a-z]/;
    $Short = "%".$Short."%";
    my $List = $dbh -> prepare("select TopicID from Topic where LOWER(ShortDescription) like ?");
    $List -> execute($Short);
    $List -> bind_columns(undef, \($TopicID));
    while ($List -> fetch) {
      push @TopicIDs,$TopicID;
    }
  } elsif ($Long) {
    $Long =~ tr/[A-Z]/[a-z]/;
    $Long = "%".$Long."%";
    my $List = $dbh -> prepare("select TopicID from Topic where LOWER(LongDescription) like ?");
    $List -> execute($Long);
    $List -> bind_columns(undef, \($TopicID));
    while ($List -> fetch) {
      push @TopicIDs,$TopicID;
    }
  }

  if ($ParentID) {
    GetTopics();
    my @CandidateIDs = @TopicIDs;
    @TopicIDs = ();
    foreach my $TopicID (@CandidateIDs) {
      foreach my $ID (@{$TopicParents{$TopicID}}) {
        if ($ParentID == $ID) {
          push @TopicIDs,$TopicID;
        }
      }
    }
  }

  if ($AncestorID) {
    GetTopics();
    my @CandidateIDs = @TopicIDs;
    @TopicIDs = ();
    foreach my $TopicID (@CandidateIDs) {
      foreach my $ID (@{$TopicProvenance{$TopicID}}) {
        if ($AncestorID == $ID) {
          push @TopicIDs,$TopicID;
        }
      }
    }
  }

  return @TopicIDs;
}

sub InsertTopics (%) {
  my %Params = @_;

  my $DocRevID =   $Params{-docrevid} || "";
  my @TopicIDs = @{$Params{-topicids}};

  my $Count = 0;

  my $Insert = $dbh -> prepare("insert into RevisionTopic (RevTopicID, DocRevID, TopicID) values (0,?,?)");

  foreach my $TopicID (@TopicIDs) {
    if ($TopicID) {
      $Insert -> execute($DocRevID,$TopicID);
      ++$Count;
    }
  }
  return $Count;
}

sub DeleteTopic ($) {
  my ($ArgRef) = @_;
  my $TopicID = exists $ArgRef->{-topicid} ? $ArgRef->{-topicid} : 0;
  my $Force   = exists $ArgRef->{-force}   ? $ArgRef->{-force}   : $FALSE;

  require "Messages.pm";
  require "TopicUtilities.pm";
  require "MeetingSQL.pm";

  unless ($TopicID) {
    push @WarnStack,$Msg_ModTopicEmpty;
    return 0;
  }
  unless (FetchTopic({ -topicid => $TopicID })) {
    push @WarnStack,"Topic does not exist";
    return 0;
  }

  my @TopicDocIDs   = GetTopicDocuments($TopicID);
  my @ChildTopicIDs = @{$TopicChildren{$TopicID}};
  my %EventHash     = GetEventHashByTopic($TopicID);

  my $Abort = $FALSE;
  if (@ChildTopicIDs && !$Force) {
    push @WarnStack,"Cannot delete a topic with sub-topic(s). ".
      "Use the force option to delete this topic and all its children and their associations. ".
      "Those associations, if any, are not reported here.";
    $Abort = $TRUE;
  }
  if (@TopicDocIDs && !$Force) {
    push @WarnStack,"Cannot delete a topic with associated documents. ".
      "Use the force option to delete this topic and all associations. ".
      "Some associations may be from documents updated with \"Update Metadata\" ".
      "which are no longer visible, but you must use the force option to erase this history.";
    $Abort = $TRUE;
  }

  if (%EventHash && !$Force) {
    push @WarnStack,"Cannot delete a topic with event(s) and/or sessions. ".
                    "Use the force option to delete this topic and all other associations. ";
    $Abort = $TRUE;
  }
  if ($Abort) {
    return 0;
  }

  my $TopicDelete     = $dbh -> prepare("delete from Topic          where TopicID=?");
  my $RevisionDelete  = $dbh -> prepare("delete from RevisionTopic  where TopicID=?");
  my $HintDelete      = $dbh -> prepare("delete from TopicHint      where TopicID=?");
  my $EventDelete     = $dbh -> prepare("delete from EventTopic     where TopicID=?");
  my $HierarchyDelete = $dbh -> prepare("delete from TopicHierarchy where TopicID=?");
  my $ParentDelete    = $dbh -> prepare("delete from TopicHierarchy where ParentTopicID=?");
  my $NotifyDelete    = $dbh -> prepare("delete from Notification   where Type='Topic' and ForeignID=?");
  my $ConfigDelete    = $dbh -> prepare("delete from ConfigSetting  where ConfigGroup='CustomField'
                                         and Sub1Group='TopicID' and ForeignID=?");

  my @TopicIDs = TopicAndSubTopics({ -topicid => $TopicID });
  foreach my $DeleteID (@TopicIDs) {
    $TopicDelete     -> execute($DeleteID);
    $RevisionDelete  -> execute($DeleteID);
    $HintDelete      -> execute($DeleteID);
    $EventDelete     -> execute($DeleteID);
    $HierarchyDelete -> execute($DeleteID);
    $ParentDelete    -> execute($DeleteID);
    $NotifyDelete    -> execute($DeleteID);
    $ConfigDelete    -> execute($DeleteID);
  }

  if ($Force) {
    push @ActionStack,"Topic <strong>$Topics{$TopicID}{LongDescription}</strong>, all sub-topics, all associations, and all associations to sub-topics deleted.";
  } else {
    push @ActionStack,"Topic <strong>$Topics{$TopicID}{LongDescription}</strong> deleted.";
  }
  return 1;
}
1;
