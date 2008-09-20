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

# Copyright 2001-2009 Eric Vaandering, Lynn Garren, Adam Bryant

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
  my $Comment;
  $SessionHash{url} = "$DisplayMeeting?sessionid=$SessionID";
  $SessionHash{uid} = "Session".$SessionID."\@".$cgi_root;

  #FUTURE: With e-mail for moderators, could use ORGANIZER tag (for one mod)
  my @ModeratorIDs = @{$Sessions{$SessionID}{Moderators}};
  if (@ModeratorIDs) {
    my @Moderators = ();
    foreach my $ModeratorID (@ModeratorIDs) {
      FetchAuthor($ModeratorID);
      push @Moderators,$Authors{$ModeratorID}{FULLNAME};
    }
    $SessionHash{"x-moderators"} = join ', ',@Moderators;
    $Comment .= "Moderated by: ".(join ', ',@Moderators)."\n\n";;
  }

  my @TopicIDs = @{$Sessions{$SessionID}{Topics}};
  if (@TopicIDs) {
    my @Topics = ();
    foreach my $TopicID (@TopicIDs) {
      FetchTopic({ -topicid => $TopicID });
      push @Topics,TopicName({ -topicid => $TopicID });
    }
    $SessionHash{"x-topics"} = join ', ',@Topics;
    $Comment .= "Topics: ".(join ', ',@Topics)."\n\n";
  }

  # Start & End Time
  SessionEndTime($SessionID);
  my $ICalFormatter = DateTime::Format::ICal->new();

  $SessionHash{dtstart} = $ICalFormatter->format_datetime($Sessions{$SessionID}{StartDateTime});
  $SessionHash{dtend}   = $ICalFormatter->format_datetime($Sessions{$SessionID}{EndDateTime});
  $SessionHash{"LAST-MODIFIED"} = $ICalFormatter->format_datetime($Sessions{$SessionID}{ModifiedDateTime});

  foreach my $Key (keys %ICalMapping) {
    if ($Sessions{$SessionID}{$Key}) {
      $SessionHash{$ICalMapping{$Key}} = $Sessions{$SessionID}{$Key};
    }
  }

  if ($Comment) {
    $SessionHash{comment} = $Comment;
  }

  $Event->add_properties(%SessionHash);
  return $Event;
}

1;
