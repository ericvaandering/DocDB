#
#        Name: KeywordHTML.pm
# Description: Routines to produce snippets of HTML and form elements 
#              dealing with keywords 
#
#      Author: Lynn Garren (garren@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)
#

sub KeywordListLink ($;$) {
  my ($KeyID,$mode) = @_;
  
  require "KeywordSQL.pm";
  
  &FetchKeyword($KeyID);
  my $link;
  ##$link = " "; # FIXME: Use KeywordLink after uses parameters
  $link = "<a href=\"$Search?innerlogic=AND&outerlogic=AND&keywordsearchmode=anysub&keywordsearch=$Keywords{$KeyID}{Short}\">";
  if ($mode eq "short") {
    $link .= $Keywords{$KeyID}{Short};
  } elsif ($mode eq "long") {
    $link .= $Keywords{$KeyID}{Long};
  } else {
    $link .= $Keywords{$KeyID}{Full};
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

sub GetKeywordInfo ($;$) { # Isn't this similar to KeywordLink too?
  my ($KeyID,$mode) = @_;
  
  require "KeywordSQL.pm";
  
  &FetchKeyword($KeyID);
  my $link;
  if ($mode eq "short") {
    $link = $Keywords{$KeyID}{Short};
  } elsif ($mode eq "long") {
    $link = $Keywords{$KeyID}{Long};
  } else {
    $link = $Keywords{$KeyID}{Full};
  }
  
  return $link;
}

sub KeywordsbyKeywordGroup ($;$) {
  my ($KeywordGroupID,$Mode) = @_;
  
  require "KeySorts.pm";

  my @KeywordIDs = sort byKey &GetKeywordsByKeywordGroupID($KeywordGroupID);

  my $KeywordGroupIDLink = &KeywordGroupInfo($KeywordGroupID,"short");
  print "<b>$KeywordGroupIDLink</b>\n";
  print "<ul>\n";
  foreach my $KeywordID (@KeywordIDs) {
    my $KeyLink;
    if ($Mode eq "chooser") {
      $KeyLink = "<a href=\"\"$ListKeywords?mode=chooser\"\"
      onClick=\"InsertKeyword('$Keywords{$KeywordID}{Short}');\">$Keywords{$KeywordID}{Short}</a>";
    } else {
      $KeyLink = &KeywordListLink($KeywordID,"short");
    }
    print "<li>$KeyLink</li>\n";
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

    my @KeywordListIDs = sort byKey keys %Keywords;

    my $KeywordGroupIDLink = &KeywordGroupInfo($KeywordGroupIDID,"short");
    print "<tr valign=top>\n";
    print "  <td colspan=2>\n";
    print "  <a name=$KeywordGroupIDLink>\n";
    print "  <b>$KeywordGroupIDLink</b>\n";
    print "  </td>\n";
    print "</tr>\n";
    foreach my $KeyID (@KeywordListIDs) {
      if ($KeywordGroupIDID == $Keywords{$KeyID}{KeywordGroupID}) {
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

sub KeywordSelect (%) { # Scrolling selectable list for keyword groups
  my (%Params) = @_; 
  
  my $Format   = $Params{-format}   || "short";        # short, long, full
  my $Multiple = $Params{-multiple} || "";             # Any non-null text is "true"
  my $Name     = $Params{-name}     || "keywordlist";
  my $MaxLabel = $Params{-maxlabel} || 0;

# Scrolling selectable list for keywords
  my @KeywordIDs = sort byKeyword keys %Keywords;
  my %KeywordLabels = ();
  foreach my $ID (@KeywordIDs) {
    if ($Format eq "short") {
      $KeywordLabels{$ID} = $Keywords{$ID}{Short}; 
    } elsif ($Format eq "long") {
      $KeywordLabels{$ID} = $Keywords{$ID}{Long}; 
    } elsif ($Format eq "full") {
      $KeywordLabels{$ID} = $Keywords{$ID}{Short}." [";
      if ($MaxLabel) {
        if ( (length $Keywords{$ID}{Long}) > $MaxLabel) {
          $KeywordLabels{$ID} .= substr($Keywords{$ID}{Long},0,$MaxLabel)." ...";
        } else {
          $KeywordLabels{$ID} .= $Keywords{$ID}{Long};
        }
        $KeywordLabels{$ID} .= "]"; 
      }  
    }
  }  
  print "<b><a ";
  &HelpLink("keywords");
  print "Keywords:</a></b><br> \n";
  print $query -> scrolling_list(-name => "keywordlist", -values => \@KeywordIDs, 
                                 -labels => \%KeywordLabels,
                                 -size => 10, -multiple => $Multiple );
};

sub KeywordGroupSelect (%) { # Scrolling selectable list for keyword groups
  my (%Params) = @_; 
  
  my $Format   = $Params{-format}   || "short";        # short, full
  my $Multiple = $Params{-multiple} || "";             # Any non-null text is "true"
  my $Name     = $Params{-name}     || "keywordgroup";
  my $Delete   = $Params{-delete}   || "";
  
  print "<b><a ";
  &HelpLink("KeywordGroups");
  print "Keyword Groups:</a></b><br> \n";
  my @KeyGroupIDs = keys %KeywordGroups;
  my %GroupLabels = ();
  
  foreach my $ID (@KeyGroupIDs) {
    if ($Format eq "full") {
      $GroupLabels{$ID} = "$KeywordGroups{$ID}{Short} [$KeywordGroups{$ID}{Long}]";
    } else {  
      $GroupLabels{$ID} = $KeywordGroups{$ID}{Short};
    }  
  }  

  if ($Delete) {
    unshift @KeyGroupIDs,"-1";
    $GroupLabels{"-1"} = "Remove existing groups";
  }
    
  print $query -> scrolling_list(-name => $Name, -values => \@KeyGroupIDs, 
                                 -labels => \%GroupLabels,  -size => 10, -multiple => $Multiple);
};

sub KeywordLink ($;%) { # FIXME: Allow parameters of short, long, full a la Lynn (use KeywordID)
  my ($Keyword,%Params) = @_;

  my $Format   = $Params{-format} || "short"; # short, full
  
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
