sub AuthorListByID {
  
  my @authorIDs = @_;
  
  print "<b>Authors:</b><br>\n";
  print "<ul>\n";
  foreach $authorID (@authorIDs) {
    print "<li> $names{$authorID} </li>\n";
  }
  print "</ul>\n";

}

sub TopicListByID {
  
  my @topicIDs = @_;
  
  print "<b>Topics:</b><br>\n";
  print "<ul>\n";
  foreach $topicID (@topicIDs) {
    print "<li> $minor_topics{$topicID}{FULL} </li>\n";
  }
  print "</ul>\n";

}







1;
