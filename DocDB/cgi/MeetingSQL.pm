#
#        Name: MiscSQL.pm 
# Description: Routines to access SQL tables related to conferences and meetings 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Have to re-do conferences, storing them by ConferenceID rather than topic ID. Probably 
# a translation hash between them and making one lookup a special case of the other 


sub GetConferences { # Probably redo this so it just gets all conferences, regardless
  %Conferences = ();
  my $MinorTopicID;
  foreach my $MajorID (@MeetingMajorIDs,@ConferenceMajorIDs) {
    my $MinorList   = $dbh -> prepare(
      "select MinorTopicID from MinorTopic where MajorTopicID=$MajorID");
    $MinorList -> execute();
    $MinorList -> bind_columns(undef, \($MinorTopicID));
    while ($MinorList -> fetch) {
      &FetchConferenceByTopicID($MinorTopicID);
    }
  }
}

sub FetchConferenceByTopicID { # Fetches a conference by MinorTopicID
  my ($minorTopicID) = @_;
  my ($ConferenceID,$MinorTopicID,$Location,$URL,$Title,$Preamble,$Epilogue,$StartDate,$EndDate,$TimeStamp);
  my $ConferenceFetch   = $dbh -> prepare(
    "select ConferenceID,MinorTopicID,Location,URL,Title,Preamble,Epilogue,StartDate,EndDate,TimeStamp ".
    "from Conference ".
    "where MinorTopicID=?");
  if ($Conference{$minorTopicID}{MINOR}) { # We already have this one
    return $Conference{$minorTopicID}{MINOR};
  }
  
  &FetchMinorTopic($minorTopicID);
  $ConferenceFetch -> execute($minorTopicID);
  ($ConferenceID,$MinorTopicID,$Location,$URL,$Title,$Preamble,$Epilogue,$StartDate,$EndDate,$TimeStamp) 
    = $ConferenceFetch -> fetchrow_array;
  $Conferences{$MinorTopicID}{MINOR}     = $MinorTopicID;
  $Conferences{$MinorTopicID}{Location}  = $Location;
  $Conferences{$MinorTopicID}{URL}       = $URL;
  $Conferences{$MinorTopicID}{Title}     = $Title;
  $Conferences{$MinorTopicID}{Preamble}  = $Preamble;
  $Conferences{$MinorTopicID}{Epilogue}  = $Epilogue;
  $Conferences{$MinorTopicID}{StartDate} = $StartDate;
  $Conferences{$MinorTopicID}{EndDate}   = $EndDate;
  $Conferences{$MinorTopicID}{TimeStamp} = $TimeStamp;

  $ConferenceForward{$ConferenceID}{Minor} = $MinorTopicID; # FIXME will go away when conferences index right	

  return $Conferences{$MinorTopicID}{MINOR};
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

sub FetchSessionByID ($) {
  my ($SessionID) = @_;
  my ($ConferenceID,$StartTime,$Title,$Description,$TimeStamp); 
  my $SessionFetch = $dbh -> prepare(
    "select ConferenceID,StartTime,Title,Description,TimeStamp ".
    "from Session where SessionID=?");
  if ($Sessions{$SessionID}{TimeStamp}) {
    return $SessionID;
  }
  $SessionFetch -> execute($SessionID);
  ($ConferenceID,$StartTime,$Title,$Description,$TimeStamp) = $SessionFetch -> fetchrow_array; 
  if ($TimeStamp) {
    $Sessions{$SessionID}{ConferenceID} = $ConferenceID;
    $Sessions{$SessionID}{StartTime}    = $StartTime;
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
  my ($ConferenceID,$StartTime,$Title,$Description,$TimeStamp); 
  my $SessionSeparatorFetch = $dbh -> prepare(
    "select ConferenceID,StartTime,Title,Description,TimeStamp ".
    "from SessionSeparator where SessionSeparatorID=?");
  if ($SessionSeparators{$SessionSeparatorID}{TimeStamp}) {
    return $SessionSeparatorID;
  }
  $SessionSeparatorFetch -> execute($SessionSeparatorID);
  ($ConferenceID,$StartTime,$Title,$Description,$TimeStamp) = $SessionSeparatorFetch -> fetchrow_array; 
  if ($TimeStamp) {
    $SessionSeparators{$SessionSeparatorID}{ConferenceID} = $ConferenceID;
    $SessionSeparators{$SessionSeparatorID}{StartTime}    = $StartTime;
    $SessionSeparators{$SessionSeparatorID}{Title}        = $Title;
    $SessionSeparators{$SessionSeparatorID}{Description}  = $Description;
    $SessionSeparators{$SessionSeparatorID}{TimeStamp}    = $TimeStamp;
  }
  return $SessionSeparatorID;  
}

sub FetchMeetingOrdersByConferenceID {
  my ($ConferenceID) = @_;
  my $SessionSeparatorID,$SessionID,$MeetingOrderID,$SessionOrder;
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

sub FetchSessionTalksBySessionID ($) {
  my ($SessionID) = @_;
  my $SessionTalkID;
  my @SessionTalkIDs = ();
  my $SessionTalkList   = $dbh -> prepare(
    "select SessionTalkID from SessionTalk where SessionID=?");
  $SessionTalkList -> execute($SessionID);
  $SessionTalkList -> bind_columns(undef, \($SessionTalkID));
  while ($SessionTalkList -> fetch) {
    $SessionTalkID = &FetchSessionTalkByID($SessionTalkID);
    push @SessionTalkIDs,$SessionTalkID;
  }
  return @SessionTalkIDs; 
}

sub FetchSessionTalkByID ($) {
  my ($SessionTalkID) = @_;
  my ($SessionID,$DocumentID,$Confirmed,$Time,$HintTitle,$Note,$TimeStamp); 
  my $SessionTalkFetch = $dbh -> prepare(
    "select SessionID,DocumentID,Confirmed,Time,HintTitle,Note,TimeStamp ".
    "from SessionTalk where SessionTalkID=?");
  if ($SessionTalks{$SessionTalkID}{TimeStamp}) {
    return $SessionTalkID;
  }
  $SessionTalkFetch -> execute($SessionITalkD);
  ($SessionID,$DocumentID,$Confirmed,$Time,$HintTitle,$Note,$TimeStamp) = $SessionTalkFetch -> fetchrow_array; 
  if ($TimeStamp) {
    $SessionTalks{$SessionTalkID}{SessionID}  = $SessionID;
    $SessionTalks{$SessionTalkID}{DocumentID} = $DocumentID;
    $SessionTalks{$SessionTalkID}{Confirmed}  = $Confirmed;
    $SessionTalks{$SessionTalkID}{Time}       = $Time;
    $SessionTalks{$SessionTalkID}{HintTitle}  = $HintTitle;
    $SessionTalks{$SessionTalkID}{Note}       = $Note;
    $SessionTalks{$SessionTalkID}{TimeStamp}  = $TimeStamp;
  }
  return $SessionTalkID;  
}

sub FetchTalkSeparatorsBySessionID ($) {
  my ($SessionID) = @_;
  my $TalkSeparatorID;
  my @TalkSeparatorIDs = ();
  my $TalkSeparatorList   = $dbh -> prepare(
    "select TalkSeparatorID from TalkSeparator where SessionID=?");
  $TalkSeparatorList -> execute($SessionID);
  $TalkSeparatorList -> bind_columns(undef, \($TalkSeparatorID));
  while ($TalkSeparatorList -> fetch) {
    $TalkSeparatorID = &FetchTalkSeparatorByID($TalkSeparatorID);
    push @TalkSeparatorIDs,$TalkSeparatorID;
  }
  return @TalkSeparatorIDs; 
}

sub FetchTalkSeparatorByID ($) {
  my ($TalkSeparatorID) = @_;
  my ($SessionID,$Time,$Title,$Description,$TimeStamp); 
  my $TalkSeparatorFetch = $dbh -> prepare(
    "select SessionID,Time,Title,Description,TimeStamp ".
    "from TalkSeparator where TalkSeparatorID=?");
  if ($TalkSeparators{$TalkSeparatorID}{TimeStamp}) {
    return $TalkSeparatorID;
  }
  $TalkSeparatorFetch -> execute($TalkSeparatorD);
  ($SessionID,$Time,$Title,$Description,$TimeStamp) = $TalkSeparatorFetch -> fetchrow_array; 
  if ($TimeStamp) {
    $TalkSeparators{$TalkSeparatorID}{SessionID}   = $SessionID;
    $TalkSeparators{$TalkSeparatorID}{Time}	   = $Time;
    $TalkSeparators{$TalkSeparatorID}{Title}       = $Title;
    $TalkSeparators{$TalkSeparatorID}{Description} = $Description;
    $TalkSeparators{$TalkSeparatorID}{TimeStamp}   = $TimeStamp;
  }
  return $TalkSeparatorID;  
}

sub FetchSessionOrdersBySessionID {
  my ($SessionID) = @_;
  my $TalkSeparatorID,$SessionTalkID,$SessionOrderID,$TalkOrder;
  my @SessionOrderIDs = ();
  my $SessionTalkOrderList   = $dbh -> prepare(
    "select SessionOrder.SessionOrderID,SessionOrder.TalkSeparatorID,SessionOrder.SessionTalkID,SessionOrder.TalkOrder ".
    "from SessionOrder,SessionTalk ".
    "where SessionOrder.SessionTalkID=SessionTalk.SessionTalkID and SessionTalk.SessionID=?");
  my $TalkSeparatorOrderList   = $dbh -> prepare(
    "select SessionOrder.SessionOrderID,SessionOrder.TalkSeparatorID,SessionOrder.SessionTalkID,SessionOrder.TalkOrder ".
    "from SessionOrder,TalkSeparator ".
    "where SessionOrder.TalkSeparatorID=TalkSeparator.TalkSeparatorID and TalkSeparator.SessionID=?");

  $SessionTalkOrderList -> execute($SessionID);
  $SessionTalkOrderList -> bind_columns(undef, \($SessionOrderID,$TalkSeparatorID,$SessionTalkID,$TalkOrder));
  while ($SessionTalkOrderList -> fetch) {
    $SessionOrders{$SessionOrderID}{TalkSeparatorID} = $TalkSeparatorID;
    $SessionOrders{$SessionOrderID}{SessionTalkID}   = $SessionTalkID;
    $SessionOrders{$SessionOrderID}{TalkOrder}	     = $TalkOrder;
    push @SessionOrderIDs,$SessionOrderID;
  }
  $TalkSeparatorOrderList -> execute($SessionID);
  $TalkSeparatorOrderList -> bind_columns(undef, \($SessionOrderID,$TalkSeparatorID,$SessionTalkID,$TalkOrder));
  while ($TalkSeparatorOrderList -> fetch) {
    $SessionOrders{$SessionOrderID}{TalkSeparatorID} = $TalkSeparatorID;
    $SessionOrders{$SessionOrderID}{SessionTalkID}   = $SessionTalkID;
    $SessionOrders{$SessionOrderID}{TalkOrder}	     = $TalkOrder;
    push @SessionOrderIDs,$SessionOrderID;
  }
  return @SessionOrderIDs; 
}
1;
