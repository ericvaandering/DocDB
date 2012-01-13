#        Name: $RCSfile$
# Description: Format conversions from SQL formats to human readable, etc.
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#

# Copyright 2001-2009 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub TruncateSeconds ($) { # Strip of seconds (from SQL) if present
  my ($Time) = @_;

  my ($Hours,$Minutes) = split /:/,$Time;

  $NewTime = "$Hours:$Minutes";
  return $NewTime;
}

sub SQLDateTime {
  my ($SQLDateTime) = @_;
  unless ($SQLDateTime) {return "";}

  my ($Date,$Time)     = split /\s+/,$SQLDateTime;
  my ($Year,$Mon,$Day) = split /\-/,$Date;
  my ($Hour,$Min,$Sec) = split /\:/,$Time;

  return ($Sec,$Min,$Hour,$Day,$Mon,$Year);
}

sub EuroTimeHM ($) {
  my ($SQLDatetime) = @_;
  unless ($SQLDatetime) {return "";}

  my ($Date,$Time) = split /\s+/,$SQLDatetime;
  my ($Year,$Month,$Day) = split /\-/,$Date;
  my ($Hour,$Min,$Sec) = split /:/,$Time;
  $ReturnDate = "$Hour:$Min";
  return $ReturnDate;
}

sub SQLNow (;%) {
  my %Params = @_;

  my $DateOnly = $Params{-dateonly}   || "";

  my ($sec,$min,$hour,$day,$mon,$year) = localtime(time);
  ++$mon; $year += 1900;
  my $SQL_NOW;
  if ($DateOnly) {
    $SQL_NOW = "$year-$mon-$day";
  } else {
    $SQL_NOW = "$year-$mon-$day $hour:$min:$sec";
  }
  return $SQL_NOW;
}

sub ConvertToDateTime {
  use DateTime;

  my ($ArgRef) = @_;
  my $MySQLTimeStamp = exists $ArgRef->{-MySQLTimeStamp} ? $ArgRef->{-MySQLTimeStamp} : "";
  my $MySQLDateTime  = exists $ArgRef->{-MySQLDateTime}  ? $ArgRef->{-MySQLDateTime} : "";

  my $DateTime;

  if (grep /:/,$MySQLTimeStamp) {
    $MySQLDateTime = $MySQLTimeStamp; # MySQL >= 4.1
  } else {
    $OldTimeStamp = $MySQLTimeStamp;  # MySQL <= 4.0
  }

  if ($MySQLDateTime) {
    my ($Date,$Time)     = split /\s+/,$MySQLDateTime;
    my ($Year,$Month,$Day) = split /\-/,$Date;
    my ($Hour,$Min,$Sec);
    if ($Time) {
      ($Hour,$Min,$Sec) = split /\:/,$Time;
    } else {
      ($Hour,$Min,$Sec) = (0,0,0);
    }
    $DateTime = DateTime -> new(year => $Year, month  => $Month,  day => $Day,
                                hour => $Hour, minute => $Min, second => $Sec,
                                time_zone => $LocalTimezone);
  } elsif ($OldTimeStamp) {
    my $Year  = substr  $OldTimeStamp,0,4;
    my $Month = substr  $OldTimeStamp,4,2;
    my $Day   = substr  $OldTimeStamp,6,2;
    my $Hour  = substr  $OldTimeStamp,8,2;
    my $Min   = substr  $OldTimeStamp,10,2;
    my $Sec   = substr  $OldTimeStamp,12,2;
    $DateTime = DateTime -> new(year => $Year, month  => $Month,  day => $Day,
                                hour => $Hour, minute => $Min, second => $Sec,
                                time_zone => $LocalTimezone);
  }

  return $DateTime;
}

sub DateTimeString {
  use DateTime;

  my ($ArgRef) = @_;

  my $ShowSeconds = exists $ArgRef->{-ShowSeconds} ? $ArgRef->{-ShowSeconds} : $FALSE;
  my $ShowTime    = exists $ArgRef->{-ShowTime}    ? $ArgRef->{-ShowTime}    : $TRUE;
  my $DateTime    = exists $ArgRef->{-DateTime}    ? $ArgRef->{-DateTime}    : DateTime->now();

  my $Format = "%d %b %Y";
  if (not $ShowTime) {
    # Do nothing
  } elsif ($ShowSeconds) {
    $Format .= ", %T";
  } else {
    $Format .= ", %R";
  }

  my $String = $DateTime->strftime($Format);
  return $String;
}

1;
