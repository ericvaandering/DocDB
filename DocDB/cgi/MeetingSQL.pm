#
#        Name: MeetingSQL.pm 
# Description: Routines to access SQL tables related to conferences and meetings 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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

sub FetchConferenceByTopicID { # Fetches a conference by MinorTopicID: Remove v7
  my ($minorTopicID) = @_;
  my ($ConferenceID,$MinorTopicID);
  
  my $ConferenceFetch   = $dbh -> prepare(
    "select ConferenceID,MinorTopicID from Conference where MinorTopicID=?");
  $ConferenceFetch -> execute($minorTopicID);
  ($ConferenceID,$MinorTopicID) = $ConferenceFetch -> fetchrow_array;
 
  $ConferenceID = &FetchConferenceByConferenceID($ConferenceID);

  return $ConferenceID;
}

sub GetEventsByDate (%) {
  require "SQLUtilities.pm";
  require "Utilities.pm";
  require "MeetingSecurityUtilities.pm";

  my %Params = @_;
  
  my $From = $Params{-from} || "";
  my $To   = $Params{-to}   || "";
  my $On   = $Params{-on}   || &SQLNow(-dateonly => $TRUE);
  
  my $List;
  if ($From && $To) { # Starts or ends in or surrounds window
    $List = $dbh->prepare("select ConferenceID from Conference where (StartDate>=? and StartDate<=?) "."
                           or (EndDate>=? and EndDate<=?) or (StartDate<? and EndDate>?)");
    $List -> execute($From,$To,$From,$To,$From,$To);
  } else { 
    $List = $dbh->prepare("select ConferenceID from Conference where StartDate<=? and EndDate>=?");
    $List -> execute($On,$On);
  }
  
  my $EventID;
  my @EventIDs;
  $List -> bind_columns(undef, \($EventID));
  while ($List -> fetch) {
    if (&FetchConferenceByConferenceID($EventID)) {
      if (&CanAccessMeeting($EventID)) {
        push @EventIDs,$EventID;
      }  
    }  
  }
  @EventIDs = &Unique(@EventIDs);
  return @EventIDs;
}

sub GetRevisionEvents ($) { # Get the events associated with a revision
  my ($DocRevID) = @_;
  
  require "Utilities.pm";
  
  my @ConferenceIDs = ();
  my $ConferenceID;
  my $EventList = $dbh->prepare("select ConferenceID from RevisionEvent where DocRevID=?");
  $EventList -> execute($DocRevID);
  $EventList -> bind_columns(undef, \($ConferenceID));
  while ($EventList -> fetch) {
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

sub FetchEventGroup ($) {
  my ($EventGroupID) = @_;
  unless ($EventGroupID) {
    return 0;
  }
    
  my $Fetch = $dbh->prepare("select ShortDescription,LongDescription,TimeStamp from EventGroup where EventGroupID=?");
  $Fetch -> execute($EventGroupID);
 
  ($ShortDescription,$LongDescription,$TimeStamp) = $Fetch -> fetchrow_array;
  if ($TimeStamp) {
    $EventGroups{$EventGroupID}{ShortDescription} = $ShortDescription;
    $EventGroups{$EventGroupID}{LongDescription}  = $LongDescription; 
    $EventGroups{$EventGroupID}{TimeStamp}        = $TimeStamp; 
  } 
  return $EventGroupID;  
} 

sub FetchConferenceByConferenceID { # Fetches a conference by ConferenceID
  my ($conferenceID) = @_;
  
  require "TopicSQL.pm";
  
  if ($Conference{$conferenceID}{MINOR}) { # We already have this one
    return $conferenceID;
  }
  
  my ($ConferenceID,$EventGroupID,$MinorTopicID,$Location,$URL,$Title,$LongDescription,$Preamble,
      $Epilogue,$StartDate,$EndDate,$ShowAllTalks,$TimeStamp);

  my $ConferenceFetch   = $dbh -> prepare(
    "select ConferenceID,EventGroupID,MinorTopicID,Location,URL,Title,LongDescription,Preamble,Epilogue,StartDate,EndDate,ShowAllTalks,TimeStamp ".
    "from Conference ".
    "where ConferenceID=?");
  $ConferenceFetch -> execute($conferenceID);
 
  ($ConferenceID,$EventGroupID,$MinorTopicID,$Location,$URL,$Title,
   $LongDescription,$Preamble,$Epilogue,$StartDate,$EndDate,$ShowAllTalks,
   $TimeStamp) = $ConferenceFetch -> fetchrow_array;
  if ($ConferenceID) {
    $Conferences{$ConferenceID}{Minor}           = $MinorTopicID; # Remove v7 (all references)
    $Conferences{$ConferenceID}{EventGroupID}    = $EventGroupID;
    $Conferences{$ConferenceID}{Location}        = $Location;
    $Conferences{$ConferenceID}{URL}             = $URL;
    $Conferences{$ConferenceID}{Title}           = $Title;
    $Conferences{$ConferenceID}{Preamble}        = $Preamble;
    $Conferences{$ConferenceID}{LongDescription} = $LongDescription;
    $Conferences{$ConferenceID}{Epilogue}        = $Epilogue;
    $Conferences{$ConferenceID}{StartDate}       = $StartDate;
    $Conferences{$ConferenceID}{EndDate}         = $EndDate;
    $Conferences{$ConferenceID}{ShowAllTalks}    = $ShowAllTalks;
    $Conferences{$ConferenceID}{TimeStamp}       = $TimeStamp;
    	
    &FetchEventGroup($EventGroupID);
    $Conferences{$ConferenceID}{Full}  = $EventGroups{$EventGroupID}{LongDescription}.":".$Title;
    $ConferenceMinor{$MinorTopicID} = $ConferenceID; #  Remove v7 Used to index conferences with MinorTopic
    &FetchMinorTopic($MinorTopicID);#  Remove v7 
  }

  return $ConferenceID;
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
    "select ConferenceID,StartTime,Location,Title,Description,TimeStamp ".
    "from Session where SessionID=?");
  if ($Sessions{$SessionID}{TimeStamp}) {
    return $SessionID;
  }
  $SessionFetch -> execute($SessionID);
  ($ConferenceID,$StartTime,$Location,$Title,$Description,$TimeStamp) = $SessionFetch -> fetchrow_array; 
  if ($TimeStamp) {
    $Sessions{$SessionID}{ConferenceID} = $ConferenceID;
    $Sessions{$SessionID}{StartTime}    = $StartTime;
    $Sessions{$SessionID}{Location}     = $Location;
    $Sessions{$SessionID}{Title}        = $Title;
    $Sessions{$SessionID}{Description}  = $Description;
    $Sessions{$SessionID}{TimeStamp}    = $TimeStamp;
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
  require "SQLUtilities.pm";

  my (%Params) = @_;
  
  my $EventGroupID     = $Params{-eventgroupid}     || 0;
  my $ShortDescription = $Params{-shortdescription} || "";
  my $LongDescription  = $Params{-longdescription}  || "";
  my $StartDate        = $Params{-startdate}        || &SQLNow();
  my $EndDate          = $Params{-enddate}          || &SQLNow();
  my $Location         = $Params{-location}         || "";
  my $URL              = $Params{-url}              || "";
  my $ShowAllTalks     = $Params{-showalltalks}     || 0;
  my $Preample         = $Params{-preample}         || "";
  my $Epilogue         = $Params{-epilogue}         || "";

  my $Insert = $dbh->prepare(
     "insert into Conference ".
     "(ConferenceID, EventGroupID, Location, URL, ShowAllTalks, StartDate, EndDate, ".
     " Preamble, Epilogue, Title, LongDescription) ". 
     "values (0,?,?,?,?,?,?,?,?,?,?)");
  $Insert -> execute($EventGroupID,$Location,$URL,$ShowAllTalks,
                     $StartDate,$EndDate,$Preamble,
                     $Epilogue,$ShortDescription,$LongDescription); 
  $EventID = $Insert -> {mysql_insertid}; 
  
  return $EventID;  
}

sub UpdateEvent (%) {
  my (%Params) = @_;

  my $EventID          = $Params{-eventid}          || 0;
  my $EventGroupID     = $Params{-eventgroupid}     || 0;
  my $ShortDescription = $Params{-shortdescription} || "";
  my $LongDescription  = $Params{-longdescription}  || "";
  my $StartDate        = $Params{-startdate}        || &SQLNow();
  my $EndDate          = $Params{-enddate}          || &SQLNow();
  my $Location         = $Params{-location}         || "";
  my $URL              = $Params{-url}              || "";
  my $ShowAllTalks     = $Params{-showalltalks}     || 0;
  my $Preample         = $Params{-preample}         || "";
  my $Epilogue         = $Params{-epilogue}         || "";


  my $Update = $dbh->prepare(
   "update Conference set ".
     "EventGroupID=?, Location=?, URL=?, ShowAllTalks=?, StartDate=?, EndDate=?, ".
     "Preamble=?, Epilogue=?, Title=?, LongDescription=? ". 
   "where ConferenceID=?");
  $Update -> execute($EventGroupID,$Location,$URL,$ShowAllTalks,
                     $StartDate,$EndDate,$Preamble,$Epilogue,
                     $ShortDescription,$LongDescription,$ConferenceID); 
  return;
}

sub InsertSession (%) {
  my (%Params) = @_;
  
  my $EventID     = $Params{-eventid}     || 0;
  my $Date        = $Params{-date}        || "";
  my $Title       = $Params{-title}       || "";
  my $Description = $Params{-description} || "";
  my $Location    = $Params{-location}    || "";

  my $Insert = $dbh -> prepare(
   "insert into Session ".
          "(SessionID, ConferenceID, StartTime, Location, Title, Description) ". 
   "values (0,?,?,?,?,?)");
  $Insert          -> execute($EventID,$Date,$Location,$Title,$Description);
  $SessionID = $Insert -> {mysql_insertid}; 

  return $SessionID;
}  

sub UpdateSession (%) {
  my (%Params) = @_;
  
  my $SessionID   = $Params{-sessionid}   || 0;
  my $Date        = $Params{-date}        || "";
  my $Title       = $Params{-title}       || "";
  my $Description = $Params{-description} || "";
  my $Location    = $Params{-location}    || "";

  my $Update = $dbh -> prepare("update Session set ".
               "Title=?, Description=?, Location=?, StartTime=? ". 
               "where SessionID=?");
               
  if ($SessionID) {
    $Update -> execute($Title,$Description,$Location,$Date,$SessionID);
  }
  
}

sub DeleteSession ($) {
  my ($SessionID) = @_;
   
  require "TalkSQL.pm";
          
  my $SessionDelete      = $dbh -> prepare("delete from Session where SessionID=?");
  my $SessionTalkList    = $dbh -> prepare("select SessionTalkID from SessionTalk where SessionID=?");
  my $TalkSeparatorList  = $dbh -> prepare("select TalkSeparatorID from TalkSeparator where SessionID=?");
  my $MeetingOrderDelete = $dbh -> prepare("delete from MeetingOrder where SessionID=?");
 
  $SessionDelete   -> execute($SessionID);
  
  my $SessionTalkID;
  $SessionTalkList -> execute($SessionID);    
  $SessionTalkList -> bind_columns(undef, \($SessionTalkID));
  while ($SessionTalkList -> fetch) {
    &DeleteSessionTalk($SessionTalkID);
  }

  my $TalkSeparatorID;
  $TalkSeparatorList -> execute($SessionID);
  $TalkSeparatorList -> bind_columns(undef, \($TalkSeparatorID));
  while ($TalkSeparatorList -> fetch) {
    &DeleteTalkSeparator($TalkSeparatorID);
  }

  $MeetingOrderDelete -> execute($SessionID);
}

sub DeleteSessionSeparator ($) {
  my ($SessionSeparatorID) = @_;
    
  my $SessionSeparatorDelete = $dbh -> prepare("delete from SessionSeparator where SessionSeparatorID=?");
  my $MeetingOrderDelete     = $dbh -> prepare("delete from MeetingOrder where SessionSeparatorID=?");
  
  $SessionSeparatorDelete -> execute($SessionSeparatorID);
  $MeetingOrderDelete     -> execute($SessionSeparatorID);
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

1;
