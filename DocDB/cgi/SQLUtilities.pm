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

1;
