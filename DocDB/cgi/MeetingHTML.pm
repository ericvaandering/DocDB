#        Name: MeetingHTML.pm
# Description: HTML producing routines for meetings and conferences
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

# FIXME: Unify various TopicLink, MeetingLink, NewMeetingLink, ConferenceLink, GatheringLink

sub LocationBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("location");
  print "Location:</a></b><br> \n";
  print $query -> textfield (-name => 'location', -default => $MeetingDefaultLocation,
                             -size => 20, -maxlength => 64);
};

sub ConferenceURLBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("confurl");
  print "URL:</a></b><br> \n";
  print $query -> textfield (-name => 'url', -default => $MeetingDefaultURL,
                             -size => 40, -maxlength => 64);
};

sub ConferencePreambleBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("meetpreepi");
  print "Meeting Preamble:</a></b><br> \n";
  print $query -> textarea (-name => 'meetpreamble', -default => $MeetingDefaultPreamble,
                            -columns => 50, -rows => 7);
};

sub ConferenceEpilogueBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("meetpreepi");
  print "Meeting Epilogue:</a></b><br> \n";
  print $query -> textarea (-name => 'meetepilogue', -default => $MeetingDefaultEpilogue,
                            -columns => 50, -rows => 7);
};

sub ConferenceShowAllTalks {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("meetshowall");
  print "Show All Talks?</a></b> \n";
  if ($MeetingDefaultShowAllTalks) {
    print $query -> checkbox(-name => "meetshowall", -value => 1, -label => 'Yes', -checked => 'Yes');
  } else {
    print $query -> checkbox(-name => "meetshowall", -value => 1, -label => 'Yes');
  }
}


sub SessionEntryForm ($@) {
  my ($ConferenceID,@MeetingOrderIDs) = @_; 

  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("sessions");
  print "Sessions:</a></b><p> \n";
  print "<table cellpadding=3>\n";

  print "<tr valign=bottom>\n";
   print "<th><b><a "; &HelpLink("meetingorder");     print "Order</a></b> or <br>\n";
   print "    <b><a "; &HelpLink("sessiondelete");    print "Delete</a></td>\n";
   print "<th><b><a "; &HelpLink("meetingseparator"); print "Break</a></th>\n";
   print "<th><b><a "; &HelpLink("sessioninfo");      print "Session Title & Description</a></th>\n";
   print "<th><b><a "; &HelpLink("sessioninfo");      print "Location<br>Start Date and Time</a></th>\n";
  print "</tr>\n";
  
  # Sort session IDs by order
  
  my $ExtraSessions = $InitialSessions;
  if (@MeetingOrderIDs) { $ExtraSessions = 1; }
  for (my $Session=1;$Session<=$ExtraSessions;++$Session) {
    push @MeetingOrderIDs,"n$Session";
  }
  
  my $SessionOrder = 0;
  foreach $MeetingOrderID (@MeetingOrderIDs) {
  
    ++$SessionOrder;
    $SessionDefaultOrder = $SessionOrder;  
    
    if (grep /n/,$MeetingOrderID) {# Erase defaults
      if ($ConferenceID) {
        &FetchConferenceByConferenceID($ConferenceID);
        $SessionDefaultDateTime = $Conferences{$ConferenceID}{StartDate};
      } else {
        $SessionDefaultDateTime = "";
      }
      $SessionDefaultLocation    = "";
      $SessionDefaultTitle       = "";
      $SessionDefaultDescription = "";
      $SessionSeparatorDefault   = "";
    } else { # Key off Meeting Order IDs, do differently for Sessions and Separators
      if ($MeetingOrders{$MeetingOrderID}{SessionID}) {
        my $SessionID = $MeetingOrders{$MeetingOrderID}{SessionID};
	$SessionDefaultDateTime    = $Sessions{$SessionID}{StartTime};
        $SessionDefaultLocation    = $Sessions{$SessionID}{Location}    || "";
	$SessionDefaultTitle       = $Sessions{$SessionID}{Title}       || "";
	$SessionDefaultDescription = $Sessions{$SessionID}{Description} || "";
	$SessionSeparatorDefault   = "No";
      } elsif ($MeetingOrders{$MeetingOrderID}{SessionSeparatorID}) {
        my $SessionSeparatorID = $MeetingOrders{$MeetingOrderID}{SessionSeparatorID};
	$SessionDefaultDateTime    = $SessionSeparators{$SessionSeparatorID}{StartTime};
        $SessionDefaultLocation    = $SessionSeparators{$SessionSeparatorID}{Location}    || "";
	$SessionDefaultTitle       = $SessionSeparators{$SessionSeparatorID}{Title}       || "";
	$SessionDefaultDescription = $SessionSeparators{$SessionSeparatorID}{Description} || "";
	$SessionSeparatorDefault   = "Yes";
      }
    } 

    print "<tr valign=top>\n";
    
     $query -> param('meetingorderid',$MeetingOrderID);
     print $query -> hidden(-name => 'meetingorderid', -default => $MeetingOrderID);

     print "<td align=center rowspan=2>"; &SessionOrder;                       print "<p/>\n";
                                          &SessionModifyLink($MeetingOrderID); print "<p/>\n";
                                          &SessionDelete($MeetingOrderID);     
     print "</td>\n";

     print "<td align=center>\n"; &SessionSeparator($MeetingOrderID);  print "</td>\n";
     print "<td>\n";              &SessionTitle($SessionDefaultTitle); print "</td>\n";
     print "<td>\n";              &SessionLocation;                    print "</td>\n";
    print "</tr>\n";

    print "<tr valign=top>\n";
     print "<td>&nbsp</td>\n";
     print "<td>\n";              &SessionDescription;                 print "</td>\n";
     print "<td align=right>\n";  &SessionDateTimePullDown;            print "</td>\n";
    print "</tr>\n";

    print "<tr valign=top><td colspan=4><hr width=95%></td>\n";
    print "</tr>\n";
  }
  print "</table>\n";
}

sub SessionDateTimePullDown {
  my $DefaultYear,$DefaultMonth,$DefaultDay,$DefaultHour;
  my (undef,undef,undef,$Day,$Month,$Year) = localtime(time);
  $Year += 1900;
  if ($SessionDefaultDateTime) {
    my ($Date,$Time) = split /\s+/,$SessionDefaultDateTime;
    my ($Year,$Month,$Day) = split /-/,$Date;
    my ($Hour,$Minute,undef) = split /:/,$Time;
    $Time = "$Hour:$Minute";
    $DefaultYear  = $Year;
    $DefaultMonth = $Month-1;
    $DefaultDay   = int($Day);
    $DefaultHour  = $Time;
  } else {
    $DefaultYear  = $Year;
    $DefaultMonth = $Month;
    $DefaultDay   = int($Day);
    $DefaultHour  = "09:00";
  }  
  if ($DefaultHour eq ":") {
    $DefaultHour = "09:00";
  }  
   
  my @days = ();
  for ($i = 1; $i<=31; ++$i) {
    push @days,$i;
  }  

  my @months = @AbrvMonths;

  my @years = ();
  for ($i = $FirstYear; $i<=$Year+2; ++$i) { # $FirstYear - current year
    push @years,$i;
  }  

  my @hours = ();
  for (my $Hour = 7; $Hour<=20; ++$Hour) {
    for (my $Min = 0; $Min<=59; $Min=$Min+15) {
      push @hours,sprintf "%2.2d:%2.2d",$Hour,$Min;
    }  
  }  

  $query -> param('sessionday',  $DefaultDay);
  $query -> param('sessionmonth',$AbrvMonths[$DefaultMonth]);
  $query -> param('sessionyear', $DefaultYear);
  $query -> param('sessionhour', $DefaultHour);

  print $query -> popup_menu (-name => 'sessionday',  -values => \@days,  -default => $DefaultDay);
  print $query -> popup_menu (-name => 'sessionmonth',-values => \@months,-default => $AbrvMonths[$DefaultMonth]);
  print $query -> popup_menu (-name => 'sessionyear', -values => \@years, -default => $DefaultYear);
  print "<p> at &nbsp;\n";
  print $query -> popup_menu (-name => 'sessionhour', -values => \@hours, -default => $DefaultHour);
}

sub SessionOrder {
  $query -> param('sessionorder',$SessionDefaultOrder);
  print $query -> textfield (-name => 'sessionorder', -value => $SessionDefaultOrder, 
                             -size => 4, -maxlength => 5);
}

sub SessionSeparator ($) {
  my ($MeetingOrderID) = @_;

  if ($SessionSeparatorDefault eq "Yes") {
    print "Yes\n";	      
  } elsif ($SessionSeparatorDefault eq "No") {
    print "No\n";	      
  } else {
    print $query -> checkbox(-name => "sessionseparator", -value => "$MeetingOrderID", -label => 'Break');
  }
}

sub SessionDelete ($) {
  my ($MeetingOrderID) = @_;
  if ($SessionSeparatorDefault eq "Yes" || $SessionSeparatorDefault eq "No") {
    print $query -> checkbox(-name => "sessiondelete", -value =>
    "$MeetingOrderID", -label => 'Delete');
  } else {
    print "&nbsp\n";
  }
}

sub SessionModifyLink ($) {
  my ($MeetingOrderID) = @_;
  if ($SessionSeparatorDefault eq "No") {
    my $SessionID = $MeetingOrders{$MeetingOrderID}{SessionID};
    print "<a href=\"$SessionModify?sessionid=$SessionID\">Modify session<br>agenda</a>\n";
  } else {
    print "&nbsp\n";
  }
}

sub SessionTitle ($) {
  $query -> param('sessiontitle',$SessionDefaultTitle);
  print $query -> textfield (-name => 'sessiontitle', -size => 40, -maxlength => 128, 
                             -default => $SessionDefaultTitle);
}

sub SessionDescription {
  $query -> param('sessiondescription',$SessionDefaultDescription);
  print $query -> textarea (-name => 'sessiondescription',-value => $SessionDefaultDescription, 
                            -columns => 40, -rows => 3);
}

sub SessionLocation {
  $query -> param('sessionlocation',$SessionDefaultLocation);
  print $query -> textfield (-name => 'sessionlocation', -size => 30, -maxlength => 128, 
                             -default => $SessionDefaultLocation);
};

sub PrintSession ($) {
  my ($SessionID) = @_;
  
  require "Sorts.pm";
  require "TalkSQL.pm";
  require "TalkHTML.pm";
  require "SQLUtilities.pm";
  require "Utilities.pm";
  
  &PrintSessionHeader($SessionID);
  print "<p>\n";
  
  my @SessionTalkIDs   = &FetchSessionTalksBySessionID($SessionID);
  my @TalkSeparatorIDs = &FetchTalkSeparatorsBySessionID($SessionID);
  my @SessionOrderIDs  = &FetchSessionOrdersBySessionID($SessionID);
  my $ConferenceID     = $Sessions{$SessionID}{ConferenceID};
  
  my ($AccumSec,$AccumMin,$AccumHour) = &SQLDateTime($Sessions{$SessionID}{StartTime});
  my $AccumulatedTime = &AddTime("$AccumHour:$AccumMin:$AccumSec");
  
  # Getting TopicID will depend on re-factoring Conferences Hashes
  my $MinorTopicID = $Conferences{$ConferenceID}{Minor};
  
  @IgnoreTopics = ($MinorTopicID);
  
# Sort talks and separators

  @SessionOrderIDs = sort SessionOrderIDByOrder @SessionOrderIDs;
  print "<center><table cellpadding=3>\n";

  print "<tr>\n";
  print "<th>Start</th>\n";
  print "<th>Title</th>\n";
  print "<th>Author</th>\n";
  print "<th>Topic(s)</th>\n";
  print "<th>Files</th>\n";
  print "<th>Length</th>\n";
  print "<th>Notes</th>\n";
  print "</tr>\n";

  foreach my $SessionOrderID (@SessionOrderIDs) {
    if ($SessionOrders{$SessionOrderID}{TalkSeparatorID}) { # TalkSeparator
      my $TalkSeparatorID =  $SessionOrders{$SessionOrderID}{TalkSeparatorID};

      print "<tr valign=top>\n";
      print "<td align=right><b>",&TruncateSeconds($AccumulatedTime),"</b></td>\n";
      print "<td>$TalkSeparators{$TalkSeparatorID}{Title}</td>\n";
      print "<td colspan=3>$TalkSeparators{$TalkSeparatorID}{Note}</td>\n";
      print "<td align=right>",&TruncateSeconds($TalkSeparators{$TalkSeparatorID}{Time}),"</td>\n";
      print "</tr>\n";

      $AccumulatedTime = &AddTime($AccumulatedTime,$TalkSeparators{$TalkSeparatorID}{Time});
    } elsif ($SessionOrders{$SessionOrderID}{SessionTalkID}) {
      my $SessionTalkID =  $SessionOrders{$SessionOrderID}{SessionTalkID};

      if ($SessionTalks{$SessionTalkID}{DocumentID}) { # Talk with DocID (confirmed or not)
        &PrintSessionTalk($SessionTalkID,$AccumulatedTime);
      } else { # Talk where only hints exist
        # FIXME add output for for topic and author hints
        print "<tr valign=top>\n";
        print "<td align=right><b>",&TruncateSeconds($AccumulatedTime),"</b></td>\n";
        print "<td>$SessionTalks{$SessionTalkID}{HintTitle}</td>\n";
        my @TopicHintIDs  = &FetchTopicHintsBySessionTalkID($SessionTalkID);
        my @AuthorHintIDs = &FetchAuthorHintsBySessionTalkID($SessionTalkID);
        my @TopicIDs  = ();
        my @AuthorIDs = (); 
        foreach my $TopicHintID (@TopicHintIDs) {
          push @TopicIDs,$TopicHints{$TopicHintID}{MinorTopicID};
        }
        foreach my $AuthorHintID (@AuthorHintIDs) {
          push @AuthorIDs,$AuthorHints{$AuthorHintID}{AuthorID};
        }
        print "<td><i>\n"; &ShortAuthorListByID(@AuthorIDs); print "</i></td>\n";
        print "<td><i>\n"; &ShortTopicListByID(@TopicIDs);   print "</i></td>\n";
        print "<td>&nbsp</td>\n"; # Files, which can't exist
        print "<td align=right>",&TruncateSeconds($SessionTalks{$SessionTalkID}{Time}),"</td>\n";
        if ($SessionTalks{$SessionTalkID}{Note}) {
          print "<td><b>",&TalkNoteLink($SessionTalkID),"</b></td>\n";
        } else {
          print "<td>",&TalkNoteLink($SessionTalkID),"</td>\n";
        }  
        print "</tr>\n";
      } 
      $AccumulatedTime = &AddTime($AccumulatedTime,$SessionTalks{$SessionTalkID}{Time});
    }
  } # End Separator/Talk distinction
  print "</table></center><hr width=95%>\n";   
}

sub PrintSessionSeparator ($) {
  my ($SessionSeparatorID) = @_;
  
  require "SQLUtilities.pm";
  
  print "<center><table cellpadding=5><tr valign=top>\n";
  print "<td><dl><dt><b>$SessionSeparators{$SessionSeparatorID}{Title}</b>\n";
  print "<dd>",&EuroDate($SessionSeparators{$SessionSeparatorID}{StartTime});
  print " at ";
  print &EuroTimeHM($SessionSeparators{$SessionSeparatorID}{StartTime});
  print "</dl></td> \n";
  if ($SessionSeparators{$SessionSeparatorID}{Location}) {
    print "<td><dl><dt><b>Location:</b><dd>$SessionSeparators{$SessionSeparatorID}{Location}</dl></td>\n";
  }
  if ($SessionSeparators{$SessionSeparatorID}{Description}) {
    print "<td width=50%><dl><dt><b>Description:</b><dd>$SessionSeparators{$SessionSeparatorID}{Description}</dl> </td>\n";
  }
  print "</tr></table><p>\n";
  print "</center><hr width=95%>\n";   
}

sub PrintSessionHeader ($) {
  my ($SessionID) = @_;

  require "SQLUtilities.pm";
  require "Utilities.pm";

  my $ConferenceID = $Sessions{$SessionID}{ConferenceID};

  print "<center><a name=\"$SessionID\"><b>Session: ".
        "<a href=\"$DisplayMeeting?sessionid=$SessionID\">$Sessions{$SessionID}{Title}</a> begins \n";
  print &EuroDate($Sessions{$SessionID}{StartTime});
  print " at ";
  print &EuroTimeHM($Sessions{$SessionID}{StartTime});
  print "</b>\n";
  if ($Sessions{$SessionID}{Location}) {
    print "<br> Location: $Sessions{$SessionID}{Location}\n";
  }
  if (&CanModifyMeeting($ConferenceID)) {
    print "<br>(<a href=\"$DocumentAddForm?sessionid=$SessionID\">Upload a document</a> ".
          "or <a href=\"$SessionModify?sessionid=$SessionID\">update the agenda</a> for this session)\n";
  }
  if ($Sessions{$SessionID}{Description}) {
    my $Description = $Sessions{$SessionID}{Description};
    $Description =~ s/\n\s*\n/<p>/;
    $Description =~ s/\n/<br>/;
    
    print "<p> ",&URLify($Description),"\n";
  }
  print "<p></center> \n";
}

sub PrintMeetingInfo($;%) {
  my ($ConferenceID,%Params) = @_;

  require "Utilities.pm";

  my $AddTalkLink = $Params{-talklink} || "";	     # short, long, full
  my $AddNavBar   = $Params{-navbar}   || "";		  # Any non-null text is "true"

#  my $AddTalkLink = $IsSingle; # FIXME: May want to make these 
#  my $AddNavBar   = $IsSingle; # parameters in a hash

  print "<center><b><big> \n";
  print "<a href=\"$DisplayMeeting?conferenceid=$ConferenceID\">$Conferences{$ConferenceID}{Title}</a>\n";
  print "</big></b><br>\n";

  if ($Conferences{$ConferenceID}{StartDate} ne $Conferences{$ConferenceID}{EndDate}) {
    print " held from ",&EuroDate($Conferences{$ConferenceID}{StartDate});
    print " to ",&EuroDate($Conferences{$ConferenceID}{EndDate});
  } else {
    print " held on ",&EuroDate($Conferences{$ConferenceID}{StartDate});
  }
  print " in $Conferences{$ConferenceID}{Location}\n";

  if ($Conferences{$ConferenceID}{URL}) {
    print "<br>\n";
    print "(<a href=\"$Conferences{$ConferenceID}{URL}\">$Conferences{$ConferenceID}{Title} homepage</a>)\n";
  }
  
  if ($AddNavBar) {
    print "<p>\n";
    my @MeetingOrderIDs = &FetchMeetingOrdersByConferenceID($ConferenceID);
    @MeetingOrderIDs = sort MeetingOrderIDByOrder @MeetingOrderIDs; 
    foreach $MeetingOrderID (@MeetingOrderIDs) { # Loop over sessions/breaks
      my $SessionID = $MeetingOrders{$MeetingOrderID}{SessionID};
      if ($SessionID) {
        &FetchSessionByID($SessionID);

        my $SessionName = $Sessions{$SessionID}{Title};
	   $SessionName =~ s/\s+/&nbsp;/;
	my $SessionLink = "<a href=\"#$SessionID\">$SessionName</a>";  
        print "[&nbsp;",$SessionLink,"&nbsp;]\n";
      }
    }
  }
     
  if ($Conferences{$ConferenceID}{Preamble}) {
    print "<p>\n";
    print "<table width=80%><tr><td>\n";
    print &Paragraphize($Conferences{$ConferenceID}{Preamble}),"\n";
    print "</td></tr></table>\n";
  }
  print "<p>\n";
  
  if ($AddTalkLink && &CanModifyMeeting($ConferenceID)) {
    print "(<a href=\"$DocumentAddForm?conferenceid=$ConferenceID\">Upload a document</a> ".
          "to this meeting or conference)\n";
  }
  
  print "</center><hr width=95%>\n";
}

sub PrintMeetingEpilogue($) {
  my ($ConferenceID) = @_;

  require "Utilities.pm";
  
  print "<p><center>\n";
  print "<table width=80%><tr><td>\n";
  print &Paragraphize($Conferences{$ConferenceID}{Epilogue}),"\n";
  print "</td></tr></table>\n";
  print "</center><p>\n";
  
  print "</center><hr width=95%>\n";
}

sub PrintSessionInfo ($) {
  my ($SessionID) = @_;
  
  require "TalkSQL.pm";
  require "SQLUtilities.pm";
  
  &FetchSessionByID($SessionID);
  
  print "<tr valign=top>\n";
  print "<td><a href=\"$DisplayMeeting?sessionid=$SessionID\">";
  print "$Sessions{$SessionID}{Title}</a></td>\n";
  print "<td>",&EuroDateHM($Sessions{$SessionID}{StartTime}),"</td>\n";
  print "<td>",$Sessions{$SessionID}{Description},"</td>\n";
  print "<td>",$Sessions{$SessionID}{Location},"</td>\n";
  print "</tr>\n";
}

sub PrintSessionSeparatorInfo ($) {
  my ($SessionSeparatorID) = @_;
  
  require "TalkSQL.pm";
  require "SQLUtilities.pm";
  
  &FetchSessionSeparatorByID($SessionSeparatorID);
  
  print "<tr valign=top>\n";
  print "<td>$SessionSeparators{$SessionSeparatorID}{Title}</td>\n";
  print "<td>",&EuroDateHM($SessionSeparators{$SessionSeparatorID}{StartTime}),"</td>\n";
  print "<td>",$SessionSeparators{$SessionSeparatorID}{Description},"</td>\n";
  print "<td>",$SessionSeparators{$SessionSeparatorID}{Location},"</td>\n";
  print "</tr>\n";
}

sub NewMeetingLink ($) {
  my ($ConferenceID) = @_;
    
  my $URL = "$DisplayMeeting?conferenceid=$ConferenceID";
  my $Link  = "<a href=\"$URL\">";
     $Link .= $Conferences{$ConferenceID}{Title};
     $Link .= "</a>";
        
  return $Link;
}

sub ModifyMeetingLink ($) {
  my ($ConferenceID) = @_;
    
  my $URL = "$MeetingModify?conferenceid=$ConferenceID";
  my $Title;
  if ($Conferences{$ConferenceID}{Title}) {
    $Title = $Conferences{$ConferenceID}{Title};
  } else {
    my $MinorTopicID = $Conferences{$ConferenceID}{Minor};  
    $Title = $MinorTopics{$MinorTopicID}{LONG};
  }  
  
  my $Link  = "<a href=\"$URL\">";
     $Link .= $Title;
     $Link .= "</a>";
        
  return $Link;
}

sub OrphanMeetingList {
  my ($Mode) = @_;
  
  require "Sorts.pm";

  my @ConferenceIDs = keys %Conferences;
  my @OrphanConferenceIDs = ();
  foreach my $ConferenceID (@ConferenceIDs) {
    unless ($Conferences{$ConferenceID}{Minor}) {
      push @OrphanConferenceIDs,$ConferenceID;
    }  
  }

#  my @OrphanConferenceIDs = sort byTopic keys @OrphanConferenceIDs;
#FIXME add sort

  print "<b>More Meetings</b>\n";
  print "<ul>\n";
  foreach my $ConferenceID (@OrphanConferenceIDs) {
    my $MeetingLink;
    if ($Mode eq "modify") {
      $MeetingLink = &ModifyMeetingLink($ConferenceID);
    } else {
      $MeetingLink = &NewMeetingLink($ConferenceID);
    }
    print "<li>$MeetingLink</li>\n";
  }  
  print "</ul>\n";
}

sub AllMeetingsTable (;$) {
  
  my ($Mode) = @_;
  
  require "Sorts.pm";
  require "TopicSQL.pm";
  require "TopicHTML.pm";
  
  &SpecialMajorTopics;
  
  my $NCols = 3;
  my @MajorTopicIDs = (@GatheringMajorIDs,0);

  my $Col   = 0;
  my $Row   = 0;
  print "<table cellpadding=10>\n";
  foreach my $MajorID (@MajorTopicIDs) {
    unless ($Col % $NCols) {
      if ($Row) {
        print "</tr>\n";
      }  
      print "<tr valign=top>\n";
      ++$Row;
    }
    print "<td>\n";
    if ($MajorID) {
      if ($Mode eq "modify") {
        &MeetingsByMajorTopic($MajorID,"modify");
      } else {
        &TopicsByMajorTopic($MajorID);
      }  
    } else {
      &OrphanMeetingList($Mode);
    }  
    print "</td>\n";
    ++$Col;
  }  
  print "</tr>\n";
  print "</table>\n";
}

sub MeetingsByMajorTopic ($;$) { #FIXME: Can I combine with Orphan meetings?
  my ($MajorID,$Mode) = @_;
  
  require "TopicSQL.pm";
  require "Sorts.pm";
  
  my @ConferenceIDs = keys %Conferences;
  my @DisplayConferenceIDs = ();
  foreach my $ConferenceID (@ConferenceIDs) {
    my $MinorID = $Conferences{$ConferenceID}{Minor};
    &FetchMinorTopic($MinorID);
    # FIXME: We should probably allow modification of conferences not fully 
    #        setup
    if ($MinorID && $MinorTopics{$MinorID}{MAJOR} == $MajorID &&
        ($Conferences{$ConferenceID}{Title} || $Mode eq "modify")) { 
      push @DisplayConferenceIDs,$ConferenceID;
    }  
  }

  @DisplayConferenceIDs = sort ConferenceIDByDate @DisplayConferenceIDs;
#FIXME add sort

  print "<b>$MajorTopics{$MajorID}{SHORT}</b>\n";
  print "<ul>\n";
  foreach my $ConferenceID (@DisplayConferenceIDs) {
    my $MeetingLink;
    if ($Mode eq "modify") {
      $MeetingLink = &ModifyMeetingLink($ConferenceID);
    } else {
      $MeetingLink = &NewMeetingLink($ConferenceID);
    }
    print "<li>$MeetingLink</li>\n";
  }  
  print "</ul>\n";
}
 

1;
