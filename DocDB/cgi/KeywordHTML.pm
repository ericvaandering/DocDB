#
#        Name: KeywordHTML.pm
# Description: Routines to produce snippets of HTML and form elements 
#              dealing with keywords 
#
#      Author: Lynn Garren (garren@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov) # KeywordFormElements merged
#



sub KeywordListLink ($;$) {
  my ($KeyID,$mode) = @_;
  
  require "KeywordSQL.pm";
  
  &FetchKeyword($KeyID);
  my $link;
  ##$link = " "; # FIXME: Use KeywordLink after uses parameters
  $link = "<a href=\"$Search?innerlogic=AND&outerlogic=AND&keywordsearchmode=anysub&keywordsearch=$KeywordListEntries{$KeyID}{Short}\">";
  if ($mode eq "short") {
    $link .= $KeywordListEntries{$KeyID}{Short};
  } elsif ($mode eq "long") {
    $link .= $KeywordListEntries{$KeyID}{Long};
  } else {
    $link .= $KeywordListEntries{$KeyID}{Full};
  }
  ##$link .= " ";
  $link .= "</a>";
  
  return $link;
}


sub KeywordGroupInfo ($;$) {
  my ($KeyID,$mode) = @_;
  
  require "KeywordSQL.pm";
  
  &FetchKeywordGroup($KeyID);
  my $info;
  if ($mode eq "short") {
    $info = $KeywordGroups{$KeyID}{Short};
  } elsif ($mode eq "long") {
    $info = $KeywordGroups{$KeyID}{Long};
  } else {
    $info = $KeywordGroups{$KeyID}{Short};
  }
  
  return $info;
}

sub GetKeywordInfo ($;$) {
  my ($KeyID,$mode) = @_;
  
  require "KeywordSQL.pm";
  
  &FetchKeyword($KeyID);
  my $link;
  if ($mode eq "short") {
    $link = $KeywordListEntries{$KeyID}{Short};
  } elsif ($mode eq "long") {
    $link = $KeywordListEntries{$KeyID}{Long};
  } else {
    $link = $KeywordListEntries{$KeyID}{Full};
  }
  
  return $link;
}

sub KeywordsbyKeywordGroup ($;$) {
  my ($KeywordGroupID,$Mode) = @_;
  
  require "KeySorts.pm";

  my @KeywordListIDs = sort byKey keys %KeywordListEntries;

  my $KeywordGroupIDLink = &KeywordGroupInfo($KeywordGroupID,"short");
  print "<b>$KeywordGroupIDLink</b>\n";
  print "<ul>\n";
  foreach my $KeyID (@KeywordListIDs) {
    if ($KeywordGroupID == $KeywordListEntries{$KeyID}{KeywordGroupID}) {
      my $KeyLink;
      if ($Mode eq "chooser") {
        $KeyLink = "<a href=\"\"$ListKeywords?mode=chooser\"\"
        onClick=\"InsertKeyword('$KeywordListEntries{$KeyID}{Short}');\">$KeywordListEntries{$KeyID}{Short}</a>";
      } else {
        $KeyLink = &KeywordListLink($KeyID,"short");
      }
      print "<li>$KeyLink</li>\n";
    }  
  }  
  print "</ul>\n";
}

sub KeywordTable {
  my ($Mode) = @_;
  
  require "KeySorts.pm";

  my $NCols = 4;
  my @KeywordGroupIDs = sort byKeywordGroup keys %KeywordGroups;

  my $Col   = 0;
  my $Row   = 0;
  print "<table cellpadding=10>\n";
  foreach my $KeywordGroupID (@KeywordGroupIDs) {
    unless ($Col % $NCols) {
      if ($Row) {
        print "</tr>\n";
      }  
      print "<tr valign=top>\n";
      ++$Row;
    }
    print "<td>\n";
    &KeywordsbyKeywordGroup($KeywordGroupID,$Mode);
    print "</td>\n";
    ++$Col;
  }  
  print "</tr>\n";
  print "</table>\n";
}

sub KeywordDetailedList {
  require "KeySorts.pm";

  my @KeywordGroupIDs = sort byKeywordGroup keys %KeywordGroups;

  print "<table cellpadding=10>\n";
  print "<tr valign=top>\n";
  foreach my $KeywordGroupIDID (@KeywordGroupIDs) {
    my $KeywordGroupID = &KeywordGroupInfo($KeywordGroupIDID,"short");
    print "  <td>\n";
    print "  <a href=\"#$KeywordGroupID\"><b>$KeywordGroupID</b>\n";
    print "  </td>\n";
  }
  print "</tr>\n";
  print "</table>\n";

  print "<table cellpadding=10>\n";
  foreach my $KeywordGroupIDID (@KeywordGroupIDs) {

    my @KeywordListIDs = sort byKey keys %KeywordListEntries;

    my $KeywordGroupIDLink = &KeywordGroupInfo($KeywordGroupIDID,"short");
    print "<tr valign=top>\n";
    print "  <td colspan=2>\n";
    print "  <a name=$KeywordGroupIDLink>\n";
    print "  <b>$KeywordGroupIDLink</b>\n";
    print "  </td>\n";
    print "</tr>\n";
    foreach my $KeyID (@KeywordListIDs) {
      if ($KeywordGroupIDID == $KeywordListEntries{$KeyID}{KeywordGroupID}) {
	my $KeyWd = &GetKeywordInfo($KeyID,"short");
	my $LongLink = &GetKeywordInfo($KeyID,"long");
	$link = "<a href=\"$Search?innerlogic=AND&outerlogic=AND&keywordsearchmode=anysub&keywordsearch=$KeyWd\">";
        print "<tr valign=top>\n";
	print "  <td>$link$KeyWd</a></td>\n";
	print "  <td>$LongLink</td>\n";
        print "</tr>\n";
      }  
    }  

  }  
  print "</table>\n";
}

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
    ##$KeywordLabels{$ID} = $FullKeywords{$ID}." [$KeywordListEntries{$ID}{Long}]"; 
    my $descr = $KeywordListEntries{$ID}{Long};
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
      $GroupLabels{$ID} = $KeywordGroups{$ID}{Short};
    }  
  }  
  print $query -> scrolling_list(-name => "keywordgroup", -values => \@KeyGroupIDs, 
                                 -labels => \%GroupLabels,  -size => 10);
};

sub KeywordLink { # FIXME: Allow parameters of short, long, full a la Lynn
  my ($Keyword) = @_;
  
  my $ret = "<a href=\"$Search\?keywordsearchmode=anysub&keywordsearch=$Keyword\">";
  $ret .= "$Keyword";
  $ret .=  "</a>";
  return $ret;
}         

sub KeywordsBox {
  print "<b><a ";
  &HelpLink("keywords");
  print "Keywords:</a></b> (space separated)\n";
  print " (<a href=\"$ListKeywords?mode=chooser\" target=\"_blank\">Keyword
  Chooser</a>)<br> \n";
  print $query -> textfield (-name => 'keywords', -default => $KeywordsDefault, 
                             -size => 70, -maxlength => 240);
};

1;
