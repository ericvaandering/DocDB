sub HTMLPrintEnv {
  print "<table>\n"; 
  foreach my $key (keys %ENV) {
    print "<tr><td>$key<td>$ENV{$key}\n";
  }  
  print "</table>\n"; 
}

sub HTMLPrintParams {
  print "<table>\n"; 
  foreach my $key (keys %params) {
    print "<tr><td>$key<td>$params{$key}\n";
  }  
  print "</table>\n"; 
}

sub HTMLPrintKeys {
  print "<table>\n"; 
  foreach my $key (keys %params) {
    print "<tr><td>$key\n";
  }  
  print "</table>\n"; 
}

sub DBPrint {
  print @_,"<br>\n";
}

1;
