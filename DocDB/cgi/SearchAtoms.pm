sub TextSearch {
  my ($Field,$Mode,$Words) = @_;
  
  my $Phrase = "";
  my $Join;
  my $Delimit;
  my @Atoms = ();
  
  if ($Mode eq "anysub" || $Mode eq "allsub") {
    my @Words = split /\s+/,$Words;
    foreach $Word (@Words) {
      $Word =~ tr/[A-Z]/[a-z]/;
      push @Atoms,"LOWER($Field) like \"%$Word%\"";
    }  
  }

  if      ($Mode eq "anysub") {
    $Join = " OR ";
  } elsif ($Mode eq "allsub") {
    $Join = " AND ";
  }

  $Phrase = join $Join,@Atoms;  
  
  if ($Phrase) {$Phrase = "($Phrase)";}
  
  return $Phrase;
}

1;
