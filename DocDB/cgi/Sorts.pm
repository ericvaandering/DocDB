sub numerically {$a <=> $b;}

sub byMajorTopic {
  $MajorTopics{$a}{SHORT} cmp $MajorTopics{$b}{SHORT};
}    

sub byMinorTopic {
  $MinorTopics{$a}{SHORT} cmp $MinorTopics{$b}{SHORT};
}    

sub byMeetingDate {
  ($adays,$amonth,$ayear) = split /\s+/,$MinorTopics{$a}{SHORT};
  ($bdays,$bmonth,$byear) = split /\s+/,$MinorTopics{$b}{SHORT};
  ($aday) = split /\-/,$adays;
  ($bday) = split /\-/,$bdays;
  
                      $ayear <=> $byear
                             or
  $ReverseFullMonth{$amonth} <=> $ReverseFullMonth{$bmonth} 
                             or
                       $aday <=> $bday;            
}    

sub byTopic {
  $MajorTopics{$MinorTopics{$a}{MAJOR}}{SHORT} cmp
  $MajorTopics{$MinorTopics{$b}{MAJOR}}{SHORT}
                   or
        $MinorTopics{$a}{SHORT} cmp
        $MinorTopics{$b}{SHORT};
}    

sub byLastName {
   $Authors{$a}{LASTNAME} cmp $Authors{$b}{LASTNAME}
                          or
  $Authors{$a}{FIRSTNAME} cmp $Authors{$b}{FIRSTNAME};
}    

sub byInstitution {
  $Institutions{$a}{SHORT} cmp $Institutions{$b}{SHORT};
}    

sub DocumentByRevisionDate {

  require "DocumentSQL.pm";
  require "RevisionSQL.pm";

  &FetchDocument($a);
  &FetchDocument($b);
  my $adr = &FetchDocRevision($a,$Documents{$a}{NVER});
  my $bdr = &FetchDocRevision($b,$Documents{$b}{NVER});
  
  $adt = $DocRevisions{$adr}{DATE};
  $bdt = $DocRevisions{$bdr}{DATE};
  
  ($adate,$atime) = split /\s+/,$adt;
  ($bdate,$btime) = split /\s+/,$bdt;
  
  ($ayear,$amonth,$aday) = split /\-/,$adate;
  ($byear,$bmonth,$bday) = split /\-/,$bdate;
  
  ($ahour,$amin,$asec) = split /\-/,$atime;
  ($bhour,$bmin,$bsec) = split /\-/,$btime;
  
   $ayear <=> $byear
          or
  $amonth <=> $bmonth 
          or
    $aday <=> $bday
          or
   $ahour <=> $bhour
          or
    $amin <=> $bmin 
          or
    $asec <=> $bsec;            
}

1;
