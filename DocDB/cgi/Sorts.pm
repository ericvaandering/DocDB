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

### All revisions and documents (of interest) must be fetched before calling
  
  my $adr = $DocRevIDs{$a}{$Documents{$a}{NVER}};
  my $bdr = $DocRevIDs{$b}{$Documents{$b}{NVER}};
  
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

sub DocumentByRequester {

### All documents (of interest) must be fetched before calling

  require "AuthorSQL.pm";

  my $adr = $Documents{$a}{REQUESTER};
  my $bdr = $Documents{$b}{REQUESTER};
  &FetchAuthor($adr);
  &FetchAuthor($bdr);
    
   $Authors{$adr}{LASTNAME} cmp $Authors{$bdr}{LASTNAME}
                            or
  $Authors{$adr}{FIRSTNAME} cmp $Authors{$bdr}{FIRSTNAME}
}

1;
