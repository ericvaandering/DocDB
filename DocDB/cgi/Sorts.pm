sub numerically {$a <=> $b;}

sub byMajorTopic {
  $MajorTopics{$MinorTopics{$a}{MAJOR}}{SHORT} cmp
  $MajorTopics{$MinorTopics{$b}{MAJOR}}{SHORT};
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
