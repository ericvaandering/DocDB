#
#        Name: TalkSQL.pm 
# Description: Routines to access SQL tables related to talks for meetings 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2007 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub ClearSessionTalks {
  %SessionTalks       = ();
  $GotAllSessionTalks = 0;
}

sub FetchSessionTalksByConferenceID ($) {
  my ($ConferenceID) = @_;
  my $SessionTalkID;
  my @SessionTalkIDs = ();
  my $SessionTalkList   = $dbh -> prepare(
    "select SessionTalk.SessionTalkID from SessionTalk,Session ".
    "where Session.SessionID=SessionTalk.SessionID and Session.ConferenceID=?");
  $SessionTalkList -> execute($ConferenceID);
  $SessionTalkList -> bind_columns(undef, \($SessionTalkID));
  while ($SessionTalkList -> fetch) {
    $SessionTalkID = &FetchSessionTalkByID($SessionTalkID);
    push @SessionTalkIDs,$SessionTalkID;
  }
  return @SessionTalkIDs; 
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
  $SessionTalkFetch -> execute($SessionTalkID);
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
  my ($SessionID,$Time,$Title,$Note,$TimeStamp); 
  my $TalkSeparatorFetch = $dbh -> prepare(
    "select SessionID,Time,Title,Note,TimeStamp ".
    "from TalkSeparator where TalkSeparatorID=?");
  if ($TalkSeparators{$TalkSeparatorID}{TimeStamp}) {
    return $TalkSeparatorID;
  }
  $TalkSeparatorFetch -> execute($TalkSeparatorID);
  ($SessionID,$Time,$Title,$Note,$TimeStamp) = $TalkSeparatorFetch -> fetchrow_array; 
  if ($TimeStamp) {
    $TalkSeparators{$TalkSeparatorID}{SessionID} = $SessionID;
    $TalkSeparators{$TalkSeparatorID}{Time}	 = $Time;
    $TalkSeparators{$TalkSeparatorID}{Title}     = $Title;
    $TalkSeparators{$TalkSeparatorID}{Note}      = $Note;
    $TalkSeparators{$TalkSeparatorID}{TimeStamp} = $TimeStamp;
  }
  
  return $TalkSeparatorID;  
}

sub FetchSessionOrdersBySessionID {
  my ($SessionID) = @_;
  my ($TalkSeparatorID,$SessionTalkID,$SessionOrderID,$TalkOrder);
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

sub FetchSessionOrderByID ($) {
  my ($SessionOrderID) = @_;
  my ($TalkSeparatorID,$SessionTalkID,$TalkOrder);
  my $List   = $dbh -> prepare(
    "select SessionOrderID,TalkSeparatorID,SessionTalkID,TalkOrder ".
    "from SessionOrder where SessionOrderID=?");

  $List -> execute($SessionOrderID);
  ($SessionOrderID,$TalkSeparatorID,$SessionTalkID,$TalkOrder) = $List -> fetchrow_array;
  $SessionOrders{$SessionOrderID}{TalkSeparatorID} = $TalkSeparatorID;
  $SessionOrders{$SessionOrderID}{SessionTalkID}   = $SessionTalkID;
  $SessionOrders{$SessionOrderID}{TalkOrder}       = $TalkOrder;

  return $SessionOrderID;
}

sub DeleteSessionTalk ($) {
  my ($SessionTalkID) = @_;

  require "TalkHintSQL.pm";

  my $TalkDelete  = $dbh -> prepare("delete from SessionTalk  where SessionTalkID=?"); 
  my $OrderDelete = $dbh -> prepare("delete from SessionOrder where SessionTalkID=?"); 

  $TalkDelete  -> execute($SessionTalkID);
  $OrderDelete -> execute($SessionTalkID);
  
  &DeleteHints($SessionTalkID);  
}

sub DeleteTalkSeparator ($) {
  my ($TalkSeparatorID) = @_;

  my $SeparatorDelete = $dbh -> prepare("delete from TalkSeparator where TalkSeparatorID=?"); 
  my $OrderDelete     = $dbh -> prepare("delete from SessionOrder  where TalkSeparatorID=?"); 

  $SeparatorDelete -> execute($TalkSeparatorID);
  $OrderDelete     -> execute($TalkSeparatorID);
}

sub ConfirmTalk (%) {
  require "RevisionSQL.pm";
  my %Params = @_;
  
  my $DocumentID    = $Params{-docid}         || 0;
  my $SessionTalkID = $Params{-sessiontalkid} || 0;
  my $EventID       = $Params{-eventid}       || 0;
  
  &FetchRevisionsByDocument($DocumentID);
  my $DocRevID = $DocRevIDs{$DocumentID}{$Documents{$DocumentID}{NVersions}};
  
  my $Check = $dbh -> prepare("select RevEventID from RevisionEvent where DocRevID=? and ConferenceID=?");
  $Check -> execute($DocRevID,$EventID);
  my ($RevisionEventID) = $Check -> fetchrow_array;
  unless ($RevisionEventID) {
    my $Insert = $dbh -> prepare("insert into RevisionEvent (RevEventID,DocRevID,ConferenceID) values (0,?,?)"); 
    $Insert -> execute($DocRevID,$EventID);
  }  
} 

1;
