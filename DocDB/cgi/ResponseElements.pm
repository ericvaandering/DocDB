sub AuthorListByID {
  my @AuthorIDs = @_;
  
  if (@AuthorIDs) {
    print "<b>Authors:</b><br>\n";
    print "<ul>\n";
    foreach $AuthorID (@AuthorIDs) {
      &FetchAuthor($AuthorID);
      print "<li> $Authors{$AuthorID}{FULLNAME} </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Authors:</b> none<br>\n";
  }
  print "<p>\n";
}

sub RequesterByID {
  my ($requesterID) = @_;
  &FetchAuthor($requesterID);
  
  print "<b>Requested by:</b> ";
  print "$Authors{$requesterID}{FULLNAME}<br>\n";
  print "<p>\n";
}

sub TopicListByID {
  my @topicIDs = @_;
  if (@topicIDs) {
    print "<b>Topics:</b><br>\n";
    print "<ul>\n";
    foreach $topicID (@topicIDs) {
      &FetchMinorTopic($topicID);
      print "<li> $MinorTopics{$topicID}{FULL} </li>\n";
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

sub EuroDate {
  my ($sql_datetime) = @_;
  unless ($sql_datetime) {return "";}
  
  my ($date,$time) = split /\s+/,$sql_datetime;
  my ($year,$month,$day) = split /\-/,$date;
  $return_date = "$day ".("Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec")[$month-1].
                 " $year"; 
  return $return_date;
}

sub EuroDateTime {
  my ($sql_datetime) = @_;
  unless ($sql_datetime) {return "";}
  
  my ($date,$time) = split /\s+/,$sql_datetime;
  my ($year,$month,$day) = split /\-/,$date;
  $return_date = "$time ".
                 "$day ".("Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec")[$month-1].
                 " $year"; 
  return $return_date;
}

1;
