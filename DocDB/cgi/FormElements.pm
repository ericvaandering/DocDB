sub TitleBox {
  print "<b>Title:</b><br> \n";
  print $query -> textfield (-name => 'title', -size => 80, -maxlength => 240);
};

sub PubInfoBox {
  print "<b>Publication information:</b><br>  \n";
  print $query -> textarea (-name => 'pubinfo', -columns => 50, -rows => 3);
};

sub AbstractBox {
  print "<b>Abstract:</b><br>  \n";
  print $query -> textarea (-name => 'abstract', -columns => 50, -rows => 6);
};

sub SingleUploadBox {
  print "<b>File upload:</b><br>  \n";
  print $query -> filefield(-name => "single_upload", -size=>60,
                            -maxlength=>250);
};

sub RequestorSelect { # Scrolling selectable list for requesting author
  print "<b>Requestor:</b><br>\n";
  print $query -> scrolling_list(-name => "requestor", -values => \%names, -size => 15);
};

sub AuthorSelect { # Scrolling selectable list for authors
  print "<b>Authors:</b><br>\n";
  print $query -> scrolling_list(-name => "authors", -values => \%names, -size => 15, -multiple => 'true');
};


sub TopicSelect { # Scrolling selectable list for topics
  print "<b>Topics:</b><br>\n";
  print $query -> scrolling_list(-name => "topics", -values => \%full_topics, -size => 15, -multiple => 'true');
};

sub DocTypeButtons {
  my ($DocTypeID,$ShortType,$LongType);
  my $doctype_list  = $dbh->prepare("select DocTypeID,ShortType,LongType from DocumentType");
  $doctype_list -> execute;
  $doctype_list -> bind_columns(undef, \($DocTypeID,$ShortType,$LongType));
  while ($doctype_list -> fetch) {
    $doc_type{$DocTypeID}{SHORT} = $ShortType;
    $short_type{$DocTypeID}      = $ShortType;
    $doc_type{$DocTypeID}{LONG}  = $LongType;
  }
  @values = keys %short_type;
  
  print "<b>Document type:</b><br>\n";
  print $query -> radio_group(-columns => 3, -name => "doctype", -values => \%short_type);
};

sub SecurityList {
  print "<b>Security:</b><br>\n";
  print $query -> scrolling_list(-name => 'security', -values => \@available_securities, 
                                 -size => 5, -multiple => 'true', -default => 'BTeV');
};

1;
