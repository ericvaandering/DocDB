#
# Description: Routines to deal with documents
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

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
  
  my %Params = @_;
  
  my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);

  my $DocumentID    = $Params{-docid}         || 0;
  my $Version       = $Params{-version}       || "bump";
  my $Title         = $Params{-title}         || "";
  my $Abstract      = $Params{-abstract}      || "";
  my $Keywords      = $Params{-keywords}      || "";
  my $TypeID        = $Params{-typeid}        || 0;
  my $RequesterID   = $Params{-requesterid}   || 0;
  my $Note          = $Params{-note}          || "";
  my $PubInfo       = $Params{-pubinfo}       || "";
  my $DateTime      = $Params{-datetime};
  my $SessionTalkID = $Params{-sessiontalkid} || 0; # Not used yet
  
  my @AuthorIDs  = @{$Params{-authorids}} ;
  my @TopicIDs   = @{$Params{-topicids}}  ;
  my @EventIDs   = @{$Params{-eventids}}  ;
  my @ViewIDs    = @{$Params{-viewids}}   ;
  my @ModifyIDs  = @{$Params{-modifyids}} ;
  my @SignOffIDs = @{$Params{-signoffids}}; # For simple signoff list, may be deprecated
  
  my %Files      = %{$Params{-files}};
  my %References = %{$Params{-references}}; # Not used yet
  my %Signoffs   = %{$Params{-signoffs}};   # Not used yet

  unless ($DateTime) {
    my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
    $Year += 1900;
    ++$Mon;
    $DateTime = "$Year-$Mon-$Day $Hour:$Min:$Sec";
  } 

  my ($DocRevID,$Count,@FileIDs);

  $DocumentID = &InsertDocument(
                 -docid    => $DocumentID, -requesterid => $RequesterID, 
                 -datetime => $DateTime);
                 
  if ($DocumentID) {                                 
    $DocRevID = &InsertRevision(
                 -docid       => $DocumentID,  -doctypeid => $TypeID, 
                 -submitterid => $RequesterID, -title     => $Title,
                 -pubinfo     => $PubInfo,     -abstract  => $Abstract,
                 -version     => $Version,     -datetime  => $DateTime,
                 -keywords    => $Keywords,    -note      => $Note);

    # Deal with SessionTalkID

  }
  
  my $Count;
  if ($DocRevID) { 
    &FetchDocRevisionByID($DocRevID);
    my $Version    = $DocRevisions{$DocRevID}{Version};
    &MakeDirectory($DocumentID,$Version); 
    &ProtectDirectory($DocumentID,$Version,@ViewIDs); 
    $Count = &InsertAuthors(-docrevid        => $DocRevID, -authorids => \@AuthorIDs);
    $Count = &InsertTopics(-docrevid         => $DocRevID, -topicids  => \@TopicIDs);
    $Count = &InsertRevisionEvents(-docrevid => $DocRevID, -eventids  => \@EventIDs);
    $Count = &InsertSecurity(-docrevid       => $DocRevID, -viewids   => \@ViewIDs, -modifyids => \@ModifyIDs);
    unless ($Version eq "reserve") {
      @FileIDs = &AddFiles(-docrevid         => $DocRevID, -datetime  => $DateTime, -files => \%Files);
    }
    if (@SignOffIDs) {
      &InsertSignoffList($DocRevID,@SignOffIDs);
    }  
  }
  
  return ($DocumentID,$DocRevID);                                 
}

sub PrepareFieldList (%) {
  my %Params = @_;
  
  my @Fields       = @{$Params{-fields}}; 
  my $Default      = $Params{-default}      || "";
  my $TopicID      = $Params{-topicid}      || 0;
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
  require "Fields.pm";
  
  my %FieldList = ();
  
  # If fields are specified, use that
  if (@Fields) {
    %FieldList = FieldsToFieldlist(@Fields);
    if (%FieldList) {
      return %FieldList
    }  
  }  
  
  #  User Cookie for event
  if ($EventID && $query -> cookie("eventid_$EventID") ) {
    %FieldList = CookieToFieldList( $query -> cookie("eventid_$EventID") );
    if (%FieldList) {
      return %FieldList
    }  
  }

  #  User Cookie for eventgroup
  if ($EventGroupID && $query -> cookie("eventgroupid_$EventGroupID") ) {
    %FieldList = CookieToFieldList( $query -> cookie("eventgroupid_$EventGroupID") );
    if (%FieldList) {
      return %FieldList
    }  
  }
  
  #  User Cookie for topic
  if ($TopicID && $query -> cookie("topicid_$TopicID") ) {
    %FieldList = CookieToFieldList( $query -> cookie("topicid_$TopicID") );
    if (%FieldList) {
      return %FieldList
    }  
  }
  
  #  User Cookie for default group
  if ($Default && $query -> cookie("$Default") ) {
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
    
  #  DB lookup for topic
  if ($TopicID) {
    %FieldList = FetchCustomFieldList(-topicid => $TopicID);
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
1;
