#
#        Name: TopicSQL.pm
# Description: Routines to do DB accesses related to topics 
#              (major and minor) 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub GetTopics { #V8OBS everything from here down to new code
  require "MeetingSQL.pm";

  my $minor_list   = $dbh->prepare("select MinorTopicID,MajorTopicID,ShortDescription,LongDescription from MinorTopic");
  my $major_list   = $dbh->prepare("select MajorTopicID,ShortDescription,LongDescription from MajorTopic");

  %MinorTopics  = ();
  %MajorTopics  = ();
  $GotAllTopics = 0;

  my ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription);

  $major_list -> execute;
  $major_list -> bind_columns(undef, \($MajorTopicID,$ShortDescription,$LongDescription));
  while ($major_list -> fetch) {
    $MajorTopics{$MajorTopicID}{MAJOR} = $MajorTopicID;
    $MajorTopics{$MajorTopicID}{SHORT} = $ShortDescription;
    $MajorTopics{$MajorTopicID}{LONG}  = $LongDescription;
    $MajorTopics{$MajorTopicID}{Full}  = $ShortDescription." [".$LongDescription."]";
  }

  $minor_list -> execute;
  $minor_list -> bind_columns(undef, \($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription));
  while ($minor_list -> fetch) {
    $MinorTopics{$MinorTopicID}{MINOR} = $MinorTopicID;
    $MinorTopics{$MinorTopicID}{MAJOR} = $MajorTopicID;
    $MinorTopics{$MinorTopicID}{SHORT} = $ShortDescription;
    $MinorTopics{$MinorTopicID}{LONG}  = $LongDescription;
    $MinorTopics{$MinorTopicID}{Full}  = $MajorTopics{$MajorTopicID}{SHORT}.":".$ShortDescription;
  }
  
### V8OBS: Everything above this

  if ($GotAllTopics) {return;}
  %Topics        = ();
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

  $GotAllTopics = 1;
};

sub GetSubTopics {# V8OBS
  my ($MajorTopicID) = @_;
  my @MinorTopicIDs = ();
  my $MinorList = $dbh->prepare("select MinorTopicID from MinorTopic where MajorTopicID=?");

  my ($MinorTopicID);
  $MinorList -> execute($MajorTopicID);
  $MinorList -> bind_columns(undef, \($MinorTopicID));
  while ($MinorList -> fetch) {
    push @MinorTopicIDs,$MinorTopicID;
  }
  return @MinorTopicIDs;
};

sub FetchMinorTopic { # V8OBS# Fetches an MinorTopic by ID, adds to $Topics{$TopicID}{}
  my ($minorTopicID) = @_;
  my ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription);
  my $minor_fetch   = $dbh -> prepare(
    "select MinorTopicID,MajorTopicID,ShortDescription,LongDescription ".
    "from MinorTopic ".
    "where MinorTopicID=?");
  if ($MinorTopics{$minorTopicID}{MINOR}) { # We already have this one
    return $MinorTopics{$minorTopicID}{MINOR};
  }
  
  $minor_fetch -> execute($minorTopicID);
  ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription) = $minor_fetch -> fetchrow_array;
  &FetchMajorTopic($MajorTopicID);
  $MinorTopics{$MinorTopicID}{MINOR} = $MinorTopicID;
  $MinorTopics{$MinorTopicID}{MAJOR} = $MajorTopicID;
  $MinorTopics{$MinorTopicID}{SHORT} = $ShortDescription;
  $MinorTopics{$MinorTopicID}{LONG}  = $LongDescription;
  $MinorTopics{$MinorTopicID}{Full}  = $MajorTopics{$MajorTopicID}{SHORT}.":".$ShortDescription;

  return $MinorTopics{$MinorTopicID}{MINOR};
}

sub FetchMinorTopicByInfo (%) { # V8OBS# Keep for John/Lynn? Can eventually add short/long, major topics
  my %Params = @_;
  
  my $Short = $Params{-short}; 
  
  my $Select = $dbh -> prepare("select MinorTopicID from MinorTopic where lower(ShortDescription) like lower(?)");
  $Select -> execute($Short);
  my ($MinorTopicID) = $Select -> fetchrow_array;
  
  if ($MinorTopicID) {
    &FetchMinorTopic($MinorTopicID);
  } else {
    return 0;
  }  
  return $MinorTopicID;
}

sub FetchMajorTopic { # V8OBS# Fetches an MajorTopic by ID, adds to $Topics{$TopicID}{}
  my ($majorTopicID) = @_;
  my ($MajorTopicID,$ShortDescription,$LongDescription);
  my $major_fetch   = $dbh -> prepare(
    "select MajorTopicID,ShortDescription,LongDescription ".
    "from MajorTopic ".
    "where MajorTopicID=?");
  if ($MajorTopics{$majorTopicID}{MAJOR}) { # We already have this one
    return $MajorTopics{$majorTopicID}{MAJOR};
  }

  $major_fetch -> execute($majorTopicID);
  ($MajorTopicID,$ShortDescription,$LongDescription) = $major_fetch -> fetchrow_array;
  $MajorTopics{$MajorTopicID}{MAJOR} = $MajorTopicID;
  $MajorTopics{$MajorTopicID}{SHORT} = $ShortDescription;
  $MajorTopics{$MajorTopicID}{LONG}  = $LongDescription;

  return $MajorTopics{$MajorTopicID}{MAJOR};
}

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
  @TopicIDs = &Unique(@TopicIDs);
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
#  &FetchMajorTopic($MajorTopicID);
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
  #FIXME: Use the relational DB!
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

sub LookupMajorTopic { # V8OBS# Returns MajorTopicID from Topic Name
  my ($TopicName) = @_;
  my $major_fetch   = $dbh -> prepare(
    "select MajorTopicID from MajorTopic where ShortDescription=?");

  $major_fetch -> execute($TopicName);
  my $MajorTopicID = $major_fetch -> fetchrow_array;
  &FetchMajorTopic($MajorTopicID);
  
  return $MajorTopicID;
}

sub MatchTopic ($) { # V8OBS# FIXME: Make LookupMajorTopic a subset?
  my ($ArgRef) = @_;
  my $Short = exists $ArgRef->{-short} ? $ArgRef->{-short} : "";
#  my $Long = exists $ArgRef->{-long}  ? $ArgRef->{-long}  : "";
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
  }
  return @TopicIDs;
}

sub InsertTopics (%) {# V8OBS
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

  my $Abort = $FALSE;
  if (@ChildTopicIDs && !$Force) {
    push @WarnStack,"Cannot delete a topic with sub-topic. Use the force option to delete this topic and all its children.";
    $Abort = $TRUE;
  }
  if (@TopicDocIDs && !$Force) {
    push @WarnStack,"Cannot delete a topic with associated with documents. Use the force option to delete this topic and all associations.";
    $Abort = $TRUE;
  }
  
  if ($Abort) {
    return 0;
  }  
  # FIXME: EventTopics will need a similar check

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
