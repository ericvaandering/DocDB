sub CheckSQLDate ($) {
  require "WebUtilities.pm";
  my ($Date) = @_;
  my $Status = 1;
  unless (grep /^(\d+)\-(\d+)\-(\d+)$/,$Date) {
    $Status = 0;
  }
  ($Year,$Month,$Day) = split /-/,$Date;
  
  unless (&ValidDate($Day,$Month,$Year)) {
    $Status = 0;
  } 
  return $Status;
}

1;
