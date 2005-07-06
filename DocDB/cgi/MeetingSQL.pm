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
  return @ConferenceIDs;
}

sub FetchConferenceByTopicID { # Fetches a conference by MinorTopicID
  my ($minorTopicID) = @_;
  my ($ConferenceID,$MinorTopicID);
  
  my $ConferenceFetch   = $dbh -> prepare(
    "select ConferenceID,MinorTopicID from Conference where MinorTopicID=?");
  $ConferenceFetch -> execute($minorTopicID);
  ($ConferenceID,$MinorTopicID) = $ConferenceFetch -> fetchrow_array;
 
  $ConferenceID = &FetchConferenceByConferenceID($ConferenceID);

  return $ConferenceID;
}

sub FetchConferenceByConferenceID { # Fetches a conference by ConferenceID
  my ($conferenceID) = @_;
  
  require "TopicSQL.pm";
  
  if ($Conference{$conferenceID}{MINOR}) { # We already have this one
    return $conferenceID;
  }
  
  my ($ConferenceID,$MinorTopicID,$Location,$URL,$Title,$Preamble,
      $Epilogue,$StartDate,$EndDate,$ShowAllTalks,$TimeStamp);

  my $ConferenceFetch   = $dbh -> prepare(
    "select ConferenceID,MinorTopicID,Location,URL,Title,Preamble,Epilogue,StartDate,EndDate,ShowAllTalks,TimeStamp ".
    "from Conference ".
    "where ConferenceID=?");
  $ConferenceFetch -> execute($conferenceID);
 
($ConferenceID,$MinorTopicID,$Location,$URL,$Title,$Preamble,$Epilogue,$StartDate,$EndDate,$ShowAllTalks,$TimeStamp) 
    = $ConferenceFetch -> fetchrow_array;
  if ($ConferenceID) {
    $Conferences{$ConferenceID}{Minor}        = $MinorTopicID;
    $Conferences{$ConferenceID}{Location}     = $Location;
    $Conferences{$ConferenceID}{URL}          = $URL;
    $Conferences{$ConferenceID}{Title}        = $Title;
    $Conferences{$ConferenceID}{Preamble}     = $Preamble;
    $Conferences{$ConferenceID}{Epilogue}     = $Epilogue;
    $Conferences{$ConferenceID}{StartDate}    = $StartDate;
    $Conferences{$ConferenceID}{EndDate}      = $EndDate;
    $Conferences{$ConferenceID}{ShowAllTalks} = $ShowAllTalks;
    $Conferences{$ConferenceID}{TimeStamp}    = $TimeStamp;
    	
    $ConferenceMinor{$MinorTopicID} = $ConferenceID; # Used to index conferences with MinorTopic
    &FetchMinorTopic($MinorTopicID);
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

1;
