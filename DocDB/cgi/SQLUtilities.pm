#        Name: SQLUtilities.pm
# Description: Format conversions from SQL formats to human readable, etc. 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2007 Eric Vaandering, Lynn Garren, Adam Bryant

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


1;
