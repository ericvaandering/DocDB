sub AuthorListByID {
  my @authorIDs = @_;
  
  if ($#authorIDs + 1) {
    print "<b>Authors:</b><br>\n";
    print "<ul>\n";
    foreach $authorID (@authorIDs) {
      print "<li> $names{$authorID} </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Authors:</b> none<br>\n";
  }
  print "<p>\n";
}

sub RequestorByID {
  my ($requestorID) = @_;
  
  print "<b>Requested by:</b> ";
  print "$names{$requestorID}<br>\n";
  print "<p>\n";
}

sub TopicListByID {
  my @topicIDs = @_;
  if ($#topicIDs + 1) {
    print "<b>Topics:</b><br>\n";
    print "<ul>\n";
    foreach $topicID (@topicIDs) {
      print "<li> $minor_topics{$topicID}{FULL} </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Topics:</b> none<br>\n";
  }
  print "<p>\n";
}

sub PrintAbstract {
  my ($abstract) = @_;
  if ($abstract) {
    print "<b>Abstract:</b><br>\n";
    print "$abstract<br>\n";
  } else {
    print "<b>Abstract:</b> none<br>\n";
  }
  print "<p>\n";
}

sub EndPage {
  my @errors = @_;
  print "<b>There was an error processing your request:</b><br>\n";
  foreach $message (@errors) {
    print "<dt><b>$message </b>\n";
  }  
  print $query->end_html;
  exit;
}

sub FullDocumentID {
  my ($documentID) = @_;
  return "BTeV-doc-$documentID";
}  

sub FileLink {
  my ($documentID,$version,$shortfile) = @_;
  $base_url = &GetURLDir($documentID,$version);
  return "<a href=\"$base_url$shortfile\">$shortfile</a>";
}  

1;
