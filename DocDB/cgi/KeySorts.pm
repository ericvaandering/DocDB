sub byKeywordGroup {
  $KeywordGroups{$a}{SHORT} cmp $KeywordGroups{$b}{SHORT};
}    

sub byKeyword {
  $KeywordLists{$a}{SHORT} cmp $KeywordLists{$b}{SHORT};
}    

sub byKey {
  
    $KeywordGroups{$KeywordLists{$a}{KEYGRP}}{SHORT} cmp
    $KeywordGroups{$KeywordLists{$b}{KEYGRP}}{SHORT}
                   or
        $KeywordLists{$a}{SHORT} cmp
        $KeywordLists{$b}{SHORT};
}    

1;
