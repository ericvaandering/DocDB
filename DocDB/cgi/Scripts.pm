
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

sub HelpLink { # Change this, change FormElementTitle
               # Eventually, replace with  FormElementTitle
  my ($helpterm) = @_;
  print " style=\"color: red\" href=\"Javascript:helppopupwindow(\'$DocDBHelp?term=$helpterm\');\">";
}

sub TalkNoteLink {
  my ($SessionTalkID) = @_;
  return "<a href=\"Javascript:notepopupwindow(\'$ShowTalkNote?sessiontalkid=$SessionTalkID\');\">Note</a>";
}

sub GroupLimitLink {
  return "<a href=\"Javascript:grouplimitpopupwindow(\'$SelectGroups\');\">Limit Groups</a>";
}

sub ConfirmTalkLink ($$) { #FIXME: Make onclick optional, use in DocumentTable
  my ($SessionTalkID,$DocumentID) = @_;
  my $HTML  = "<form>";
     $HTML .= $query -> hidden(-name => 'documentid',   -default => $DocumentID);
     $HTML .= $query -> hidden(-name => 'sessiontalkid',-default => $SessionTalkID);
     $HTML .= $query -> button(-value => "Confirm Match", 
                               -onclick => "confirmtalkpopupwindow(this.form,\"$ConfirmTalkHint\")");
     $HTML .= "</form>";
  return $HTML;
}

sub TopicSearchScript {

# This script produces a menu for topics and another for relevant subtopics
# (i.e. selecting a topic reduces the set of subtopics). This code is 
# adapted from Bugzilla, produced by mozilla.org.

# There are two major changes:
#  1. seperate labels and values
#  2. sort by label instead of by value

  print <<PREAMBLE;

<script type="text/javascript">
<!--

var first_load = 1; // is this the first time we load the page?
var last_sel = []; // caches last selection

var major = new Array();
var label = new Array();

PREAMBLE

  foreach $MajorID (sort byMajorTopic keys %MajorTopics) {
    print "major[\'$MajorID\'] = [";
    $first = 1;
    foreach $MinorID (sort byTopic keys %MinorTopics) { #FIXME use join
      if ($MinorTopics{$MinorID}{MAJOR} == $MajorID) {
        unless ($first) { 
          print ", ";
        }
        $first = 0;
        print "\'$MinorID\'";
      }
    }
    print "];\n";  
  }

  foreach $MinorID (sort byTopic keys %MinorTopics) { #FIXME use join
    my $label = $MinorTopics{$MinorID}{Full};
    $label =~ s/\'/\\\'/; # Escape single quotes
    print "label[\'$MinorID\'] = \'$label\';\n"; 
  }   

  print "//-->\n</script>\n";
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
