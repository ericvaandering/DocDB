sub DateTimePullDown {
  my ($sec,$min,$hour,$day,$mon,$year) = localtime(time);
  $year += 1900;
  $min = (int (($min+3)/5))*5; # Nearest five minutes
  
  my @days = ();
  for ($i = 1; $i<=31; ++$i) {
    push @days,$i;
  }  

  my @months = ("Jan","Feb","Mar","Apr","May","Jun",
             "Jul","Aug","Sep","Oct","Nov","Dec");

  my @years = ();
  for ($i = 1994; $i<=$year; ++$i) { # 1994 - current year
    push @years,$i;
  }  

  my @hours = ();
  for ($i = 0; $i<24; ++$i) {
    push @hours,$i;
  }  

  my @minutes = ();
  for ($i = 0; $i<=55; $i=$i+5) {
    push @minutes,(sprintf "%2.2d",$i);
  }  
  
  print "<b><a ";
  &HelpLink("overdate");
  print "Date & Time:</a></b><br> \n";
  print $query -> popup_menu (-name => 'overday',-values => \@days, -default => $day);
  print $query -> popup_menu (-name => 'overmonth',-values => \@months, -default => $months[$mon]);
  print $query -> popup_menu (-name => 'overyear',-values => \@years, -default => $year);
  print "<br>\n";
  print $query -> popup_menu (-name => 'overhour',-values => \@hours, -default => $hour);
  print "<b> : </b>\n";
  print $query -> popup_menu (-name => 'overmin',-values => \@minutes, -default => $min);
}

sub TitleBox {
  print "<b><a ";
  &HelpLink("title");
  print "Title:</a></b><br> \n";
  print $query -> textfield (-name => 'title', -default => $TitleDefault, 
                             -size => 80, -maxlength => 240);
};

sub PubInfoBox {
  print "<b><a ";
  &HelpLink("pubinfo");
  print "Publication information:</a></b><br> \n";
  print $query -> textarea (-name => 'pubinfo', -default => $PubInfoDefault,
                            -columns => 50, -rows => 3);
};

sub AbstractBox {
  print "<b><a ";
  &HelpLink("abstract");
  print "Abstract:</a></b><br> \n";
  print $query -> textarea (-name => 'abstract', -default => $AbstractDefault,
                            -columns => 50, -rows => 6);
};

sub SingleUploadBox {
  print "<table cellpadding=3>\n";
  print "<tr><td colspan=2><b><a ";
  &HelpLink("fileupload");
  print "File upload:</a></b><br></td></tr>\n";
  for (my $i=1;$i<=$NumberUploads;++$i) {
    print "<tr><td align=right>\n";
    print "<a "; &HelpLink("localfile"); print "<b>File:</b></a>\n";
    print "</td>\n";
    print "<td>\n";
    print $query -> filefield(-name => "single_upload", -size => 60,
                              -maxlength=>250);
    print "</td></tr>\n";
    print "<tr><td align=right>\n";
    print "<a "; &HelpLink("description"); print "<b>Description:</b></a>\n";
    print "</td>\n";
    print "<td>\n";
    print $query -> textfield (-name => 'filedesc', -size => 60, -maxlength => 128);
    print $query -> checkbox(-name => "root", -checked => 'checked', -label => '');
    print "<a "; &HelpLink("main"); print "Main?</a>\n";
    print "</td></tr>\n";
  }
  print "</table>\n";
};

sub SingleHTTPBox {
  print "<table cellpadding=3>\n";
  print "<tr><td colspan=4><b><a ";
  &HelpLink("httpupload");
  print "Upload by HTTP:</a></b><br> \n";
  print "</td><tr>\n";
  for (my $i=1;$i<=$NumberUploads;++$i) {
    print "<tr><td align=right>\n";
    print "<a "; &HelpLink("remoteurl"); print "<b>URL:</b></a>\n";
    print "</td>\n";
    print "<td colspan=3>\n";
    print $query -> textfield (-name => 'single_http', -size => 70, -maxlength => 240);
    print "</td></tr>\n";
    print "<tr><td align=right>\n";
    print "<a "; &HelpLink("description"); print "<b>Description:</b></a>\n";
    print "</td>\n";
    print "<td colspan=3>\n";
    print $query -> textfield (-name => 'filedesc', -size => 60, -maxlength => 128);
    print $query -> checkbox(-name => "root", -checked => 'checked', -label => '');
    print "<a "; &HelpLink("main"); print "Main?</a>\n";
    print "</td></tr>\n";
  }
  print "<tr><td align=right><b>User:</b></td>\n";
  print "<td>\n";
  print $query -> textfield (-name => 'http_user', -size => 20, -maxlength => 40);
  print "</td><td align=right>\n";
  print "<b>Password:</b></td>\n";
  print "<td>\n";
  print $query -> password_field (-name => 'http_pass', -size => 20, -maxlength => 40);
  print "</td></tr>\n";
  print "</table>\n";
};

sub ArchiveUploadBox {
  print "<table cellpadding=3>\n";
  print "<tr><td colspan=2><b><a ";
  &HelpLink("filearchive");
  print "Archive file upload:</a></b><br> \n";
  print "<tr><td align=right>\n";
  print "<b>Archive File:</b>\n";
  print "</td><td>\n";
  print $query -> filefield(-name => "single_upload", -size => 60,
                              -maxlength=>250);

  print "<tr><td align=right>\n";
  print "<b>Main file in archive:</b>\n";
  print "</td><td>\n";
  print $query -> textfield (-name => 'mainfile', -size => 70, -maxlength => 128);

  print "<tr><td align=right>\n";
  print "<b>Description of file:</b>\n";
  print "</td><td>\n";
  print $query -> textfield (-name => 'filedesc', -size => 70, -maxlength => 128);
  print "</td></tr></table>\n";
};

sub ArchiveHTTPBox {
  print "<table cellpadding=3>\n";
  print "<tr><td colspan=4><b><a ";
  &HelpLink("httparchive");
  print "Upload Archive by HTTP:</a></b><br> \n";

  print "<tr><td align=right><b>Archive URL:</b>\n";
  print "<td colspan=3>\n";
  print $query -> textfield (-name => 'single_http', -size => 70, -maxlength => 240);

  print "<tr><td align=right>\n";
  print "<b>Main file in archive:</b>\n";
  print "<td colspan=3>\n";
  print $query -> textfield (-name => 'mainfile', -size => 70, -maxlength => 128);

  print "<tr><td align=right>\n";
  print "<b>Description of file:</b>\n";
  print "<td colspan=3>\n";
  print $query -> textfield (-name => 'filedesc', -size => 70, -maxlength => 128);

  print "<tr><td align=right><b>User:</b>\n";
  print "<td>\n";
  print $query -> textfield (-name => 'http_user', -size => 20, -maxlength => 40);
  print "<td align=right>\n";
  print "<b>Password:</b>\n";
  print "<td>\n";
  print $query -> password_field (-name => 'http_pass', -size => 20, -maxlength => 40);
  print "</td></tr>\n";
  print "</table>\n";
};

sub RequesterSelect { # Scrolling selectable list for requesting author
  my @AuthorIDs = sort byLastName keys %Authors;
  my %AuthorLabels = ();
  my @ActiveIDs = ();
  foreach my $ID (@AuthorIDs) {
    if ($Authors{$ID}{ACTIVE}) {
      $AuthorLabels{$ID} = $Authors{$ID}{FULLNAME};
      push @ActiveIDs,$ID; 
    } 
  }  
  print "<b><a ";
  &HelpLink("requester");
  print "Requester:</a></b><br> \n";
  print $query -> scrolling_list(-name => "requester", -values => \@ActiveIDs, 
                                 -size => 10, -labels => \%AuthorLabels,                      
                                 -default => $RequesterDefault);
};

sub AuthorSelect { # Scrolling selectable list for authors
  my @AuthorIDs = sort byLastName keys %Authors;
  my %AuthorLabels = ();
  my @ActiveIDs = ();
  foreach my $ID (@AuthorIDs) {
    if ($Authors{$ID}{ACTIVE}) {
      $AuthorLabels{$ID} = $Authors{$ID}{FULLNAME};
      push @ActiveIDs,$ID; 
    } 
  }  
  print "<b><a ";
  &HelpLink("authors");
  print "Authors:</a></b><br> \n";
  print $query -> scrolling_list(-name => "authors", -values => \@ActiveIDs, 
                                 -labels => \%AuthorLabels,
                                 -size => 10, -multiple => 'true',
                                 -default => @AuthorDefaults);
};

sub TopicSelect { # Scrolling selectable list for topics
  my @TopicIDs = sort byTopic keys %FullTopics;
  my %TopicLabels = ();
  foreach my $ID (@TopicIDs) {
    $TopicLabels{$ID} = $FullTopics{$ID}; # FIXME: get rid of FullTopics
  }  
  print "<b><a ";
  &HelpLink("topics");
  print "Topics:</a></b><br> \n";
  print $query -> scrolling_list(-name => "topics", -values => \@TopicIDs, 
                                 -labels => \%TopicLabels,
                                 -size => 10, -multiple => 'true',
                                 -default => @TopicDefaults);
};

sub MultiTopicSelect { # Multiple scrolling selectable lists for topics
  my $NCols = 4;
  my @MajorIDs = sort byMajorTopic keys %MajorTopics;
  my @MinorIDs = keys %MinorTopics;

  print "<table cellpadding=5>\n";
  print "<tr><td colspan=$NCols align=center>\n";
  print "<b><a ";
  &HelpLink("topics");
  print "Topics:</a></b><br> \n";
  my $Col = 0;
  foreach $MajorID (@MajorIDs) {
    unless ($Col % $NCols) {
      print "<tr valign=top>\n";
    }
    print "<td><b>$MajorTopics{$MajorID}{SHORT}</b><br>\n";
    ++$Col;
    my @MatchMinorIDs = ();
    my %MatchLabels = ();
    foreach my $MinorID (@MinorIDs) {
      if ($MinorTopics{$MinorID}{MAJOR} == $MajorID) {
        push @MatchMinorIDs,$MinorID;
        $MatchLabels{$MinorID} = $MinorTopics{$MinorID}{SHORT};
      }  
    }
    if ($MajorTopics{$MajorID}{SHORT} eq "Collaboration Meetings") {
      @MatchMinorIDs = reverse sort byMeetingDate @MatchMinorIDs;
    } else {
      @MatchMinorIDs = sort byMinorTopic @MatchMinorIDs;
    }
    print $query -> scrolling_list(-name => "topics", 
             -values => \@MatchMinorIDs, -labels => \%MatchLabels,
             -size => 8, -multiple => 'true', -default => @TopicDefaults);
    print "</td>\n";
  }  
  print "</table>\n";
};

sub MajorTopicSelect { # Scrolling selectable list for major topics
  print "<b><a ";
  &HelpLink("majortopics");
  print "Major Topics:</a></b><br> \n";
  my @MajorIDs = keys %MajorTopics;
  my %MajorLabels = ();
  foreach my $ID (@MajorIDs) {
    $MajorLabels{$ID} = $MajorTopics{$ID}{SHORT};
  }  
  print $query -> scrolling_list(-name => "majortopic", -values => \@MajorIDs, 
                                 -labels => \%MajorLabels,  -size => 10);
};

sub InstitutionSelect { # Scrolling selectable list for institutions
  require "Sorts.pm";
  print "<b><a ";
  &HelpLink("institution");
  print "Institution:</a></b><br> \n";
  my @InstIDs = sort byInstitution keys %Institutions;
  my %InstLabels = ();
  foreach my $ID (@InstIDs) {
    $InstLabels{$ID} = $Institutions{$ID}{SHORT};
  }  
  print $query -> scrolling_list(-name => "inst", -values => \@InstIDs,
                                 -labels => \%InstLabels,  -size => 15);
};

sub DocTypeButtons {
# FIXME Get rid of fetches, make sure GetDocTypes is executed
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
  print $query -> radio_group(-columns => 3, -name => "doctype", 
                              -values => \%short_type, -default => "-");
};

sub SecurityList {
  my @GroupIDs = keys %SecurityGroups;
  my %GroupLabels = ();

  foreach my $ID (@GroupIDs) {
    $GroupLabels{$ID} = $SecurityGroups{$ID}{NAME};
  }  
  
  $ID = 0; # Add dummy security code "Public"
  push @GroupIDs,$ID; 
  $GroupLabels{$ID} = "Public";  
  @GroupIDs = sort numerically @GroupIDs;
  
  unless (@SecurityDefaults) {@SecurityDefaults = [1];}  # BTeV (hardcoded-bad)
  print "<b><a ";
  &HelpLink("security");
  print "Security:</a></b><br> \n";
  print $query -> scrolling_list(-name => 'security', -values => \@GroupIDs, 
                                 -labels => \%GroupLabels, 
                                 -size => 10, -multiple => 'true', 
                                 -default => @SecurityDefaults);
};

sub ShortDescriptionBox {
  print "<b><a ";
  &HelpLink("shortdescription");
  print "Short Description:</a></b><br> \n";
  print $query -> textfield (-name => 'short', 
                             -size => 20, -maxlength => 40);
};

sub LongDescriptionBox {
  print "<b><a ";
  &HelpLink("longdescription");
  print "Long Description:</a></b><br> \n";
  print $query -> textfield (-name => 'long', 
                             -size => 40, -maxlength => 120);
};

sub NameEntryBox {
  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("authorentry");
  print "First Name:</a></b><br> \n";
  print $query -> textfield (-name => 'first', 
                             -size => 20, -maxlength => 32);
  print "</td></tr>\n";
  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("authorentry");
  print "Initials:</a></b><br> \n";
  print $query -> textfield (-name => 'middle', 
                             -size => 10, -maxlength => 16);
  print "</td></tr>\n";
  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("authorentry");
  print "Last Name:</a></b><br> \n";
  print $query -> textfield (-name => 'lastname', 
                             -size => 20, -maxlength => 32);
  print "</td>\n";
  print "</tr></table>\n";
}

sub UpdateButton {
  my ($DocumentID) = @_;

#  unless (&CanModify) {return;}

  $query -> param('mode','update'); 
  $query -> param('docid',$DocumentID);
  
  print $query -> startform('POST',$DocumentAddForm);
  print $query -> hidden(-name => 'mode',  -default => 'update');
  print $query -> hidden(-name => 'docid', -default => $DocumentID);
  print $query -> submit (-value => "Update Document");
  print $query -> endform;
}

sub UpdateDBButton {
  my ($DocumentID) = @_;

#  unless (&CanModify) {return;}

  $query -> param('mode','updatedb');
  $query -> param('docid',$DocumentID);
  
  print $query -> startform('POST',$DocumentAddForm);
  print $query -> hidden(-name => 'mode',  -default => 'updatedb');
  print $query -> hidden(-name => 'docid', -default => $DocumentID);
  print $query -> submit (-value => "Update DB Info");
  print $query -> endform;
}

sub AddFilesButton {
  my ($DocumentID,$Version) = @_;

#  unless (&CanModify) {return;}

  $query -> param('docid',$DocumentID);
  $query -> param('version',$Version);
  
  print $query -> startform('POST',$AddFilesForm);
  print $query -> hidden(-name => 'version', -default => $Version);
  print $query -> hidden(-name => 'docid',   -default => $DocumentID);
  print $query -> submit (-value => "Add Files to Document");
  print $query -> endform;
}

1;
