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

sub EndPage {
  @errors = @_;
  print "<b>There was an error processing your request:</b><br>\n";
  foreach $message (@errors) {
    print "<dt><b>$message </b>\n";
  }  
  print $query->end_html;
  exit;
}

1;
