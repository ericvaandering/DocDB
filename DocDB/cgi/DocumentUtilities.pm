#
#        Name: $RCSfile$
# Description: Routines to deal with documents
#
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

sub AddDocument {
  require "FileUtilities.pm";
  require "FSUtilities.pm";

  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  require "TopicSQL.pm";
  require "AuthorSQL.pm";
  require "MeetingSQL.pm";
  require "SecuritySQL.pm";
  require "SignoffSQL.pm";

  my ($ArgRef) = @_;

  my $DefaultTime;
  unless ($DateTime) {
    my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
    $Year += 1900;
    ++$Mon;
    $DefaultTime = "$Year-$Mon-$Day $Hour:$Min:$Sec";
  }

  my $DocumentID    =  exists $ArgRef->{-docid} ? $ArgRef->{-docid}       :  0 ;  # The number the database will use for the document id. If not specified, the database will automaticaly generate a new document number.
  # The version number of the document.
  # If undefined or "bump", the database will automaticaly increment the version number.
  # If set to "latest", the last existing version will be updated (Update DB Info).
  # If a version number is given, that version will be updated.
  my $Version       = exists $ArgRef->{-version}       ? $ArgRef->{-version}       : "bump";
  my $Title         = exists $ArgRef->{-title}         ? $ArgRef->{-title}         : "";
  my $Abstract      = exists $ArgRef->{-abstract}      ? $ArgRef->{-abstract}      : "";
  my $Keywords      = exists $ArgRef->{-keywords}      ? $ArgRef->{-keywords}      : "";
  my $TypeID        = exists $ArgRef->{-typeid}        ? $ArgRef->{-typeid}        : 0 ; # Internal ID number
  my $RequesterID   = exists $ArgRef->{-requesterid}   ? $ArgRef->{-requesterid}   : 0 ; # Internal ID number
  my $Note          = exists $ArgRef->{-note}          ? $ArgRef->{-note}          : "";
  my $PubInfo       = exists $ArgRef->{-pubinfo}       ? $ArgRef->{-pubinfo}       : "";
  my $DateTime      = exists $ArgRef->{-datetime}      ? $ArgRef->{-datetime}      : $DefaultTime ; # In SQL format (YYYY-MM-DD HH:MM:SS)
  my $SessionTalkID = exists $ArgRef->{-sessiontalkid} ? $ArgRef->{-sessiontalkid} : 0 ; # Not used yet
  my $UniqueID      = exists $ArgRef->{-uniqueid}      ? $ArgRef->{-uniqueid}      : 0 ; # Not used yet, parameter to keep from inserting duplicate documents via Web

  my @AuthorIDs  = exists $ArgRef->{-authorids}  ? @{$ArgRef->{-authorids} } : (); # Internal ID numbers
  my @TopicIDs   = exists $ArgRef->{-topicids}   ? @{$ArgRef->{-topicids}  } : (); # Internal ID numbers
  my @EventIDs   = exists $ArgRef->{-eventids}   ? @{$ArgRef->{-eventids}  } : (); # Internal ID numbers
  my @ViewIDs    = exists $ArgRef->{-viewids}    ? @{$ArgRef->{-viewids}   } : (); # Internal ID numbers
  my @ModifyIDs  = exists $ArgRef->{-modifyids}  ? @{$ArgRef->{-modifyids} } : (); # Internal ID numbers
  my @SignOffIDs = exists $ArgRef->{-signoffids} ? @{$ArgRef->{-signoffids}} : (); # For simple signoff list, may be deprecated

  my %Files      = exists $ArgRef->{-files}      ? %{$ArgRef->{-files}     } : (); # File hash. See FileUtilities.pm
  my %References = exists $ArgRef->{-references} ? %{$ArgRef->{-references}} : (); # Not used yet
  my %Signoffs   = exists $ArgRef->{-signoffs}   ? %{$ArgRef->{-signoffs}  } : (); # Not used yet

  if ($Version eq "same") {
    $Version = "latest"; # FIXME: Is this needed? Shouldn't be.
  }
  push @DebugStack,"AddDocument: DocID=$DocumentID, Version=$Version";
  my ($DocRevID,$Count,@FileIDs);

  my $ExistingDocumentID = FetchDocument($DocumentID);
  unless ($ExistingDocumentID) {
    $DocumentID = InsertDocument(-docid    => $DocumentID, -requesterid => $RequesterID,
                                 -datetime => $DateTime);
    push @DebugStack,"Document $DocumentID inserted";
  }

  if ($DocumentID) {
    $DocRevID = InsertRevision(
                 -docid       => $DocumentID,  -doctypeid => $TypeID,
                 -submitterid => $RequesterID, -title     => $Title,
                 -pubinfo     => $PubInfo,     -abstract  => $Abstract,
                 -version     => $Version,     -datetime  => $DateTime,
                 -keywords    => $Keywords,    -note      => $Note);
    push @DebugStack,"DocRevID $DocRevID inserted";
    #FUTURE: Deal with SessionTalkID
  }

  my $Count;
  if ($DocRevID) {
    FetchDocRevisionByID($DocRevID);
    my $NewVersion    = $DocRevisions{$DocRevID}{Version};
    $Count = InsertAuthors(       -docrevid => $DocRevID, -authorids => \@AuthorIDs);
    $Count = InsertTopics(        -docrevid => $DocRevID, -topicids  => \@TopicIDs);
    $Count = InsertRevisionEvents(-docrevid => $DocRevID, -eventids  => \@EventIDs);
    $Count = InsertSecurity(      -docrevid => $DocRevID, -viewids   => \@ViewIDs,
                                                          -modifyids => \@ModifyIDs);
    if ($Version eq "bump" || $Version eq "new") {
      push @DebugStack,"Uploading files";
      MakeDirectory($DocumentID,$NewVersion);
      ProtectDirectory($DocumentID,$NewVersion,@ViewIDs);
      @FileIDs = AddFiles(-docrevid => $DocRevID, -datetime => $DateTime, -files => \%Files);
    } elsif ($Version eq "latest" || int($Version) > 0) {
      @FileIDs = AddFiles(-docrevid => $DocRevID,   -datetime => $DateTime,
                          -files    => \%Files,   -oldversion => $NewVersion);
    }


    if (@SignOffIDs) {
      InsertSignoffList($DocRevID,@SignOffIDs);
    }
  }

  return ($DocumentID,$DocRevID);
}

sub PrepareFieldList (%) {
  my %Params = @_;

  my @Fields       = @{$Params{-fields}};
  my $Default      = $Params{-default}      || "";
  my $TopicID      = $Params{-topicid}      || 0;
  my $DocTypeID    = $Params{-doctypeid}    || 0;
  my $EventID      = $Params{-eventid}      || 0;
  my $EventGroupID = $Params{-eventgroupid} || 0;

  # Given a bunch of parameters for what the current list of documents contains,
  # apply a precedence operation and figure out if any of the various ways of
  # returning a field list give us something. Fall back on defaults.
  # Precedence is 1) @Fields if specified
  #               2) Cookies for user a) event b) eventgroup c) topic d) defaults
  #               3) DB definitions   a) event b) eventgroup c) topic d) defaults
  #               4) DocDB defined defaults
  #               5) Default of all lists

  require "ConfigSQL.pm";
  require "DocDBFields.pm";

  if ($TopicID) {
    require "TopicSQL.pm";
    GetTopics();
  }

  my %FieldList = ();

  # If fields are specified, use that
  if (@Fields) {
    %FieldList = FieldsToFieldlist(@Fields);
    if (%FieldList) {
      return %FieldList
    }
  }

  #  User Cookie for event
  if ($query && $EventID && $query -> cookie("eventid_$EventID") ) {
    %FieldList = CookieToFieldList( $query -> cookie("eventid_$EventID") );
    if (%FieldList) {
      return %FieldList
    }
  }

  #  User Cookie for eventgroup
  if ($query && $EventGroupID && $query -> cookie("eventgroupid_$EventGroupID") ) {
    %FieldList = CookieToFieldList( $query -> cookie("eventgroupid_$EventGroupID") );
    if (%FieldList) {
      return %FieldList
    }
  }

  #  User Cookie for topic or parents
  foreach my $ParentTopicID ( @{$TopicProvenance{$TopicID}} ) {
    if ($query && $query -> cookie("topicid_$ParentTopicID") ) {
      %FieldList = CookieToFieldList( $query -> cookie("topicid_$ParentTopicID") );
      if (%FieldList) {
        return %FieldList
      }
    }
  }

  #  User Cookie for document type
  if ($query && $DocTypeID && $query -> cookie("doctypeid_$DocTypeID") ) {
    %FieldList = CookieToFieldList( $query -> cookie("doctypeid_$DocTypeID") );
    if (%FieldList) {
      return %FieldList
    }
  }

  #  User Cookie for default group
  if ($query && $Default && $query -> cookie("$Default") ) {
    %FieldList = CookieToFieldList( $query -> cookie("$Default") );
    if (%FieldList) {
      return %FieldList
    }
  }

  #  DB lookup for event
  if ($EventID) {
    %FieldList = FetchCustomFieldList(-eventid => $EventID);
    if (%FieldList) {
      return %FieldList
    }
  }

  #  DB lookup for event group
  if ($EventGroupID) {
    %FieldList = FetchCustomFieldList(-eventgroupid => $EventGroupID);
    if (%FieldList) {
      return %FieldList
    }
  }

  #  DB lookup for topic or parent
  if ($TopicID) {
    foreach my $ParentTopicID ( @{$TopicProvenance{$TopicID}} ) {
      %FieldList = FetchCustomFieldList(-topicid => $ParentTopicID);
      if (%FieldList) {
        return %FieldList
      }
    }
  }

  #  DB lookup for document type
  if ($DocTypeID) {
    %FieldList = FetchCustomFieldList(-doctypeid => $DocTypeID);
    if (%FieldList) {
      return %FieldList
    }
  }

  #  DB lookup   for default group
  if ($Default) {
    %FieldList = FetchCustomFieldList(-default => $Default);
    if (%FieldList) {
      return %FieldList
    }
  }

  # Default for various styles
  if ($Default) {
    my @DefaultFields = @{ $DefaultFieldLists{$Default} };
    %FieldList = FieldsToFieldlist(@DefaultFields);
    if (%FieldList) {
      return %FieldList
    }
  }

  # Default for "Default" (probably never gets here)
  my @DefaultFields = @{ $DefaultFieldLists{"Default"} };
  %FieldList = FieldsToFieldlist(@DefaultFields);
  return %FieldList
}

sub FieldsToFieldlist {
  my @Fields = @_;
  my %FieldList = ();

  my $Column = 0;
  my $Row    = 1;
  foreach my $Field (@Fields) {
    ++$Column;
    $FieldList{$Field}{Column}  = $Column;
    $FieldList{$Field}{Row}     = 1;
    $FieldList{$Field}{RowSpan} = 1;
    $FieldList{$Field}{ColSpan} = 1;
  }

  return %FieldList;
}

sub CookieToFieldList {
  my ($Value) = @_;
  my @Settings = split /\;/,$Value;

  my %FieldList = ();
  foreach my $Setting (@Settings) {
    my ($Field,$Row,$Column,$RowSpan,$ColSpan) = split /_/,$Setting;
    push @DebugStack, "Setting fieldlist to $Field,$Row,$Column,$RowSpan,$ColSpan";
    $FieldList{$Field}{Row}     = $Row;
    $FieldList{$Field}{Column}  = $Column;
    $FieldList{$Field}{RowSpan} = $RowSpan;
    $FieldList{$Field}{ColSpan} = $ColSpan;
  }
  return %FieldList;
}

sub RevisionToDocumentIDs {
  my ($ArgRef) = @_;
  my @RevisionIDs = exists $ArgRef->{-revisionids} ? @{$ArgRef->{-revisionids}} : ();

  foreach my $DocRevID (@RevisionIDs) {
    if ($DocRevisions{$DocRevID}{DOCID}) {
      $DocIDs{$DocRevisions{$DocRevID}{DOCID}} = 1;
    }
  }
  my @DocumentIDs = keys %DocIDs;
  return @DocumentIDs;
}

1;
