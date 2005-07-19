sub PrintCalendar {
  use DateTime;
  
  my %Params = @_;
  
  my $Month = $Params{-month};
  my $Year  = $Params{-year};
  my $Type  = $Params{-type} || "month";

  my $DaysInMonth = DateTime -> last_day_of_month(year => $Year, month => $Month) -> day();
  my $FirstDay    = DateTime -> new(year => $Year, month => $Month, day => 1);
  my $MonthName   = $FirstDay -> month_name();
  

  my $Class = "ByMonth";
  if ($Type eq "year") {  
    $Class = "InYear";
  }
  
  print "<table class=\"Calendar $Class\">";

  if ($Type eq "year") {  
      print "<tr><th colspan=\"7\">$MonthName</th>\n</tr>\n";
  }    
  print "<tr>\n";
  foreach my $DayName ("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday") {
    if ($Type eq "year") {  
      print "<th class=\"$DayName InYearDays\">",substr($DayName,0,1),"</th>\n";
    } else {
      print "<th class=\"$DayName\">$DayName</th>\n";
    }
  }  
  print "</tr>\n";

  my $RowOpen;

  my $DOW = $FirstDay -> day_of_week() + 1; if ($DOW ==8) {$DOW = 1;} 
  if ($DOW > 1) {
    my $NSkip = $DOW - 1; 
    print "<tr><td colspan=\"$NSkip\"></td>\n";
    $RowOpen = $TRUE;
  }    
  my $DaysLeft;

  for  (my $Day = 1; $Day <= $DaysInMonth; ++$Day) {
    my $DateTime = DateTime -> new(year => $Year, month => $Month, day => $Day);
    my $SQLDate = $DateTime -> ymd(); 
    my $DOW = $DateTime -> day_of_week() + 1; 
    if ($DOW ==8) {$DOW = 1;} 
       $DaysLeft = 7 - $DOW;
    my $DayName = $DateTime -> day_name();
    if ($DOW == 1) {
      if ($RowOpen) {
        print "</tr>\n";
        $RowOpen = $FALSE;
      }
      print "<tr>\n";
      $RowOpen = $TRUE;
    }
    my @EventIDs = sort numerically &GetEventsByDate(-on => $SQLDate);
    print "<td class=\"$DayName\">\n";
    my $DayLink = "<a class=\"Date\" href=\"".$ShowCalendar."?year=$Year&amp;month=$Month&amp;day=$Day\">".
                  $DateTime -> day()."</a>";
    if ($Type eq "year") {
      if (@EventIDs) {
        print "$DayLink\n";
      } else {
        print "$Day\n";  
      }
    }
    if ($Type eq "month") {
      my $AddLink = "<span class=\"AddEvent\">[<a href=\"".$ShowCalendar."?year=$Year&amp;month=$Month&amp;day=$Day\">+</a>]</span>";            
      print $DayLink,"\n"; 
      print $AddLink,"\n";
      print "<br/>\n"; 
      if (@EventIDs) {
        foreach my $EventID (@EventIDs) {
          print &EventLink(-eventid => $EventID, -format => "full"),"<br/>";
        }  
      }  
    }  
    print "</td>\n";
  }

  if ($DaysLeft) {
    print "<td colspan=\"$DaysLeft\">&nbsp;</td>\n";
  }

  print "</tr></table>\n";
}

1;
