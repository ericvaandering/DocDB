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

sub TalkNoteLink {
  my ($SessionOrderID) = @_;
  return "<a href=\"Javascript:notepopupwindow(\'$ShowTalkNote?sessionorderid=$SessionOrderID\');\">Edit</a>";
}

sub GroupLimitLink {
  return "<a href=\"Javascript:grouplimitpopupwindow(\'$SelectGroups\');\">Limit Groups</a>";
}

sub EventSearchScript {
  
# This script produces a menu for event groups and another for relevant events
# (i.e. selecting a group reduces the set of events). This code is 
# adapted from Bugzilla, produced by mozilla.org.

# There are two major changes:
#  1. seperate labels and values
#  2. sort by label instead of by value
  require "MeetingSQL.pm";
  
  &GetConferences;
  &GetAllEventGroups;
  
  print <<PREAMBLE;

<script type="text/javascript">
<!--

var first_load = 1; // is this the first time we load the page?
var last_sel = []; // caches last selection

var group = new Array();
var event = new Array();

PREAMBLE

  foreach my $EventGroupID (sort EventGroupsByName keys %EventGroups) {
    print "group[\'$EventGroupID\'] = [";
    my $first = 1;
    foreach my $EventID (sort EventsByDate keys %Conferences) { #FIXME use join
      if ($Conferences{$EventID}{EventGroupID} == $EventGroupID) {
        unless ($first) { 
          print ", ";
        }
        $first = 0;
        print "\'$EventID\'";
      }
    }
    print "];\n";  
  }

  foreach $EventID (sort EventsByDate keys %Conferences) { #FIXME use join
    my $label = $Conferences{$EventID}{Full};
    $label =~ s/\'/\\\'/; # Escape single quotes
    print "event[\'$EventID\'] = \'$label\';\n"; 
  }   

  print "//-->\n</script>\n";
} 

1;
