#        Name: Scripts.pm
# Description: Create links to Javascript used by DocDB and if the
#              scripts need info from DocDB, write the JS
#
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2018 Eric Vaandering, Lynn Garren, Adam Bryant

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

  GetConferences($TRUE);
  GetAllEventGroups();

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
    $label =~ tr/a-zA-Z0-9\.\,\'\-\ //dc; # Remove special characters
    $label =~ s/\'/\\\'/; # Escape single quotes
    print "event[\'$EventID\'] = \'$label\';\n";
  }

  print "//-->\n</script>\n";
}

sub AuthorSearchScript {
  require "AuthorSQL.pm";
  require "Sorts.pm";

  print <<PREAMBLE;
        <script type="text/javascript">
        var auth_ids = [
                /* [author_id, author_name] */
PREAMBLE

  GetAuthors();
  my @AuthorIDs     = sort byLastName keys %Authors;
  foreach my $AuthorID (@AuthorIDs) {
    my $Label = $Authors{$AuthorID}{Formal};
    $Label =~ tr/a-zA-Z0-9\.\,\'\-\ //dc; # Remove special characters
    $Label =~ s/\'/\\\'/; # Escape single quotes
    print '['.$AuthorID.', "'.$Label.'"],'."\n";
  }
  print "\n];\n";
  print 'var imgURL = "'.$ImgURLPath.'";';
  print "</script>\n";
}

sub JQueryReadyScript {
  print '<script type="text/javascript">'."\n";
  print "jQuery().ready(function() {\n";
  foreach my $Element (@JQueryElements) {
    if ($Element eq "elastic") {
      print "  jQuery('textarea').elastic();\n";
    }
    if ($Element eq "validate") {
      print "  jQuery('form#documentadd').validate({onfocusout: true, onkeyup: true});\n";
    }
    if ($Element eq "tablesorter") {
#      print qq(  \$\(".DocumentList"\).tablesorter\(\);\n);
      print "  jQuery('.DocumentList').tablesorter({widgets: [\"zebra\"],
          widgetOptions : {
           zebra : [ \"Even\", \"Odd\" ]
    }});\n";
    }
  }
  print "});\n";
  print "</script>\n";
}

1;
