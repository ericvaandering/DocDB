# Description: Routines to access tables dealing with security settings on 
#              meetings
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2004 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub GetMeetingSecurityGroups ($) {
  my ($ConferenceID) = @_;
 
  my $Select = $dbh -> prepare("select MeetingSecurityID from MeetingSecurity ".
                                     "where ConferenceID=?");
  my ($MeetingSecurityID);
  my @MeetingSecurityGroupIDs = ();
  
  $Select -> execute($ConferenceID);
  $Select -> bind_columns(undef, \($MeetingSecurityID));
  while ($Select -> fetch) {
    my $MeetingSecurityGroupID = &FetchMeetingSecurityGroup($MeetingSecurityID);
    push @MeetingSecurityGroupIDs,$MeetingSecurityGroupID;
  }
 
  return @MeetingSecurityGroupIDs;
}

sub FetchMeetingSecurityGroup ($) {
  my ($MeetingSecurityID) = @_;

  if ($MeetingSecurities{$MeetingSecurityID}{TimeStamp}) {
    return $MeetingSecurityID;
  }
  
  my ($ConferenceID,$GroupID,$TimeStamp);
  my $Select = $dbh -> prepare("select ConferenceID,GroupID,TimeStamp ".
                               "from MeetingSecurity where MeetingSecurityID=?");
  $Select -> execute($MeetingSecurityID);
  ($ConferenceID,$GroupID,$TimeStamp) = $Select -> fetchrow_array;
  
  if ($TimeStamp) {
    $MeetingSecurities{$MeetingSecurityID}{ConferenceID} = $DocRevID   ;
    $MeetingSecurities{$MeetingSecurityID}{GroupID}      = $Note       ;
    $MeetingSecurities{$MeetingSecurityID}{TimeStamp}    = $TimeStamp  ;
    return $MeetingSecurityID;
  } else {
    return 0;
  }  
}  

sub GetMeetingModifyGroups ($) {
  my ($ConferenceID) = @_;
 
  my $Select = $dbh -> prepare("select MeetingModifyID from MeetingModify ".
                                     "where ConferenceID=?");
  my ($MeetingModifyID);
  my @MeetingModifyGroupIDs = ();
  
  $Select -> execute($ConferenceID);
  $Select -> bind_columns(undef, \($MeetingModifyID));
  while ($Select -> fetch) {
    my $MeetingModifyGroupID = &FetchMeetingModifyGroup($MeetingModifyID);
    push @MeetingModifyGroupIDs,$MeetingModifyGroupID;
  }
 
  return @MeetingModifyGroupIDs;
}

sub FetchMeetingModifyGroup ($) {
  my ($MeetingModifyID) = @_;

  if ($MeetingModify{$MeetingModifyID}{TimeStamp}) {
    return $MeetingModifyID;
  }
  
  my ($ConferenceID,$GroupID,$TimeStamp);
  my $Select = $dbh -> prepare("select ConferenceID,GroupID,TimeStamp ".
                               "from MeetingModify where MeetingModifyID=?");
  $Select -> execute($MeetingModifyID);
  ($ConferenceID,$GroupID,$TimeStamp) = $Select -> fetchrow_array;
  
  if ($TimeStamp) {
    $MeetingModify{$MeetingModifyID}{ConferenceID} = $DocRevID   ;
    $MeetingModify{$MeetingModifyID}{GroupID}      = $Note       ;
    $MeetingModify{$MeetingModifyID}{TimeStamp}    = $TimeStamp  ;
    return $MeetingModifyID;
  } else {
    return 0;
  }  
}  

1;
