sub HTMLPrintenv {
  print "<table>\n"; 
  foreach $key (keys %ENV) {
    print "<tr><td>$key<td>$ENV{$key}\n";
  }  
  print "</table>\n"; 
}

1;
