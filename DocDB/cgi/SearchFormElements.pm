#  Functions in this file:
#
#
#  TitleSearchBox
#    A box to type words/strings and a mode selecter for text searches 
#    on DocumentTitle
#    
#  AbstractSearchBox
#    A box to type words/strings and a mode selecter for text searches 
#    on Abstract
#   
#  KeywordSearchBox
#    A box to type words/strings and a mode selecter for text searches 
#    on Keywords
#   
#  PubInfoSearchBox
#    A box to type words/strings and a mode selecter for text searches 
#    on PublicationInfo
#   
#  RequesterSearchBox
#    A select box for searches on the requester. Unlike entry box, this 
#    has to be multi-selectable for ANDS/ORS
#   
#  DocTypeMulti
#    A select box for searches on document type. Unlike entry buttons, 
#    this has to be multi-selectable for ANDS/ORS
#   
#  DateRangePullDown
#    Two sets of pulldowns for defining a date range. Blanks are default
#    for tagging no search on date.
#   
#  MajorMinorSelect
#    Two multi-select boxes, one for major topics, one for minor topics.
#    These are tied together by TopicSearchScript so that when major topics
#    are selected, the list of minor topics is reduced. When only major topics
#    are selected, the search will be on major topic. When even a single minor
#    topic is selected, the search will be on the minor topic(s). 
#    
#  LogicTypeButtons
#    Two buttons allow the user to control whether the inner logic (multiple 
#    members of field) and the outer logic (between fields) are done with ANDs
#    or ORs.  

require "SearchModes.pm";

sub TitleSearchBox { # Box and mode selecter for searches on DocumentTitle
  print "<tr><th align=right><a ";
  &HelpLink("wordsearch");
  print "Title:</a></th> \n";
  print "<td>\n";
  print $query -> textfield (-name      => 'titlesearch', 
#                             -default   => $TitleSearchDefault, 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'titlesearchmode', 
#                              -default => $TitleSearchModeDefault, 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub AbstractSearchBox { # Field and mode selecter for searches on Abstract
  print "<tr><th align=right><a ";
  &HelpLink("wordsearch");
  print "Abstract:</a></th> \n";
  print "<td>\n";
  print $query -> textfield (-name      => 'abstractsearch', 
#                             -default   => $TitleSearchDefault, 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'abstractsearchmode', 
#                              -default => $TitleSearchModeDefault, 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub KeywordsSearchBox { # Field and mode selecter for searches on Keywords
  print "<tr><th align=right><a ";
  &HelpLink("wordsearch");
  print "Keywords:</a></th> \n";
  print "<td>\n";
  print $query -> textfield (-name      => 'keywordsearch', 
#                             -default   => $TitleSearchDefault, 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'keywordsearchmode', 
#                              -default => $TitleSearchModeDefault, 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub PubInfoSearchBox { # Field and mode selecter for searches on PublicationInfo
  print "<tr><th align=right><a ";
  &HelpLink("wordsearch");
  print "Publication Info:</a></th> \n";
  print "<td>\n";
  print $query -> textfield (-name      => 'pubinfosearch', 
#                             -default   => $TitleSearchDefault, 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'pubinfosearchmode', 
#                              -default => $TitleSearchModeDefault, 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub RequesterSearchBox { # Scrolling selectable list for requester search
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

sub DocTypeMulti { # Scrolling selectable list for doc type search
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

sub DateRangePullDown { # Two sets of pulldowns for defining a date range
  my ($sec,$min,$hour,$day,$mon,$year) = localtime(time);
  $year += 1900;
  
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

sub MajorMinorSelect { # Two multi-select boxes for major and minor topics
                       # These are tied together by TopicSearchScript so that 
                       # when major topics are selected, the list of minor 
                       # topics is reduced.
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

sub LogicTypeButtons { # Two buttons allow control whether inner and outer 
                       # logic are done with ANDs or ORs
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
}

1;
