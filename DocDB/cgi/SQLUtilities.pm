#        Name: SQLUtilities.pm
# Description: Format conversions from SQL formats to human readable, etc. 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

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

sub EuroTimeHM($) {
  my ($SQLDatetime) = @_;
  unless ($SQLDatetime) {return "";}
  
  my ($Date,$Time) = split /\s+/,$SQLDatetime;
  my ($Year,$Month,$Day) = split /\-/,$Date;
  my ($Hour,$Min,$Sec) = split /:/,$Time;
  $ReturnDate = "$Hour:$Min"; 
  return $ReturnDate;
}

1;
