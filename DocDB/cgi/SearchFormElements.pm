  $SearchModes{anysub} = "Any words as sub-string";
  $SearchModes{allsub} = "All words as sub-string";



sub TitleSearchBox {
  print "<tr><th align=right><a ";
  &HelpLink("wordsearch");
  print "Title:</a></th> \n";
  print "<td>\n";
  print $query -> textfield (-name      => 'titlesearch', 
                             -default   => $TitleSearchDefault, 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'titlesearchmode', 
                              -default => $TitleSearchModeDefault, 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub AbstractSearchBox {
  print "<tr><th align=right><a ";
  &HelpLink("wordsearch");
  print "Abstract:</a></th> \n";
  print "<td>\n";
  print $query -> textfield (-name      => 'abstractsearch', 
                             -default   => $TitleSearchDefault, 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'abstractsearchmode', 
                              -default => $TitleSearchModeDefault, 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub PubInfoSearchBox {
  print "<tr><th align=right><a ";
  &HelpLink("wordsearch");
  print "Publication Info:</a></th> \n";
  print "<td>\n";
  print $query -> textfield (-name      => 'pubinfosearch', 
                             -default   => $TitleSearchDefault, 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'pubinfosearchmode', 
                              -default => $TitleSearchModeDefault, 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub RequesterSearchBox { # Scrolling selectable list for requesting author
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
  print $query -> scrolling_list(-name => "requestersearch", -values => \@ActiveIDs, 
                                 -size => 10, -labels => \%AuthorLabels,                      
                                 -default => $RequesterDefault,
                                 -multiple => 'true');
};

sub DocTypeMulti {
# FIXME Get rid of fetches, make sure GetDocTypes is executed
  my %DocTypeLabels = ();
  foreach my $DocTypeID (keys %DocumentTypes) {
    $DocTypeLabels{$DocTypeID} = $DocumentTypes{$DocTypeID}{SHORT};
  }  
  print "<b><a ";
  &HelpLink("doctype");
  print "Document type:</a></b><br> \n";
  print $query -> scrolling_list(-size => 10, -name => "doctypemulti", 
                              -values => \%DocTypeLabels, -multiple => 'true');
};

sub DateRangePullDown {
  my ($sec,$min,$hour,$day,$mon,$year) = localtime(time);
  $year += 1900;
  $min = (int (($min+3)/5))*5; # Nearest five minutes
  
  my @days = ("--");
  for ($i = 1; $i<=31; ++$i) {
    push @days,$i;
  }  

  my @months = ("---","Jan","Feb","Mar","Apr","May","Jun",
             "Jul","Aug","Sep","Oct","Nov","Dec");

  my @years = ("----");
  for ($i = 1994; $i<=$year; ++$i) { # 1994 - current year
    push @years,$i;
  }  

  print $query -> popup_menu (-name => 'afterday',-values => \@days);    
  print $query -> popup_menu (-name => 'aftermonth',-values => \@months);
  print $query -> popup_menu (-name => 'afteryear',-values => \@years); 
  print " (Start)\n";
  print "<br><b><big>&nbsp;</big>&nbsp;and</b><br>\n";

  print $query -> popup_menu (-name => 'beforeday',-values => \@days);
  print $query -> popup_menu (-name => 'beforemonth',-values => \@months);
  print $query -> popup_menu (-name => 'beforeyear',-values => \@years);
  print " (End)\n";
}

sub MajorMinorSelect {
  print "<td>\n";
  my @MajorIDs = sort byMajorTopic keys %MajorTopics;
  my %MajorLabels = ();
  foreach my $ID (@MajorIDs) {
    $MajorLabels{$ID} = $MajorTopics{$ID}{SHORT};
  }  
  print $query -> scrolling_list(-name => "majortopic", -values => \@MajorIDs, 
                                 -labels => \%MajorLabels,  
                                 -size => 10, 
                                 -onChange => "selectProduct(this.form);",
                                 -multiple => 'true');
  print "</td>\n";
  
  print "<td colspan=2>\n";
  my @MinorIDs = sort byTopic keys %MinorTopics;
  my %MinorLabels = ();
  foreach my $ID (@MinorIDs) {
    $MinorLabels{$ID} = $MinorTopics{$ID}{FULL};
  }  
  print $query -> scrolling_list(-name => "minortopic", -values => \@MinorIDs, 
                                 -labels => \%MinorLabels,  
                                 -size => 10,
                                 -multiple => 'true');
  print "</td>\n";
}

sub LogicTypeButtons {
  my @values = ["AND","OR"];
  
  print "<b><a ";
  &HelpLink("logictype");
  print "Between Fields:</a></b> \n";
  print $query -> radio_group(-name => "outerlogic", 
                              -values => @values, -default => "AND");
  
  print "&nbsp;&nbsp;&nbsp;&nbsp;";
  
  print "<b><a ";
  &HelpLink("logictype");
  print "Within Fields:</a></b> \n";
  print $query -> radio_group(-name => "innerlogic", 
                              -values => @values, -default => "OR");
};



