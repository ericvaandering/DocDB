#
#        Name: EventUtilities.pm 
# Description: Routines to help with events (conferences and meetings) 
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

sub SessionCountByEventID ($) {
  require "MeetingSQL.pm";

  my ($EventID) = @_;
  my @SessionIDs = FetchSessionsByConferenceID($EventID);
  my @SeperatIDs = FetchSessionSeparatorsByConferenceID($EventID);
  
  my $Count = scalar(@SessionIDs) + scalar(@SeperatIDs);
}  

sub SessionEndTime ($) { # Can eventually use EndTime? no need to order these
  require "MeetingSQL.pm";
  require "TalkSQL.pm";
  
  my ($SessionID) = @_;
  &FetchSessionByID ($SessionID);
  my @TalkIDs      = &FetchSessionTalksBySessionID($SessionID);
  my @SeparatorIDs = &FetchTalkSeparatorsBySessionID($SessionID);
   
  my ($AccumSec,$AccumMin,$AccumHour) = &SQLDateTime($Sessions{$SessionID}{StartTime});
  my $AccumulatedTime = &AddTime("$AccumHour:$AccumMin:$AccumSec");

  foreach my $TalkID (@TalkIDs) {
    $AccumulatedTime = &AddTime($AccumulatedTime,$SessionTalks{$TalkID}{Time});
  }

  foreach my $SeparatorID (@SeparatorIDs) {
    $AccumulatedTime = &AddTime($AccumulatedTime,$TalkSeparators{$SeparatorID}{Time});
  }
 
  return $AccumulatedTime;
}

sub EventAgendaDocIDs {
  my ($ArgRef) = @_;
  my $EventID = exists $ArgRef->{-eventid} ? $ArgRef->{-eventid} : 0;

  require "TalkSQL.pm";	

  my %AgendaDocIDs = ();
  
  # Flag documents which are associated with a session
  my @MeetingOrderIDs = FetchMeetingOrdersByConferenceID($EventID);
  foreach my $MeetingOrderID (@MeetingOrderIDs) {
    my $SessionID = $MeetingOrders{$MeetingOrderID}{SessionID};
    if ($SessionID) {
      my @SessionTalkIDs = FetchSessionTalksBySessionID($SessionID);
      foreach my $SessionTalkID (@SessionTalkIDs) {
        if ($SessionTalks{$SessionTalkID}{DocumentID}) {
          $AgendaDocIDs{$SessionTalks{$SessionTalkID}{DocumentID}} = 1;
        }
      } 
    }
  }   
  my @AgendaDocIDs = keys %AgendaDocIDs;
  return @AgendaDocIDs;
}

sub EventHashByTime { # Sort EventHash reverse in date, forward in time
  my $adt = $TmpEventHash{$a}{Time};
  my $bdt = $TmpEventHash{$b}{Time};
  
  my ($adate,$atime) = split /\s+/,$adt;  
  my ($bdate,$btime) = split /\s+/,$bdt;
  
  $bdate cmp $adate
         or 
  $atime cmp $btime;
}

1;
