sub ValidURL { # URL is valid
  my ($url) = @_;
  
  $ok = 0;
  $sep = "://";
  
  my ($service,$address) = split /$sep/,$url;
  
  unless ($service && $address) {
    return $ok;
  }
  unless (grep /^\s*[a-zA-z]+$/,$service) {
    return $ok;
  }    
  unless (grep /^[\-\w\~\;\/\?\=\&\$\.\+\!\*\'\(\)\,]+\s*$/, $address) { # no :,@
    return $ok;
  }  

  $ok = 1;
  return $ok;
}
  
sub ValidFileURL { # URL is valid and has file afterwards
  my ($url) = @_;
  
  $ok = 0;
  $sep = "://";
  
  my ($service,$address) = split /$sep/,$url;
  
  unless ($service && $address) {
    return $ok;
  }
  unless (grep /^\s*[a-zA-z]+$/,$service) {
    return $ok;
  }    
  unless (grep /^[\-\w\~\;\/\?\=\&\$\.\+\!\*\'\(\)\,]+\s*$/, $address) { # no :,@
    return $ok;
  }  
  if (grep /\/$/,$address) {
    return $ok;
  } 
  unless (grep /\//,$address) {
    return $ok;
  } 
   
  $ok = 1;
  return $ok;
}

sub ValidDate {
  my ($Day,$Month,$Year) = @_;
  
  my @MaxDays = (31,29,31,30,31,30,31,31,30,31,30,31);
  my $FebDays;
  
  $ok = 0;
  
  if ($Day < 1) {
    return $ok;
  }  
  if ($Day > $MaxDays[$Month-1]) {
    return $ok;
  }

# We're done if its not February
  
  if ($Month != 2) {
    $ok = 1;
    return $ok;
  }  

# Is it a leap year?
  
  if ($Year % 400 == 0) {
    $FebDays = 29;
  } elsif ($Year % 100 == 0) {
    $FebDays = 28      
  } elsif ($Year % 4 == 0) {
    $FebDays = 29      
  } else {
    $FebDays = 28 
  }       
  
  if ($Day > $FebDays) {
    return $ok;
  }
  
  $ok = 1;
  return $ok;  
}
  
1;
