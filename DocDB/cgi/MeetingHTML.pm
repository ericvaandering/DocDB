#        Name: MeetingHTML.pm
# Description: HTML producing routines for meetings and conferences
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub LocationBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("location");
  print "Location:</a></b><br> \n";
  print $query -> textfield (-name => 'location', 
                             -size => 20, -maxlength => 64);
};

sub ConferenceURLBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("confurl");
  print "URL:</a></b><br> \n";
  print $query -> textfield (-name => 'url', 
                             -size => 40, -maxlength => 64);
};

sub ConferencePreambleBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("confreamble");
  print "Meeting Preamble:</a></b><br> \n";
  print $query -> textarea (-name => 'meetpreamble',
                            -columns => 50, -rows => 5);
};

sub ConferenceEpilogueBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("confepilogue");
  print "Meeting Epilogue:</a></b><br> \n";
  print $query -> textarea (-name => 'meetepilogue',
                            -columns => 50, -rows => 5);
};

sub SessionEntryForm (@) {
  my @MeetingOrderIDs = @_; 

  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("sessions");
  print "Sessions:</a></b><p> \n";
  print "<table cellpadding=3>\n";
  print "<tr valign=top>\n";
  print "<th><b><a "; &HelpLink("meetingorder");     print "Order</a></b> or <br>\n";
  print "    <b><a "; &HelpLink("sessiondelete");    print "Delete</a></td>\n";
  print "<th><b><a "; &HelpLink("meetingseparator"); print "Separator</a></th>\n";
  print "<th><b><a "; &HelpLink("sessioninfo");      print "Start Date and Time</a></th>\n";
  print "<th><b><a "; &HelpLink("sessioninfo");      print "Session Title & Description</a></th>\n";
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
      $SessionDefaultDateTime    = "";
      $SessionDefaultTitle       = "";
      $SessionDefaultDescription = "";
      $SessionSeparatorDefault   = "";
    } else { # Key off Meeting Order IDs, do differently for Sessions and Separators
      if ($MeetingOrders{$MeetingOrderID}{SessionID}) {
        my $SessionID = $MeetingOrders{$MeetingOrderID}{SessionID};
	$SessionDefaultDateTime    = $Sessions{$SessionID}{StartTime};
	$SessionDefaultTitle       = $Sessions{$SessionID}{Title};
	$SessionDefaultDescription = $Sessions{$SessionID}{Description};
	$SessionSeparatorDefault   = "No";
      } elsif ($MeetingOrders{$MeetingOrderID}{SessionSeparatorID}) {
        my $SessionSeparatorID = $MeetingOrders{$MeetingOrderID}{SessionSeparatorID};
	$SessionDefaultDateTime    = $SessionSeparators{$SessionSeparatorID}{StartTime};
	$SessionDefaultTitle       = $SessionSeparators{$SessionSeparatorID}{Title};
	$SessionDefaultDescription = $SessionSeparators{$SessionSeparatorID}{Description};
	$SessionSeparatorDefault   = "Yes";
      }
    } 

    print "<tr valign=top>\n";
    $query -> param('meetingorderid',$MeetingOrderID);
    print $query -> hidden(-name => 'meetingorderid', -default => $MeetingOrderID);

    print "<td align=center rowspan=2>\n"; &SessionOrder; print "<p/>\n";
    &SessionModifyLink($MeetingOrderID) ; print "<p/>\n";
    &SessionDelete($MeetingOrderID) ; print "</td>\n";

    print "<td align=center>\n"; &SessionSeparator($MeetingOrderID) ; print "</td>\n";
    print "<td rowspan=2 align=right>\n"; &SessionDateTimePullDown; print "</td>\n";
    print "<td>\n"; &SessionTitle($SessionDefaultTitle);            print "</td>\n";
    print "</tr>\n";
    print "<tr valign=top>\n";
    print "<td colspan=2>&nbsp</td>\n";
    print "<td>\n"; &SessionDescription;      print "</td>\n";
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
    $DefaultDay   = $Day;
    $DefaultHour  = $Time;
  } else {
    $DefaultYear  = $Year;
    $DefaultMonth = $Month;
    $DefaultDay   = $Day;
    $DefaultHour  = "09:00";
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
    print $query -> checkbox(-name => "sessionseparator", -value => "$MeetingOrderID", -label => 'Yes');
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
    print "<a href=\"$SessionModify?sessionid=$SessionID\">Modify Talks</a>\n";
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

sub PrintSession ($;$) {
  my ($SessionID,$IsSingle) = @_;
  
  require "Sorts.pm";
  require "TalkSQL.pm";
  require "TalkHTML.pm";
  
  print "<center><h4>$Sessions{$SessionID}{Title}: \n";
  print "[ $SessionID ] \n"; # FIXME: debug
  print &EuroDateTime($Sessions{$SessionID}{StartTime});
  print "</h4></center> \n";
  print "<center> $Sessions{$SessionID}{Description} </center><p>\n";

  my @SessionTalkIDs   = &FetchSessionTalksBySessionID($SessionID);
  my @TalkSeparatorIDs = &FetchTalkSeparatorsBySessionID($SessionID);
  my @SessionOrderIDs  = &FetchSessionOrdersBySessionID($SessionID);
  my $ConferenceID     = $Sessions{$SessionID}{ConferenceID};
  
  # Getting TopicID will depend on re-factoring Conferences Hashes
  # my $MinorTopicID = 
  
  @IgnoreTopics = ($MinorTopicID);
  
# Sort talks and separators

  @SessionOrderIDs = sort SessionOrderIDByOrder @SessionOrderIDs;
  print "<table>\n";
  print "<tr>\n";
  print "<th>Start</th>\n";
  print "<th>Title</th>\n";
  print "<th>Note</th>\n";
  print "<th>Time</th>\n";
  print "</tr>\n";
  foreach my $SessionOrderID (@SessionOrderIDs) {
    # Accumulate time
    # Put titles in italics for unconfirmed talks
    if ($SessionOrders{$SessionOrderID}{TalkSeparatorID}) {
      my $TalkSeparatorID =  $SessionOrders{$SessionOrderID}{TalkSeparatorID};
      print "<tr>\n";
      print "<td>Sep $TalkSeparatorID $AccumulatedTime</td>\n";
      print "<td>$TalkSeparators{$TalkSeparatorID}{Title}</td>\n";
      print "<td>$TalkSeparators{$TalkSeparatorID}{Note}</td>\n";
      print "<td>$TalkSeparators{$TalkSeparatorID}{Time}</td>\n";
      print "</tr>\n";
    } elsif ($SessionOrders{$SessionOrderID}{SessionTalkID}) {
      my $SessionTalkID =  $SessionOrders{$SessionOrderID}{SessionTalkID};
      # One thing for confirmed talks, one thing for hinted, one thing for no idea
      if ($SessionTalks{$SessionTalkID}{DocumentID}) {
        &PrintSessionTalk($SessionTalkID,$AccumulatedTime);
      } else {
        print "<tr>\n";
        print "<td>Talk $SessionTalkID $AccumulatedTime</td>\n";
        print "<td>$SessionTalks{$SessionTalkID}{HintTitle}</td>\n";
        print "<td>$SessionTalks{$SessionTalkID}{Note}</td>\n";
        print "<td>$SessionTalks{$SessionTalkID}{Time}</td>\n";
        print "</tr>\n";
      } 
    }
  }
  print "</table><hr>\n";   
}

1;
