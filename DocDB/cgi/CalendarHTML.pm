# Author Eric Vaandering (ewv@fnal.gov)

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

sub CalendarLink (%) {
  my %Params = @_;
  
  my $Month = $Params{-month} || 0;
  my $Year  = $Params{-year}  || 0;
  my $Day   = $Params{-day}   || 0;
  my $Text  = $Params{-text}  || "Calendar";
  my $Class = $Params{-class} || "";
  
  my $Link = "<a ";
  if ($Class) {
    $Link .= "class=\"Date\" ";
  }
  $Link .= "href=\"".$ShowCalendar;
                 
  if ($Day && $Month && $Year) {
    $Link .= "?year=$Year&amp;month=$Month&amp;day=$Day\">";
  } elsif ($Month && $Year) {
    $Link .= "?year=$Year&amp;month=$Month\">";
  } elsif ($Year) {
    $Link .= "?year=$Year\">";
  }  
  $Link .= $Text."</a>";  
}

sub PrintCalendar {
  use DateTime;
  require "Sorts.pm";
  
  my %Params = @_;
  
  my $Month = $Params{-month};
  my $Year  = $Params{-year};
  my $Type  = $Params{-type} || "month";

  my $DaysInMonth = DateTime -> last_day_of_month(year => $Year, month => $Month) -> day();
  my $FirstDay    = DateTime -> new(year => $Year, month => $Month, day => 1);
  my $MonthName   = $FirstDay -> month_name();
  my $Today       = DateTime ->today();

  my $Class = "ByMonth";
  if ($Type eq "year") {  
    $Class = "InYear";
  }
  
  print "<table class=\"Calendar $Class\">";

  if ($Type eq "year") {
    my $MonthLink = &CalendarLink(-year => $Year, -month => $Month, -text => $MonthName);
    print "<tr><th colspan=\"7\">$MonthLink</th></tr>\n";
  } elsif ($Type eq "month") {
    my $PrevMonth = $FirstDay -> clone();
       $PrevMonth -> add(months => -1);
    my $PrevMNum  = $PrevMonth -> month(); 
    my $PrevName  = $PrevMonth -> month_name(); 
    my $PrevYear  = $PrevMonth -> year(); 
    my $NextMonth = $FirstDay -> clone();
       $NextMonth -> add(months => 1);
    my $NextMNum  = $NextMonth -> month(); 
    my $NextName  = $NextMonth -> month_name(); 
    my $NextYear  = $NextMonth -> year(); 
    
    my $YearLink = &CalendarLink(-year => $Year, -text => $Year);
    my $CurrLink = "$MonthName $YearLink";
    my $PrevLink = &CalendarLink(-year => $PrevYear, -month => $PrevMNum, -text => "&laquo;$PrevName $PrevYear");
    my $NextLink = &CalendarLink(-year => $NextYear, -month => $NextMNum, -text => "$NextName $NextYear&raquo;");
    print "<tr class=\"MonthNav\">\n
            <th>$PrevLink</th>\n
            <th colspan=\"5\"><h1>$CurrLink</h1></th>\n
            <th>$NextLink</th>\n
          </tr>\n";
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

# Add blank cells for days in previous month

  my $DOW = $FirstDay -> day_of_week() + 1; if ($DOW ==8) {$DOW = 1;} 
  if ($DOW > 1) {
    my $NSkip = $DOW - 1; 
    print "<tr><td colspan=\"$NSkip\"></td>\n";
    $RowOpen = $TRUE;
  }    
  my $DaysLeft;

  for (my $Day = 1; $Day <= $DaysInMonth; ++$Day) {
    my $DateTime = DateTime -> new(year => $Year, month => $Month, day => $Day);
    my $SQLDate = $DateTime -> ymd(); 
    my $DOW = $DateTime -> day_of_week() + 1; # Convert from Monday week start
    if ($DOW ==8) {$DOW = 1;} 
       $DaysLeft = 7 - $DOW;
    my $DayName = $DateTime -> day_name();

# Start a new row on Sundays

    if ($DOW == 1) {
      if ($RowOpen) {
        print "</tr>\n";
        $RowOpen = $FALSE;
      }
      print "<tr>\n";
      $RowOpen = $TRUE;
    }

    my $TDClass = "$DayName";
    if ($DateTime == $Today) {
      $TDClass .= " Today";
    }  
    my @EventIDs = sort numerically &GetEventsByDate(-on => $SQLDate);
    print "<td class=\"$TDClass\">\n";
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
      my $AddLink = "<a class=\"AddEvent\" href=\"".$ShowCalendar."?year=$Year&amp;month=$Month&amp;day=$Day\">+</a>";            
      print $DayLink,"\n"; 
      print $AddLink,"\n";
      &PrintDayEvents(-day => $Day, -month => $Month, -year => $Year, -format => "summary");
    }  
    print "</td>\n";
  }

  if ($DaysLeft) {
    print "<td colspan=\"$DaysLeft\">&nbsp;</td>\n";
  }

  print "</tr></table>\n";
}

sub PrintDayEvents (%) {
  use DateTime;
  require "Sorts.pm";
  require "MeetingSQL.pm";
  require "Utilities.pm";
  require "EventUtilities.pm";
  
  my %Params = @_;
  
  my $Month  = $Params{-month};
  my $Year   = $Params{-year};
  my $Day    = $Params{-day};
  my $Format = $Params{-format} || "full"; # full || summary || multiday

  my $DateTime = DateTime -> new(year => $Year, month => $Month, day => $Day);
  my $SQLDate  = $DateTime -> ymd(); 

  my @EventIDs = sort numerically &GetEventsByDate(-on => $SQLDate);
  if ($Format eq "full") {
    print "<table class=\"CenteredTable MedPaddedTable\">\n";
  }  
  my $DayPrinted = $FALSE;
  
### Separate into ones with and without sessions, save sessions for this day

  my @AllDayEventIDs = ();
  my @AllSessionIDs  = ();
  my $EventID;
  foreach $EventID (@EventIDs) {
    my @SessionIDs = &FetchSessionsByConferenceID($EventID);
    if (@SessionIDs) {
      foreach my $SessionID (@SessionIDs) {
        my ($Sec,$Min,$Hour,$SessDay,$SessMonth,$SessYear) = &SQLDateTime($Sessions{$SessionID}{StartTime});
        if ($SessYear == $Year && $SessMonth == $Month && $SessDay == $Day) {
          push @AllSessionIDs,$SessionID;
        }
      }    
    } else {
      push @AllDayEventIDs,$EventID;
    }  
  }  

### Print Header if we are going to print something

  if ((@AllDayEventIDs || @AllSessionIDs) && $Format eq "full") {
    print "<tr>\n";
    print "<th>Time</th>\n";
    print "<th>Event</th>\n";
    print "<th>Location</th>\n";
    print "<th>External URL</th>\n";
    print "</tr>\n";
  } elsif ($Format eq "full") {
    print "<tr><td>No events for this day</td></tr>\n";
  }  
  
### Loop over all day/no time events
  
  foreach $EventID (@AllDayEventIDs) {
    my $EventLink = &EventLink(-eventid => $EventID, -format => "full");
    if ($EventLink) {
      if ($Format eq "full" || $Format eq "multiday" ) {
        print "<tr>\n";
        if ($Format eq "multiday" && !$DayPrinted) {
          $DayPrinted = $TRUE;
          print "<th class=\"LeftHeader\">$Day ",@AbrvMonths[$Month-1]," $Year</th>\n";
        } elsif ($Format eq "multiday") {
          print "<td>&nbsp;</td>\n";   
        }  
        print "<td>All day/no time</td>\n";
        print "<td>$EventLink</td>\n";
        print "<td>$Conferences{$ConferenceID}{Location}</td>\n";
        print "<td>$Conferences{$ConferenceID}{URL}</td>\n";
        print "</tr>\n";
      } elsif ($Format eq "summary") {
        print $EventLink,"\n";
      }   
    }  
  }  
  
  foreach my $SessionID (@AllSessionIDs) {
    my $StartTime = &EuroTimeHM($Sessions{$SessionID}{StartTime});
    my $EndTime   = &TruncateSeconds(&SessionEndTime($SessionID));
    if ($EndTime eq $StartTime) { 
      $EndTime = "";
    }  
    if ($Format eq "full" || $Format eq "multiday" ) {
      my $SessionLink = &SessionLink(-sessionid => $SessionID, -format => "full");
      print "<tr>\n";
      if ($Format eq "multiday" && !$DayPrinted) {
        $DayPrinted = $TRUE;
        print "<th class=\"LeftHeader\">$Day ",@AbrvMonths[$Month-1]," $Year</th>\n";
      } elsif ($Format eq "multiday") {
        print "<td>&nbsp;</td>\n";   
      }  
      print "<td>$StartTime &ndash; $EndTime</td>\n";
      print "<td>$SessionLink</td>\n";
      print "<td>$Sessions{$SessionID}{Location}</td>\n";
      print "<td>$Conferences{$ConferenceID}{URL}</td>\n";
      print "</tr>\n";
    } elsif ($Format eq "summary") {
      my $SessionLink = &SessionLink(-sessionid => $SessionID);
      print "<span class=\"Event\">$StartTime $SessionLink</span>\n";
    }   
  }  
  if ($Format eq "full") {
    print "</table>\n";
  }  
}

1;
