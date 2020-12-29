#
#        Name: VEntryOutput.pm
# Description: Routines to produce iCal formatted lists of events.
#              If support added for XML/HTML format, then add translation
#              layer and presentation layer?
#
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

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

use Data::ICal;
use Data::ICal::Entry::Event;
use DateTime::Format::ICal;

require "AuthorSQL.pm";
require "EventUtilities.pm";
require "MeetingSQL.pm";
require "MeetingHTML.pm";
require "SQLUtilities.pm";

sub NewICal {
  my $Calendar = Data::ICal->new();
  return $Calendar;
}

sub NewICalEvent {
  my $Event = Data::ICal::Entry::Event->new();
  my $ICalFormatter = DateTime::Format::ICal->new();
  $Hash{dtstamp}   = $ICalFormatter->format_datetime(DateTime->now);
  $Event->add_properties(%Hash);

  return $Event;
}

sub ICalHeader {
  my $Header;
  $Header .= "Content-Type: text/calendar\n";
  $Header .= "\n";
  return $Header;
}

sub ICalEventEntry {
  my ($ArgRef) = @_;

  my $EventID = exists $ArgRef->{-eventid} ? $ArgRef->{-eventid} : 0;
  my $Event = NewICalEvent();
  unless ($EventID) {return $Event}
  FetchEventByEventID($EventID);

  # Map names of DocDB Session fields into iCal format fields
  my %ICalMapping = (Title => summary, LongDescription => description, Location => location,);

  my %EventHash = ();
  my @Comments = ();
  if ($Conferences{$EventID}{Preamble}) {
    push @Comments, $Conferences{$EventID}{Preamble};
  }
  $EventHash{url} = "$DisplayMeeting?conferenceid=$EventID";
  $EventHash{uid} = "Event.".$EventID."\@".$cgi_root;

  #FUTURE: With e-mail for moderators, could use ORGANIZER tag (for one mod)
  my @ModeratorIDs = @{$Conferences{$EventID}{Moderators}};
  if (@ModeratorIDs) {
    my $ModeratorList = ListOfModerators(@ModeratorIDs);
    $EventHash{"x-moderators"} = $ModeratorList;
    push @Comments, "Moderated by: $ModeratorList";
  }

  my @TopicIDs = @{$Conferences{$EventID}{Topics}};
  if (@TopicIDs) {
    my $TopicList = ListOfTopics(@TopicIDs);
    $EventHash{"x-topics"} = $TopicList;
    push @Comments, "Topics: $TopicList";
  }

  if ($Conferences{$EventID}{AltLocation}) {
    push @Comments, "Alternate Location: $Conferences{$EventID}{AltLocation}";
  }

  my $ICalFormatter = DateTime::Format::ICal->new();

  my $formated_dtstart = $ICalFormatter->format_datetime($Conferences{$EventID}{StartDateTime});
  if ($formated_dtstart =~ m/TZID=/) {
    my ($timezone, $timestamp) = split(':', $formated_dtstart, 2);
    $EventHash{'dtstart;'.$timezone} = $timestamp
  }
  else {
    $EventHash{dtstart} = $formated_dtstart
  }
  my $formated_dtend = $ICalFormatter->format_datetime($Conferences{$EventID}{EndDateTime});
  if ($formated_dtend =~ m/TZID=/) {
    my ($timezone, $timestamp) = split(':', $formated_dtend, 2);
    $EventHash{'dtend;'.$timezone} = $timestamp
  }
  else {
    $EventHash{dtend} = $formated_dtend
  }

  $EventHash{"LAST-MODIFIED"} = $ICalFormatter->format_datetime($Conferences{$EventID}{ModifiedDateTime});

  foreach my $Key (keys %ICalMapping) {
    if ($Conferences{$EventID}{$Key}) {
      $EventHash{$ICalMapping{$Key}} = $Conferences{$EventID}{$Key};
    }
  }

  if (@Comments) {
    $EventHash{comment} = join "\n\n",@Comments;
  }

  $Event->add_properties(%EventHash);
  return $Event;
}

sub ICalSessionEntry {
  my ($ArgRef) = @_;

  my $SessionID = exists $ArgRef->{-sessionid} ? $ArgRef->{-sessionid} : 0;
  my $Event = NewICalEvent();
  unless ($SessionID) {return $Event}
  FetchSessionByID($SessionID);

  # Map names of DocDB Session fields into iCal format fields
  my %ICalMapping = (Title => summary, Description => description, Location => location,);

  my %SessionHash = ();
  my @Comments = ();
  $SessionHash{url} = "$DisplayMeeting?sessionid=$SessionID";
  $SessionHash{uid} = "Session.".$SessionID."\@".$cgi_root;

  # FUTURE: With e-mail for moderators, could use ORGANIZER tag (for one mod)
  my @ModeratorIDs = @{$Sessions{$SessionID}{Moderators}};
  if (@ModeratorIDs) {
    my $ModeratorList = ListOfModerators(@ModeratorIDs);
    $SessionHash{"x-moderators"} = $ModeratorList;
    push @Comments, "Moderated by: $ModeratorList";
  }

  my @TopicIDs = @{$Sessions{$SessionID}{Topics}};
  if (@TopicIDs) {
    my $TopicList = ListOfTopics(@TopicIDs);
    $SessionHash{"x-topics"} = $TopicList;
    push @Comments, "Topics: $TopicList";
  }

  if ($Sessions{$SessionID}{AltLocation}) {
    push @Comments, "Alternate Location: $Sessions{$SessionID}{AltLocation}";
  }

  # Start & End Time
  SessionEndTime($SessionID);
  my $ICalFormatter = DateTime::Format::ICal->new();

  my $formated_dtstart = $ICalFormatter->format_datetime($Sessions{$SessionID}{StartDateTime});
  if ($formated_dtstart =~ m/TZID=/) {
    my ($timezone, $timestamp) = split(':', $formated_dtstart, 2);
    $SessionHash{'dtstart;'.$timezone} = $timestamp
  }
  else {
    $SessionHash{dtstart} = $formated_dtstart
  }
  my $formated_dtend = $ICalFormatter->format_datetime($Sessions{$SessionID}{EndDateTime});
  if ($formated_dtend =~ m/TZID=/) {
    my ($timezone, $timestamp) = split(':', $formated_dtend, 2);
    $SessionHash{'dtend;'.$timezone} = $timestamp
  }
  else {
    $SessionHash{dtend} = $formated_dtend
  }
  
  $SessionHash{"LAST-MODIFIED"} = $ICalFormatter->format_datetime($Sessions{$SessionID}{ModifiedDateTime});

  foreach my $Key (keys %ICalMapping) {
    if ($Sessions{$SessionID}{$Key}) {
      $SessionHash{$ICalMapping{$Key}} = $Sessions{$SessionID}{$Key};
    }
  }

  if (@Comments) {
    $SessionHash{comment} = join "\n\n",@Comments;
  }

  $Event->add_properties(%SessionHash);
  return $Event;
}

sub ListOfModerators {
  my @ModeratorIDs = @_;
  my $ModeratorList = "";
  if (@ModeratorIDs) {
    my @Moderators = ();
    foreach my $ModeratorID (@ModeratorIDs) {
      FetchAuthor($ModeratorID);
      push @Moderators,$Authors{$ModeratorID}{FULLNAME};
    }
    $ModeratorList = join ', ',@Moderators;
  }
  return $ModeratorList;
}

sub ListOfTopics {
  my @TopicIDs = @_;
  my $TopicList = "";
  if (@TopicIDs) {
    my @Topics = ();
    foreach my $TopicID (@TopicIDs) {
      FetchTopic({ -topicid => $TopicID });
      push @Topics,TopicName({ -topicid => $TopicID });
    }
    $TopicList = join ', ',@Topics;
  }
  return $TopicList;
}

1;