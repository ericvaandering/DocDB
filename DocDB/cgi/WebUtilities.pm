sub ValidURL { # Returns a directory name
  my ($url) = @_;
  
  $ok = 0;
  $sep = "://";
  
  my ($service,$address) = split /$sep/,$url;
  
  unless ($service && $address) {
    return $ok;
  }
  unless (grep /^[a-zA-z]+$/,$service) {
    return $ok;
  }    
  unless (grep /^[\-\w\~\;\/\?\=\&\$\.\+\!\*\'\(\)\,]+$/, $address) { # no :,@
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
  
1;
