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
  my $Link;
  
  $Link = "<a class=\"Date\" href=\"".$ShowCalendar;
                 
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
  

  my $Class = "ByMonth";
  if ($Type eq "year") {  
    $Class = "InYear";
  }
  
  print "<table class=\"Calendar $Class\">";

  if ($Type eq "year") {
    my $MonthLink = "<a href=\"ShowCalendar?year=$Year&amp;month=$Month\">$MonthName</a>";
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
    
    my $CurrLink = "$MonthName <a href=\"ShowCalendar?year=$Year\">$Year</a>";
    my $PrevLink = "<a href=\"ShowCalendar?year=$PrevYear&amp;month=$PrevMNum\">$PrevName $PrevYear</a>";
    my $NextLink = "<a href=\"ShowCalendar?year=$NextYear&amp;month=$NextMNum\">$NextName $NextYear</a>";
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
