sub byKeywordGroup {
  $KeywordGroups{$a}{Short} cmp $KeywordGroups{$b}{Short};
}    

sub byKeyword {
  $KeywordLists{$a}{Short} cmp $KeywordLists{$b}{Short};
}    

sub byKey {
  
    $KeywordGroups{$KeywordLists{$a}{KeywordGroupID}}{Short} cmp
    $KeywordGroups{$KeywordLists{$b}{KeywordGroupID}}{Short}
                   or
        $KeywordLists{$a}{Short} cmp
        $KeywordLists{$b}{Short};
}    

1;
