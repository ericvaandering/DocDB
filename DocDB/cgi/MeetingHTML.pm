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

sub ConferenceIntroBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("confintro");
  print "Meeting Preamble:</a></b><br> \n";
  print $query -> textarea (-name => 'introtext',
                            -columns => 50, -rows => 5);
};

sub ConferenceDiscBox {
  require "Scripts.pm";
  print "<b><a ";
  &HelpLink("confdisc");
  print "Meeting Epilog:</a></b><br> \n";
  print $query -> textarea (-name => 'disctext',
                            -columns => 50, -rows => 5);
};

sub SessionEntryForm {
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
  print "</tr>\n";
  for (my $Session=1;$Session<=$InitialSession;++$Session) {
    print "<tr valign=top>\n";
    print "<td align=center>\n"; &SessionOrder($Session) ; print "</td>\n";
    print "<td align=center>\n"; &SessionSeparator($Session) ; print "</td>\n";
    print "<td>\n"; &SessionDateTimePullDown; print "</td>\n";
    print "<td>\n"; &SessionTitle;            print "</td>\n";
    print "<td>\n"; &SessionDescription;      print "</td>\n";
    print "</tr>\n";
  }
  print "</table>\n";
}

sub SessionDateTimePullDown {
  my (undef,undef,undef,$day,$mon,$year) = localtime(time);
  $year += 1900;
  
  my @days = ();
  for ($i = 1; $i<=31; ++$i) {
    push @days,$i;
  }  

  my @months = @AbrvMonths;

  my @years = ();
  for ($i = $FirstYear; $i<=$year+2; ++$i) { # $FirstYear - current year
    push @years,$i;
  }  

  my @hours = ();
  for (my $Hour = 7; $Hour<=20; ++$Hour) {
    for (my $Min = 0; $Min<=59; $Min=$Min+15) {
      push @hours,sprintf "%2.2d:%2.2d",$Hour,$Min;
    }  
  }  

  print $query -> popup_menu (-name => 'sessionday',  -values => \@days,  -default => $day);
  print $query -> popup_menu (-name => 'sessionmonth',-values => \@months,-default => $AbrvMonths[$mon]);
  print $query -> popup_menu (-name => 'sessionyear', -values => \@years, -default => $year);
  print "<b> - </b>\n";
  print $query -> popup_menu (-name => 'sessionhour', -values => \@hours, -default => $hour);
}

sub SessionOrder ($) {
  my ($SessionOrderDefault) = @_;
  print $query -> textfield (-name => 'sessionorder', -default => $SessionOrderDefault, 
                             -size => 3, -maxlength => 4);
}

sub SessionSeparator ($) {
  my ($Order) = @_;
#  print $query -> checkbox(-name => "separator", -value => $Order, -checked => 'checked', -label => '');
  print $query -> checkbox(-name => "separator", -value => $Order, -label =>
  'Yes');
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
