sub byKeywordGroup {
  $KeywordGroups{$a}{Short} cmp $KeywordGroups{$b}{Short};
}    

sub byKeyword {
  $Keywords{$a}{Short} cmp $Keywords{$b}{Short};
}    

1;
