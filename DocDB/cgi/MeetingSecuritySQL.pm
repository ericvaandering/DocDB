# Description: Routines to access tables dealing with security settings on 
#              meetings
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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

sub GetMeetingSecurityGroups ($) {
  my ($ConferenceID) = @_;
 
  my $Select = $dbh -> prepare("select MeetingSecurityID from MeetingSecurity ".
                                     "where ConferenceID=?");
  my ($MeetingSecurityID);
  my @MeetingSecurityIDs = ();
  
  $Select -> execute($ConferenceID);
  $Select -> bind_columns(undef, \($MeetingSecurityID));
  while ($Select -> fetch) {
    $MeetingSecurityID = &FetchMeetingSecurityGroup($MeetingSecurityID);
    push @MeetingSecurityIDs,$MeetingSecurityID;
  }
 
  return @MeetingSecurityIDs;
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
    $MeetingSecurities{$MeetingSecurityID}{ConferenceID} = $ConferenceID;
    $MeetingSecurities{$MeetingSecurityID}{GroupID}      = $GroupID     ;
    $MeetingSecurities{$MeetingSecurityID}{TimeStamp}    = $TimeStamp   ;
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
  my @MeetingModifyIDs = ();
  
  $Select -> execute($ConferenceID);
  $Select -> bind_columns(undef, \($MeetingModifyID));
  while ($Select -> fetch) {
    $MeetingModifyID = &FetchMeetingModifyGroup($MeetingModifyID);
    push @MeetingModifyIDs,$MeetingModifyID;
  }
 
  return @MeetingModifyIDs;
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
    $MeetingModify{$MeetingModifyID}{ConferenceID} = $ConferenceID;
    $MeetingModify{$MeetingModifyID}{GroupID}      = $GroupID     ;
    $MeetingModify{$MeetingModifyID}{TimeStamp}    = $TimeStamp   ;
    return $MeetingModifyID;
  } else {
    return 0;
  }  
}  

sub MeetingSecurityUpdate (%) {  
  my (%Params) = @_;
  
  my $Mode         =   $Params{-mode};
  my $ConferenceID =   $Params{-conferenceid} || 0;
  my @GroupIDs     = @{$Params{-groupids}};
  
  my $Table;
  my $Success = 0;
     
  if ($Mode eq "access") {  
    $Table = "MeetingSecurity";
  } elsif ($Mode eq "modify") {
    $Table = "MeetingModify";
  }
  
  my $IDField = $Table."ID";
  
# Delete old settings, insert new ones  
  
  if ($Table && $ConferenceID) {
    my $Delete = $dbh -> prepare("delete from $Table where ConferenceID=?");
    my $Insert = $dbh -> prepare("insert into $Table ($IDField,ConferenceID,GroupID) values (0,?,?)");
    $Delete -> execute($ConferenceID);
    foreach my $GroupID (@GroupIDs) {
      unless ($GroupID) {next;}
      $Insert -> execute($ConferenceID,$GroupID);
    }
    $Success = 1;  
  } 
  
  return $Success;
}


1;
