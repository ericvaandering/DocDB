#
#        Name: MeetingSQL.pm 
# Description: Routines to access SQL tables related to conferences and meetings 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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

sub GetConferences { 
  if ($HaveAllConferences) {
    my @ConferenceIDs = keys %Conferences;
    return @ConferenceIDs;
  }  

  %Conferences = ();

  my @ConferenceIDs = ();
  my $ConferenceID;

  my $ConferenceList   = $dbh -> prepare("select ConferenceID from Conference");
  $ConferenceList -> execute();
  $ConferenceList -> bind_columns(undef, \($ConferenceID));
  while ($ConferenceList -> fetch) {
    $ConferenceID = &FetchConferenceByConferenceID($ConferenceID);
    push @ConferenceIDs,$ConferenceID;
  }
  $HaveAllConferences = $TRUE;
  return @ConferenceIDs;
}

sub ClearConferences () {
  %Conferences = ();
  $HaveAllConferences = $FALSE;
  return;
}

sub GetEventsByDate (%) {
  require "SQLUtilities.pm";
  require "Utilities.pm";
  require "MeetingSecurityUtilities.pm";

  my %Params = @_;
  
  my $From = $Params{-from} || "";
  my $To   = $Params{-to}   || "";
  my $On   = $Params{-on}   || SQLNow(-dateonly => $TRUE);
  
  
  my $List;
  if ($From && $To) { # Starts or ends in or surrounds window
    push @DebugStack,"Fetching events from $From to $To";
    $List = $dbh->prepare("select ConferenceID from Conference where (StartDate>=? and StartDate<=?) "."
                           or (EndDate>=? and EndDate<=?) or (StartDate<? and EndDate>?)");
    $List -> execute($From,$To,$From,$To,$From,$To);
  } else { 
    push @DebugStack,"Fetching events on $On";
    $List = $dbh->prepare("select ConferenceID from Conference where StartDate<=? and EndDate>=?");
    $List -> execute($On,$On);
  }
  
  my $EventID;
  my @EventIDs;
  $List -> bind_columns(undef, \($EventID));
  while ($List -> fetch) {
    if (FetchConferenceByConferenceID($EventID)) {
      if (CanAccessMeeting($EventID)) {
        push @EventIDs,$EventID;
      }  
    }  
  }
  @EventIDs = Unique(@EventIDs);
  return @EventIDs;
}

sub GetRevisionEvents ($) { # Get the events associated with a revision
  my ($DocRevID) = @_;
  
  require "Utilities.pm";
  
  my @ConferenceIDs = ();
  my $ConferenceID;
  
  # Fetch from RevisionEvent table
  
  my $EventList = $dbh -> prepare("select ConferenceID from RevisionEvent where DocRevID=?");
  $EventList -> execute($DocRevID);
  $EventList -> bind_columns(undef, \($ConferenceID));
  while ($EventList -> fetch) {
    if (&FetchConferenceByConferenceID($ConferenceID)) {
      push @ConferenceIDs,$ConferenceID;
    }  
  }
  
  # Fetch from SessionTalkID table
  
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $SessionList =  $dbh -> prepare("select Session.ConferenceID from Session,SessionTalk where SessionTalk.SessionID=Session.SessionID and SessionTalk.DocumentID=?"); 
  $SessionList -> execute($DocumentID);
  $SessionList -> bind_columns(undef, \($ConferenceID));
  while ($SessionList -> fetch) {
    if (&FetchConferenceByConferenceID($ConferenceID)) {
      push @ConferenceIDs,$ConferenceID;
    }  
  }

  @ConferenceIDs = &Unique(@ConferenceIDs);
  return @ConferenceIDs;
}

sub GetAllEventGroups () {
  if ($HaveAllEventGroups) {
    my @EventGroupIDs = keys %EventGroups;
    return @EventGroupIDs;
  }
  
  %EventGroups = ();
  my @EventGroupIDs = ();
  my ($EventGroupID);

  my $List = $dbh->prepare("select EventGroupID from EventGroup");
  $List -> execute();
  $List -> bind_columns(undef, \($EventGroupID));
  while ($List -> fetch) {
    if (&FetchEventGroup($EventGroupID)) {
      push @EventGroupIDs,$EventGroupID;
    }  
  }
  $HaveAllEventGroups = $TRUE;
  return @EventGroupIDs;  
}

sub ClearEventGroups () {
  %EventGroups = ();
  $HaveAllEventGroups = $FALSE;
  return;
}

sub LookupEventGroup { # Returns EventGroupID from Name
  my ($Name) = @_;
  my $Fetch   = $dbh -> prepare("select EventGroupID from EventGroup where ShortDescription=?");

  $Fetch -> execute($Name);
  my $EventGroupID = $Fetch -> fetchrow_array;
  &FetchEventGroup($EventGroupID);
  
  return $EventGroupID;
}

sub MatchEventGroup ($) {
  my ($ArgRef) = @_;
  my $Short = exists $ArgRef->{-short} ? $ArgRef->{-short} : "";
#  my $Long = exists $ArgRef->{-long}  ? $ArgRef->{-long}  : "";
  my $EventGroupID;
  my @MatchIDs = ();
  if ($Short) {
    $Short =~ tr/[A-Z]/[a-z]/;
    $Short = "%".$Short."%";
    my $List = $dbh -> prepare(
       "select EventGroupID from EventGroup where LOWER(ShortDescription) like ?"); 
    $List -> execute($Short);
    $List -> bind_columns(undef, \($EventGroupID));
    while ($List -> fetch) {
      push @MatchIDs,$EventGroupID;
    }
  }
  return @MatchIDs;
}

sub MatchEvent ($) {
  my ($ArgRef) = @_;
  my $Short = exists $ArgRef->{-short} ? $ArgRef->{-short} : "";
#  my $Long = exists $ArgRef->{-long}  ? $ArgRef->{-long}  : "";
  my $EventID;
  my @MatchIDs = ();
  if ($Short) {
    $Short =~ tr/[A-Z]/[a-z]/;
    $Short = "%".$Short."%";
    my $List = $dbh -> prepare(
       "select ConferenceID from Conference where LOWER(Title) like ?"); 
    $List -> execute($Short);
    $List -> bind_columns(undef, \($EventID));
    while ($List -> fetch) {
      push @MatchIDs,$EventID;
    }
  }
  return @MatchIDs;
}

sub FetchEventGroup ($) {
  my ($EventGroupID) = @_;
  unless ($EventGroupID) {
    return 0;
  }
    
  my $Fetch = $dbh->prepare("select ShortDescription,LongDescription,TimeStamp from EventGroup where EventGroupID=?");
  $Fetch -> execute($EventGroupID);
 
  my ($ShortDescription,$LongDescription,$TimeStamp) = $Fetch -> fetchrow_array;
  if ($TimeStamp) {
    $EventGroups{$EventGroupID}{ShortDescription} = $ShortDescription;
    $EventGroups{$EventGroupID}{LongDescription}  = $LongDescription; 
    $EventGroups{$EventGroupID}{TimeStamp}        = $TimeStamp; 
  } 
  return $EventGroupID;  
} 

sub FetchEventsByGroup ($) {
  my ($EventGroupID) = @_;
  unless ($EventGroupID) {
    return undef;
  }
  my $EventID;
  my @EventIDs = ();
  
  my $List = $dbh -> prepare("select ConferenceID from Conference where EventGroupID=?");
  $List -> execute($EventGroupID);
  $List -> bind_columns(undef, \($EventID));

  while ($List -> fetch) {
    push @EventIDs,$EventID;
  }
  return @EventIDs;
}  

sub FetchConferenceByConferenceID { # Fetches a conference by ConferenceID
  my ($EventID) = @_;
  
  require "TopicSQL.pm";
  
  if ($Conference{$EventID}{EventGroupID}) { # We already have this one
    return $EventID;
  }
  
  my $Fetch = $dbh -> prepare(
    "select EventGroupID,Location,AltLocation,URL,Title,LongDescription,Preamble,Epilogue,StartDate,EndDate,ShowAllTalks,TimeStamp ".
    "from Conference ".
    "where ConferenceID=?");
  $Fetch -> execute($EventID);
 
  my ($EventGroupID,$Location,$AltLocation,$URL,$Title,
      $LongDescription,$Preamble,$Epilogue,$StartDate,$EndDate,$ShowAllTalks,
      $TimeStamp) = $Fetch -> fetchrow_array;
  if ($EventGroupID) {
    $Conferences{$EventID}{EventGroupID}    = $EventGroupID;
    $Conferences{$EventID}{Location}        = $Location;
    $Conferences{$EventID}{AltLocation}     = $AltLocation;
    $Conferences{$EventID}{URL}             = $URL;
    $Conferences{$EventID}{Title}           = $Title;
    $Conferences{$EventID}{Preamble}        = $Preamble;
    $Conferences{$EventID}{LongDescription} = $LongDescription;
    $Conferences{$EventID}{Epilogue}        = $Epilogue;
    $Conferences{$EventID}{StartDate}       = $StartDate;
    $Conferences{$EventID}{EndDate}         = $EndDate;
    $Conferences{$EventID}{ShowAllTalks}    = $ShowAllTalks;
    $Conferences{$EventID}{TimeStamp}       = $TimeStamp;
    	
    FetchEventGroup($EventGroupID);
    $Conferences{$EventID}{Full}  = $EventGroups{$EventGroupID}{LongDescription}.":".$Title;
    @{$Conferences{$EventID}{Moderators}} = ();
    @{$Conferences{$EventID}{Topics}}     = ();
  }
  
  my $ModeratorSelect = $dbh -> prepare("select AuthorID from Moderator where EventID=?");
  $ModeratorSelect -> execute($EventID);
  while (my ($AuthorID) = $ModeratorSelect -> fetchrow_array()) {
    push @{$Conferences{$EventID}{Moderators}},$AuthorID;
  }

  my $TopicSelect = $dbh -> prepare("select TopicID from EventTopic where EventID=?");
  $TopicSelect -> execute($EventID);
  while (my ($TopicID) = $TopicSelect -> fetchrow_array()) {
    push @{$Conferences{$EventID}{Topics}},$TopicID;
  }

  return $EventID;
}

sub FetchSessionsByConferenceID ($) {
  my ($ConferenceID) = @_;
  my $SessionID;
  my @SessionIDs = ();
  my $SessionList   = $dbh -> prepare(
    "select SessionID from Session where ConferenceID=?");
  $SessionList -> execute($ConferenceID);
  $SessionList -> bind_columns(undef, \($SessionID));
  while ($SessionList -> fetch) {
    $SessionID = &FetchSessionByID($SessionID);
    push @SessionIDs,$SessionID;
  }
  return @SessionIDs; 
}

sub ClearSessions () {
  $HaveAllSessions          = 0;
  $HaveAllSessionSeparators = 0;
  %Sessions          = ();
  %SessionSeparators = ();
}

sub FetchSessionByID ($) {
  my ($SessionID) = @_;
  my ($ConferenceID,$StartTime,$Location,$Title,$Description,$TimeStamp); 
  my $SessionFetch = $dbh -> prepare(
    "select ConferenceID,StartTime,Location,AltLocation,Title,Description,TimeStamp ".
    "from Session where SessionID=?");
  if ($Sessions{$SessionID}{TimeStamp}) {
    return $SessionID;
  }
  $SessionFetch -> execute($SessionID);
  ($ConferenceID,$StartTime,$Location,$AltLocation,$Title,$Description,$TimeStamp) = $SessionFetch -> fetchrow_array; 
  if ($TimeStamp) {
    $Sessions{$SessionID}{ConferenceID}  = $ConferenceID;
    $Sessions{$SessionID}{StartTime}     = $StartTime;
    $Sessions{$SessionID}{Location}      = $Location;
    $Sessions{$SessionID}{AltLocation}   = $AltLocation;
    $Sessions{$SessionID}{Title}         = $Title;
    $Sessions{$SessionID}{Description}   = $Description;
    $Sessions{$SessionID}{TimeStamp}     = $TimeStamp;
    @{$Sessions{$SessionID}{Moderators}} = ();
    @{$Sessions{$SessionID}{Topics}}     = ();
  }
  
  my $ModeratorSelect = $dbh -> prepare("select AuthorID from Moderator where SessionID=?");
  $ModeratorSelect -> execute($SessionID);
  while (my ($AuthorID) = $ModeratorSelect -> fetchrow_array()) {
    push @{$Sessions{$SessionID}{Moderators}},$AuthorID;
  }

  my $TopicSelect = $dbh -> prepare("select TopicID from EventTopic where SessionID=?");
  $TopicSelect -> execute($SessionID);
  while (my ($TopicID) = $TopicSelect -> fetchrow_array()) {
    push @{$Sessions{$SessionID}{Topics}},$TopicID;
  }

  return $SessionID;  
}

sub FetchSessionSeparatorsByConferenceID ($) {
  my ($ConferenceID) = @_;
  my $SessionSeparatorID;
  my @SessionSeparatorIDs = ();
  my $SessionSeparatorList   = $dbh -> prepare(
    "select SessionSeparatorID from SessionSeparator where ConferenceID=?");
  $SessionSeparatorList -> execute($ConferenceID);
  $SessionSeparatorList -> bind_columns(undef, \($SessionSeparatorID));
  while ($SessionSeparatorList -> fetch) {
    $SessionSeparatorID = &FetchSessionSeparatorByID($SessionSeparatorID);
    push @SessionSeparatorIDs,$SessionSeparatorID;
  }
  return @SessionSeparatorIDs; 
}

sub FetchSessionSeparatorByID ($) {
  my ($SessionSeparatorID) = @_;
  my ($ConferenceID,$StartTime,$Location,$Title,$Description,$TimeStamp); 
  my $SessionSeparatorFetch = $dbh -> prepare(
    "select ConferenceID,StartTime,Location,Title,Description,TimeStamp ".
    "from SessionSeparator where SessionSeparatorID=?");
  if ($SessionSeparators{$SessionSeparatorID}{TimeStamp}) {
    return $SessionSeparatorID;
  }
  $SessionSeparatorFetch -> execute($SessionSeparatorID);
  ($ConferenceID,$StartTime,$Location,$Title,$Description,$TimeStamp) = $SessionSeparatorFetch -> fetchrow_array; 
  if ($TimeStamp) {
    $SessionSeparators{$SessionSeparatorID}{ConferenceID} = $ConferenceID;
    $SessionSeparators{$SessionSeparatorID}{StartTime}    = $StartTime;
    $SessionSeparators{$SessionSeparatorID}{Location}     = $Location;
    $SessionSeparators{$SessionSeparatorID}{Title}        = $Title;
    $SessionSeparators{$SessionSeparatorID}{Description}  = $Description;
    $SessionSeparators{$SessionSeparatorID}{TimeStamp}    = $TimeStamp;
  }
  return $SessionSeparatorID;  
}

sub FetchMeetingOrdersByConferenceID {
  my ($ConferenceID) = @_;
  my ($SessionSeparatorID,$SessionID,$MeetingOrderID,$SessionOrder);
  my @MeetingOrderIDs = ();
  my $SessionOrderList   = $dbh -> prepare(
    "select MeetingOrder.MeetingOrderID,MeetingOrder.SessionSeparatorID,MeetingOrder.SessionID,MeetingOrder.SessionOrder ".
    "from MeetingOrder,Session ".
    "where MeetingOrder.SessionID=Session.SessionID and Session.ConferenceID=?");
  my $SessionSeparatorOrderList   = $dbh -> prepare(
    "select MeetingOrder.MeetingOrderID,MeetingOrder.SessionSeparatorID,MeetingOrder.SessionID,MeetingOrder.SessionOrder ".
    "from MeetingOrder,SessionSeparator ".
    "where MeetingOrder.SessionSeparatorID=SessionSeparator.SessionSeparatorID and SessionSeparator.ConferenceID=?");

  $SessionOrderList -> execute($ConferenceID);
  $SessionOrderList -> bind_columns(undef, \($MeetingOrderID,$SessionSeparatorID,$SessionID,$SessionOrder));
  while ($SessionOrderList -> fetch) {
    $MeetingOrders{$MeetingOrderID}{SessionSeparatorID} = $SessionSeparatorID;
    $MeetingOrders{$MeetingOrderID}{SessionID}          = $SessionID;
    $MeetingOrders{$MeetingOrderID}{SessionOrder}       = $SessionOrder;
    push @MeetingOrderIDs,$MeetingOrderID;
  }
  $SessionSeparatorOrderList -> execute($ConferenceID);
  $SessionSeparatorOrderList -> bind_columns(undef, \($MeetingOrderID,$SessionSeparatorID,$SessionID,$SessionOrder));
  while ($SessionSeparatorOrderList -> fetch) {
    $MeetingOrders{$MeetingOrderID}{SessionSeparatorID} = $SessionSeparatorID;
    $MeetingOrders{$MeetingOrderID}{SessionID}          = $SessionID;
    $MeetingOrders{$MeetingOrderID}{SessionOrder}       = $SessionOrder;
    push @MeetingOrderIDs,$MeetingOrderID;
  }
  return @MeetingOrderIDs; 
}

sub InsertEvent (%) {
  my ($ArgRef) = @_;
  
  my $EventGroupID     = exists $ArgRef->{-eventgroupid}     ?   $ArgRef->{-eventgroupid}     : 0;
  my $ShortDescription = exists $ArgRef->{-shortdescription} ?   $ArgRef->{-shortdescription} : "";
  my $LongDescription  = exists $ArgRef->{-longdescription}  ?   $ArgRef->{-longdescription}  : "";
  my $StartDate        = exists $ArgRef->{-startdate}        ?   $ArgRef->{-startdate}        : SQLNow();
  my $EndDate          = exists $ArgRef->{-enddate}          ?   $ArgRef->{-enddate}          : SQLNow();
  my $Location         = exists $ArgRef->{-location}         ?   $ArgRef->{-location}         : "";
  my $AltLocation      = exists $ArgRef->{-altlocation}      ?   $ArgRef->{-altlocation}      : "";
  my $URL              = exists $ArgRef->{-url}              ?   $ArgRef->{-url}              : "";
  my $ShowAllTalks     = exists $ArgRef->{-showalltalks}     ?   $ArgRef->{-showalltalks}     : 0;
  my $Preample         = exists $ArgRef->{-preample}         ?   $ArgRef->{-preample}         : "";
  my $Epilogue         = exists $ArgRef->{-epilogue}         ?   $ArgRef->{-epilogue}         : "";
  my @TopicIDs         = exists $ArgRef->{-topicids}         ? @{$ArgRef->{-topicids}}        : ();
  my @ModeratorIDs     = exists $ArgRef->{-moderatorids}     ? @{$ArgRef->{-moderatorids}}    : ();
  my @ViewGroupIDs     = exists $ArgRef->{-viewgroupids}     ? @{$ArgRef->{-viewgroupids}}    : ();
  my @ModifyGroupIDs   = exists $ArgRef->{-modifygroupids}   ? @{$ArgRef->{-viewgroupids}}    : ();

  require "SQLUtilities.pm";
  require "MeetingSecuritySQL.pm";

  my $Insert = $dbh->prepare(
     "insert into Conference ".
     "(ConferenceID, EventGroupID, Location, AltLocation, URL, ShowAllTalks, StartDate, EndDate, ".
     " Preamble, Epilogue, Title, LongDescription) ". 
     "values (0,?,?,?,?,?,?,?,?,?,?,?)");
  $Insert -> execute($EventGroupID,$Location,$AltLocation,$URL,$ShowAllTalks,
                     $StartDate,$EndDate,$Preamble,
                     $Epilogue,$ShortDescription,$LongDescription); 
  $EventID = $Insert -> {mysql_insertid}; 
  
  MeetingSecurityUpdate(-mode => 'access', -conferenceid => $EventID, -groupids => \@ViewGroupIDs);
  MeetingSecurityUpdate(-mode => 'modify', -conferenceid => $EventID, -groupids => \@ModifyGroupIDs);
  MeetingTopicUpdate({     -type => 'Event', -id => $EventID, -topicids  => \@TopicIDs });
  MeetingModeratorUpdate({ -type => 'Event', -id => $EventID, -authorids => \@ModeratorIDs });

  return $EventID;  
}

sub UpdateEvent (%) {
  my ($ArgRef) = @_;
  
  my $EventID          = exists $ArgRef->{-eventid}          ?   $ArgRef->{-eventid}          : 0;
  my $EventGroupID     = exists $ArgRef->{-eventgroupid}     ?   $ArgRef->{-eventgroupid}     : 0;
  my $ShortDescription = exists $ArgRef->{-shortdescription} ?   $ArgRef->{-shortdescription} : "";
  my $LongDescription  = exists $ArgRef->{-longdescription}  ?   $ArgRef->{-longdescription}  : "";
  my $StartDate        = exists $ArgRef->{-startdate}        ?   $ArgRef->{-startdate}        : SQLNow();
  my $EndDate          = exists $ArgRef->{-enddate}          ?   $ArgRef->{-enddate}          : SQLNow();
  my $Location         = exists $ArgRef->{-location}         ?   $ArgRef->{-location}         : "";
  my $AltLocation      = exists $ArgRef->{-altlocation}      ?   $ArgRef->{-altlocation}      : "";
  my $URL              = exists $ArgRef->{-url}              ?   $ArgRef->{-url}              : "";
  my $ShowAllTalks     = exists $ArgRef->{-showalltalks}     ?   $ArgRef->{-showalltalks}     : 0;
  my $Preample         = exists $ArgRef->{-preample}         ?   $ArgRef->{-preample}         : "";
  my $Epilogue         = exists $ArgRef->{-epilogue}         ?   $ArgRef->{-epilogue}         : "";
  my @TopicIDs         = exists $ArgRef->{-topicids}         ? @{$ArgRef->{-topicids}}        : ();
  my @ModeratorIDs     = exists $ArgRef->{-moderatorids}     ? @{$ArgRef->{-moderatorids}}    : ();
  my @ViewGroupIDs     = exists $ArgRef->{-viewgroupids}     ? @{$ArgRef->{-viewgroupids}}    : ();
  my @ModifyGroupIDs   = exists $ArgRef->{-modifygroupids}   ? @{$ArgRef->{-viewgroupids}}    : ();

  require "SQLUtilities.pm";
  require "MeetingSecuritySQL.pm";

  my $Update = $dbh->prepare(
   "update Conference set ".
     "EventGroupID=?, Location=?, AltLocation=?, URL=?, ShowAllTalks=?, StartDate=?, EndDate=?, ".
     "Preamble=?, Epilogue=?, Title=?, LongDescription=? ". 
   "where ConferenceID=?");

  $Update -> execute($EventGroupID,$Location,$AltLocation,$URL,$ShowAllTalks,
                     $StartDate,$EndDate,$Preamble,$Epilogue,
                     $ShortDescription,$LongDescription,$EventID); 
  MeetingSecurityUpdate(-mode => 'access', -conferenceid => $EventID, -groupids => \@ViewGroupIDs);
  MeetingSecurityUpdate(-mode => 'modify', -conferenceid => $EventID, -groupids => \@ModifyGroupIDs);
  MeetingTopicUpdate({     -type => 'Event', -id => $EventID, -topicids  => \@TopicIDs });
  MeetingModeratorUpdate({ -type => 'Event', -id => $EventID, -authorids => \@ModeratorIDs });
  return;
}

sub InsertSession (%) {
  my ($ArgRef) = @_;
  
  my $EventID      = exists $ArgRef->{-eventid}      ?   $ArgRef->{-eventid}       : 0;
  my $Date         = exists $ArgRef->{-date}         ?   $ArgRef->{-date}          : "";
  my $Title        = exists $ArgRef->{-title}        ?   $ArgRef->{-title}         : "";
  my $Description  = exists $ArgRef->{-description}  ?   $ArgRef->{-description}   : "";
  my $Location     = exists $ArgRef->{-location}     ?   $ArgRef->{-location}      : "";
  my $AltLocation  = exists $ArgRef->{-altlocation}  ?   $ArgRef->{-altlocation}   : "";
  my $ShowAllTalks = exists $ArgRef->{-showalltalks} ?   $ArgRef->{-showalltalks}  : $FALSE;
  my @TopicIDs     = exists $ArgRef->{-topicids}     ? @{$ArgRef->{-topicids}}     : ();
  my @ModeratorIDs = exists $ArgRef->{-moderatorids} ? @{$ArgRef->{-moderatorids}} : ();

  my $Insert = $dbh -> prepare(
   "insert into Session ".
          "(SessionID, ConferenceID, StartTime, Location, AltLocation, Title, Description, ShowAllTalks) ". 
   "values (0,?,?,?,?,?,?,?)");
  $Insert -> execute($EventID,$Date,$Location,$AltLocation,$Title,$Description,$ShowAllTalks);
  $SessionID = $Insert -> {mysql_insertid}; 
  MeetingTopicUpdate({     -type => 'Session', -id => $SessionID, -topicids  => \@TopicIDs });
  MeetingModeratorUpdate({ -type => 'Session', -id => $SessionID, -authorids => \@ModeratorIDs });

  return $SessionID;
}  

sub UpdateSession (%) {
  my ($ArgRef) = @_;
  
  my $SessionID    = exists $ArgRef->{-sessionid}    ?   $ArgRef->{-sessionid}     : 0;
  my $Date         = exists $ArgRef->{-date}         ?   $ArgRef->{-date}          : "";
  my $Title        = exists $ArgRef->{-title}        ?   $ArgRef->{-title}         : "";
  my $Description  = exists $ArgRef->{-description}  ?   $ArgRef->{-description}   : "";
  my $Location     = exists $ArgRef->{-location}     ?   $ArgRef->{-location}      : "";
  my $AltLocation  = exists $ArgRef->{-altlocation}  ?   $ArgRef->{-altlocation}   : "";
  my $ShowAllTalks = exists $ArgRef->{-showalltalks} ?   $ArgRef->{-showalltalks}  : $FALSE;
  my @TopicIDs     = exists $ArgRef->{-topicids}     ? @{$ArgRef->{-topicids}}     : ();
  my @ModeratorIDs = exists $ArgRef->{-moderatorids} ? @{$ArgRef->{-moderatorids}} : ();

  my $Update = $dbh -> prepare("update Session set ".
               "Title=?, Description=?, Location=?, AltLocation=?, StartTime=?, ShowAllTalks=? ". 
               "where SessionID=?");
               
  if ($SessionID) {
    $Update -> execute($Title,$Description,$Location,$AltLocation,$Date,$ShowAllTalks,$SessionID);
    MeetingTopicUpdate({     -type => 'Session', -id => $SessionID, -topicids  => \@TopicIDs });
    MeetingModeratorUpdate({ -type => 'Session', -id => $SessionID, -authorids => \@ModeratorIDs });
  }
}

sub DeleteEventGroup (%) {
  my %Params = @_;
  
  my $EventGroupID = $Params{-eventgroupid} || 0;
  my $Force        = $Params{-force}   || 0;
  
  unless ($EventGroupID) {
    push @WarnStack,"No Event Group specified";
    return 0;
  }

  my $Status = &FetchEventGroup($EventGroupID);

  unless ($Status) {
    push @WarnStack,"Event Group does not exist";
    return 0;
  }

  my @EventIDs = &FetchEventsByGroup($EventGroupID);
  if (@EventIDs && !$Force) {
    push @WarnStack,"Cannot delete an event group with events. Use force option if you are sure.";
    return 0;
  }
  
  foreach my $EventID (@EventIDs) {
    &DeleteEvent(-eventid => $EventID, -force => $Force);
  }
    
  my $Delete = $dbh -> prepare("delete from EventGroup where EventGroupID=?");
  $Delete -> execute($EventGroupID);
  push @ActionStack,"Event group <strong>$EventGroups{$EventGroupID}{LongDescription}</strong> deleted";

  return 1;    
}

sub DeleteEvent (%) {
  require "RevisionSQL.pm";

  my %Params = @_;
  
  my $EventID = $Params{-eventid} || 0;
  my $Force   = $Params{-force}   || 0;
  
  unless ($EventID) {
    push @WarnStack,"No Event specified";
    return 0;
  }
  
  my $Status = FetchConferenceByConferenceID($EventID);
  unless ($Status) {
    push @WarnStack,"Event does not exist";
    return 0;
  }

  my @SeparatorIDs = FetchSessionSeparatorsByConferenceID($EventID);
  my @SessionIDs   = FetchSessionsByConferenceID($EventID);
  my @DocRevIDs    = FetchRevisionsByEventID($EventID);

  if ((@SeparatorIDs || @SessionIDs) && !$Force) {
    push @WarnStack,"Cannot delete event with sessions, use force option.";
    return 0;
  }
  if (@DocRevIDs && !$Force) {
    push @WarnStack,"Cannot delete event with associated documents, use force option.";
    return 0;
  }
  
  foreach my $SessionID (@SessionIDs) {
    DeleteSession($SessionID);
  }   
  foreach my $SeparatorID (@SeparatorIDs) {
    DeleteSessionSeparator($EventID);
  }   
  
  my $Delete = $dbh -> prepare("delete from Conference where ConferenceID=?");
  my $DeleteTopic = $dbh -> prepare("delete from Moderator where EventID=?");
  my $DeleteModerator = $dbh -> prepare("delete from EventTopic where EventID=?");
  $Delete          -> execute($EventID);
  $DeleteTopic     -> execute($EventID);
  $DeleteModerator -> execute($EventID);
  push @ActionStack,"Event <strong>$Conferences{$EventID}{Title}</strong> deleted";
  if (@DocRevIDs) {
    my $Delete = $dbh -> prepare("delete from RevisionEvent where ConferenceID=?");
    $Delete -> execute($EventID);
    push @ActionStack,"Document/Event associations deleted";
  }
  return 1;
}    
 
sub DeleteSession ($) {
  my ($SessionID) = @_;
   
  require "TalkSQL.pm";
          
  my $SessionDelete      = $dbh -> prepare("delete from Session where SessionID=?");
  my $SessionTalkList    = $dbh -> prepare("select SessionTalkID from SessionTalk where SessionID=?");
  my $TalkSeparatorList  = $dbh -> prepare("select TalkSeparatorID from TalkSeparator where SessionID=?");
  my $MeetingOrderDelete = $dbh -> prepare("delete from MeetingOrder where SessionID=?");
  my $DeleteTopic        = $dbh -> prepare("delete from Moderator where SessionID=?");
  my $DeleteModerator    = $dbh -> prepare("delete from EventTopic where SessionID=?");
 
  $SessionDelete   -> execute($SessionID);
  $DeleteTopic     -> execute($SessionID);
  $DeleteModerator -> execute($SessionID);

  my $SessionTalkID;
  $SessionTalkList -> execute($SessionID);    
  $SessionTalkList -> bind_columns(undef, \($SessionTalkID));
  while ($SessionTalkList -> fetch) {
    DeleteSessionTalk($SessionTalkID);
  }

  my $TalkSeparatorID;
  $TalkSeparatorList -> execute($SessionID);
  $TalkSeparatorList -> bind_columns(undef, \($TalkSeparatorID));
  while ($TalkSeparatorList -> fetch) {
    DeleteTalkSeparator($TalkSeparatorID);
  }

  $MeetingOrderDelete -> execute($SessionID);
  push @ActionStack,"Session and associated agenda entries deleted. (Documents not deleted.)";
}

sub DeleteSessionSeparator ($) {
  my ($SessionSeparatorID) = @_;
    
  my $SessionSeparatorDelete = $dbh -> prepare("delete from SessionSeparator where SessionSeparatorID=?");
  my $MeetingOrderDelete     = $dbh -> prepare("delete from MeetingOrder where SessionSeparatorID=?");
  
  $SessionSeparatorDelete -> execute($SessionSeparatorID);
  $MeetingOrderDelete     -> execute($SessionSeparatorID);
  push @ActionStack,"Session separator deleted";
}

sub InsertRevisionEvents (%) {
  my %Params = @_;
  
  my $DocRevID =   $Params{-docrevid} || "";   
  my @EventIDs = @{$Params{-eventids}};

  my $Count = 0;

  my $Insert = $dbh -> prepare("insert into RevisionEvent (RevEventID, DocRevID, ConferenceID) values (0,?,?)");
                                 
  foreach my $EventID (@EventIDs) {
    if (int $EventID) {
      $Insert -> execute($DocRevID,$EventID);
      ++$Count;
    }
  }  
      
  return $Count;
}

sub InsertMeetingOrder {
  my %Params = @_;
  my $Order              = $Params{-session}            || 1;
  my $SessionID          = $Params{-sessionid}          || 0;
  my $SessionSeparatorID = $Params{-sessionseparatorid} || 0;
  unless ($SessionID || $SessionSeparatorID) { 
    return;
  }  
  my $Insert = $dbh -> prepare(
   "insert into MeetingOrder ".
   "(MeetingOrderID, SessionOrder, SessionID, SessionSeparatorID) ". 
   "values (0,?,?,?)");
  $Insert -> execute($Order,$SessionID,$SessionSeparatorID);
}

sub MeetingTopicUpdate {  
  my ($ArgRef) = @_;
  my @TopicIDs = exists $ArgRef->{-topicids} ? @{$ArgRef->{-topicids}} : ();
  my $Type     = exists $ArgRef->{-type}     ?   $ArgRef->{-type}      : "";
  my $ID       = exists $ArgRef->{-id}       ?   $ArgRef->{-id}        : 0;
  
  my $Delete;
  my $Insert;
     
  if ($Type eq "Event") {  
    $Delete = $dbh -> prepare("delete from EventTopic where EventID=?");
    $Insert = $dbh -> prepare("insert into EventTopic (EventTopicID,EventID,TopicID) values (0,?,?)");
  } elsif ($Type eq "Session") {
    $Delete = $dbh -> prepare("delete from EventTopic where SessionID=?");
    $Insert = $dbh -> prepare("insert into EventTopic (EventTopicID,SessionID,TopicID) values (0,?,?)");
  } else {
    return undef;
  }
  
  unless ($ID) {
    return undef;
  }
    
# Delete old settings, insert new ones  
  my $Count = 0;
  $Delete -> execute($ID);
  foreach my $TopicID (@TopicIDs) {
    $Insert -> execute($ID,$TopicID);
    ++$Count;
  }
  
  return $Count;
}

sub MeetingModeratorUpdate {  
  my ($ArgRef) = @_;
  my @AuthorIDs = exists $ArgRef->{-authorids} ? @{$ArgRef->{-authorids}} : ();
  my $Type      = exists $ArgRef->{-type}      ?   $ArgRef->{-type}       : "";
  my $ID        = exists $ArgRef->{-id}        ?   $ArgRef->{-id}         : 0;

  my $Delete;
  my $Insert;
     
  if ($Type eq "Event") {  
    $Delete = $dbh -> prepare("delete from Moderator where EventID=?");
    $Insert = $dbh -> prepare("insert into Moderator (ModeratorID,EventID,AuthorID) values (0,?,?)");
  } elsif ($Type eq "Session") {
    $Delete = $dbh -> prepare("delete from Moderator where SessionID=?");
    $Insert = $dbh -> prepare("insert into Moderator (ModeratorID,SessionID,AuthorID) values (0,?,?)");
  } else {
    return undef;
  }
  
  unless ($ID) {
    return undef;
  }
    
# Delete old settings, insert new ones  
  my $Count = 0;
  $Delete -> execute($ID);
  foreach my $AuthorID (@AuthorIDs) {
    $Insert -> execute($ID,$AuthorID);
    ++$Count;
  }
  
  return $Count;
}

1;
