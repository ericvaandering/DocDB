sub numerically {$a <=> $b;}

sub byMajorTopic {
  $MajorTopics{$a}{SHORT} cmp $MajorTopics{$b}{SHORT};
}    

sub byMinorTopic {
  $MinorTopics{$a}{SHORT} cmp $MinorTopics{$b}{SHORT};
}    

sub byMeetingDate {
   my %ReverseFullMonth = 
   (January => 1,  February => 2,  March      => 3,
    April   => 4,  May      => 5,  June       => 6,
    July    => 7,  August   => 8,  September  => 9,
    October => 10, November => 11, December   => 12);
   
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

1;
