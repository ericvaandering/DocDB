#
#        Name: KeywordFormElements.pm
# Description: Various routines which supply input forms for  
#              keyword table administration
#
#      Author: Lynn Garren (garren@fnal.gov)
#    Modified: 
#

sub KeywordSelect { # Scrolling selectable list for keywords
  my @KeywordListIDs = sort byKeyword keys %FullKeywords;
  my %KeywordLabels = ();
  foreach my $ID (@KeywordListIDs) {
    $KeywordLabels{$ID} = $FullKeywords{$ID}; # FIXME: get rid of FullKeywords
  }  
  print "<b><a ";
  &HelpLink("keywords");
  print "Keywords:</a></b><br> \n";
  print $query -> scrolling_list(-name => "keywordlist", -values => \@KeywordListIDs, 
                                 -labels => \%KeywordLabels,
                                 -size => 10, -multiple => 'true' );
};

sub KeywordSelectLong { # Scrolling selectable list for keywords, all info
  my @KeywordListIDs = sort byKeyword keys %FullKeywords;
  my %KeywordLabels = ();
  foreach my $ID (@KeywordListIDs) {
    ##$KeywordLabels{$ID} = $FullKeywords{$ID}." [$KeywordListEntries{$ID}{LONG}]"; 
    my $descr = $KeywordListEntries{$ID}{LONG};
    my $long;
    if ( (length $descr ) > 40 ) {
      $long = substr($descr,0,40)." ...";
    } else {
      $long = $descr;
    }
    $KeywordLabels{$ID} = $FullKeywords{$ID}." [$long]"; 
  }
  print "<b><a ";
  &HelpLink("keywords");
  print "Keywords:</a></b> (Long descriptions in brackets)<br> \n";
  print $query -> scrolling_list(-name => "keywordlist", -values => \@KeywordListIDs, 
                                 -labels => \%KeywordLabels,
                                 -size => 15 );
};


sub KeywordGroupSelect (;$) { # Scrolling selectable list for keyword groups
  my ($Mode) = @_; 
  
  print "<b><a ";
  &HelpLink("KeywordGroups");
  print "Keyword Groups:</a></b><br> \n";
  my @KeyGroupIDs = keys %KeywordGroups;
  my %GroupLabels = ();
  foreach my $ID (@KeyGroupIDs) {
    if ($Mode eq "full") {
      $GroupLabels{$ID} = $KeywordGroups{$ID}{Full};
    } else {  
      $GroupLabels{$ID} = $KeywordGroups{$ID}{SHORT};
    }  
  }  
  print $query -> scrolling_list(-name => "keywordgroup", -values => \@KeyGroupIDs, 
                                 -labels => \%GroupLabels,  -size => 10);
};

1;
