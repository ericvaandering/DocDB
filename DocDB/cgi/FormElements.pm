sub TitleBox {
  print "<b><a ";
  &HelpLink("title");
  print "Title:</a></b><br> \n";
  print $query -> textfield (-name => 'title', -size => 80, -maxlength => 240);
};

sub PubInfoBox {
  print "<b><a ";
  &HelpLink("pubinfo");
  print "Publication information:</a></b><br> \n";
  print $query -> textarea (-name => 'pubinfo', -columns => 50, -rows => 3);
};

sub AbstractBox {
  print "<b><a ";
  &HelpLink("abstract");
  print "Abstract:</a></b><br> \n";
  print $query -> textarea (-name => 'abstract', -columns => 50, -rows => 6);
};

sub SingleUploadBox {
  print "<b><a ";
  &HelpLink("fileupload");
  print "File upload:</a></b><br> \n";
  print $query -> filefield(-name => "single_upload", -size=>60,
                            -maxlength=>250);
};

sub SingleHTTPBox {
  print "<b><a ";
  &HelpLink("httpupload");
  print "Upload by URL:</a></b><br> \n";
  print $query -> textfield (-name => 'single_http', -size => 80, -maxlength => 240);
};

sub RequestorSelect { # Scrolling selectable list for requesting author
  print "<b><a ";
  &HelpLink("requestor");
  print "Requestor:</a></b><br> \n";
  print $query -> scrolling_list(-name => "requestor", -values => \%names, -size => 15);
};

sub AuthorSelect { # Scrolling selectable list for authors
  print "<b><a ";
  &HelpLink("authors");
  print "Authors:</a></b><br> \n";
  print $query -> scrolling_list(-name => "authors", -values => \%names, -size => 15, -multiple => 'true');
};


sub TopicSelect { # Scrolling selectable list for topics
  print "<b><a ";
  &HelpLink("topics");
  print "Topics:</a></b><br> \n";
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
  
  print "<b><a ";
  &HelpLink("doctype");
  print "Document type:</a></b><br> \n";
  print $query -> radio_group(-columns => 3, -name => "doctype", -values => \%short_type);
};

sub SecurityList {
  print "<b><a ";
  &HelpLink("security");
  print "Security:</a></b><br> \n";
  print $query -> scrolling_list(-name => 'security', -values => \@available_securities, 
                                 -size => 5, -multiple => 'true', -default => 'BTeV');
};

1;
