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
  my @MeetingOrderIDs = @_; # Or do I need to dereference?
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("sessions");
  print "Sessions:</a></b><p> \n";
  print "<table cellpadding=3>\n";
  print "<tr valign=top>\n";
  print "<th><b><a "; &HelpLink("meetingorder");     print "Order</a></td>\n";
  print "<th><b><a "; &HelpLink("meetingseparator"); print "Separator</a></td>\n";
  print "<th><b><a "; &HelpLink("sessioninfo");      print "Start Date and Time</a></td>\n";
  print "<th><b><a "; &HelpLink("sessioninfo");      print "Session Title</a></td>\n";
  print "<th><b><a "; &HelpLink("sessioninfo");      print "Description of Session</a></td>\n";
  print "<th><b><a "; &HelpLink("sessiondelete");    print "Delete</a></td>\n";
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
    if (grep /n/,$MeetingOrderID) {# Erase defaults
      $SessionDefaultDateTime    = "";
      $SessionDefaultTitle       = "";
      $SessionDefaultDescription = "";
      $SessionSeparatorDefault = "";
    } else { # Key off Meeting Order IDs, do differently for Sessions and Separators
      if ($MeetingOrders{$MeetingOrderID}{SessionID}) {
        my $SessionID = $MeetingOrders{$MeetingOrderID}{SessionID};
	$SessionDefaultDateTime    = $Sessions{$SessionID}{StartTime};
	$SessionDefaultTitle       = $Sessions{$SessionID}{Title};
	$SessionDefaultDescription = $Sessions{$SessionID}{Description};
	$SessionSeparatorDefault = "No";
      } elsif ($MeetingOrders{$MeetingOrderID}{SessionSeparatorID}) {
        my $SessionSeparatorID = $MeetingOrders{$MeetingOrderID}{SessionSeparatorID};
	$SessionDefaultDateTime    = $Sessions{$SessionSeparatorID}{StartTime};
	$SessionDefaultTitle       = $Sessions{$SessionSeparatorID}{Title};
	$SessionDefaultDescription = $Sessions{$SessionSeparatorID}{Description};
	$SessionSeparatorDefault = "Yes";
      }
    } 
    $SessionOrderDefault = $SessionOrder;  
    
    print "<tr valign=top>\n";
    print $query -> hidden(-name => 'meetingorderid', -default => $MeetingOrderID);
    print "<td align=center>\n"; &SessionOrder; print "</td>\n";
    print "<td align=center>\n"; &SessionSeparator($MeetingOrderID) ; print "</td>\n";
    print "<td>\n"; &SessionDateTimePullDown; print "</td>\n";
    print "<td>\n"; &SessionTitle;            print "</td>\n";
    print "<td>\n"; &SessionDescription;      print "</td>\n";
    print "<td align=center>\n"; &SessionDelete($MeetingOrderID) ; print "</td>\n";
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
    $DefaultMonth = $Month;
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

  print $query -> popup_menu (-name => 'sessionday',  -values => \@days,  -default => $DefaultDay);
  print $query -> popup_menu (-name => 'sessionmonth',-values => \@months,-default => $AbrvMonths[$DefaultMonth]);
  print $query -> popup_menu (-name => 'sessionyear', -values => \@years, -default => $DefaultYear);
  print "<b> - </b>\n";
  print $query -> popup_menu (-name => 'sessionhour', -values => \@hours, -default => $DefaultHour);
}

sub SessionOrder {
  print $query -> textfield (-name => 'sessionorder', -default => $SessionOrderDefault, 
                             -size => 4, -maxlength => 5);
}

sub SessionSeparator ($) {
  my ($MeetingOrderID) = @_;

  if ($SessionSeparatorDefault eq "Yes") {
    # May not be needed, MeetingOrderID should tell me.
    print $query -> hidden(-name => 'sessiontype', -default => 'Separator');
    print "Yes\n";	      
  } elsif ($SessionSeparatorDefault eq "No") {
    print $query -> hidden(-name => 'sessiontype', -default => 'Session');
    print "No\n";	      
  } else {
    print $query -> hidden(-name => 'sessiontype', -default => 'Open');
    print $query -> checkbox(-name => "sessionseparator", -value => "$MeetingOrderID", -label => 'Yes');
  }
}

sub SessionDelete ($) {
  my ($MeetingOrderID) = @_;

  if ($SessionSeparatorDefault) {
    print "&nbsp\n";
  } else {
    print $query -> checkbox(-name => "sessiondelete", -value => "$MeetingOrderID", -label => 'Yes');
  }
}

sub SessionTitle {
  print $query -> textfield (-name => 'sessiontitle', -default => $SessionTitleDefault, 
                             -size => 35, -maxlength => 128);
}

sub SessionDescription {
  print $query -> textarea (-name => 'sessiondescription',-default => $SessionDescriptionDefault, 
                            -columns => 30, -rows => 3);
}

1;
