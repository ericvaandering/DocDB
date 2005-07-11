#
#        Name: KeywordHTML.pm
# Description: Routines to produce snippets of HTML and form elements 
#              dealing with keywords 
#
#      Author: Lynn Garren (garren@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)
#

# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License 
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

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

sub KeywordsbyKeywordGroup ($;$) {
  my ($KeywordGroupID,$Mode) = @_;
  
  require "Sorts.pm";

  my @KeywordIDs = sort byKeyword &GetKeywordsByKeywordGroupID($KeywordGroupID);

  my $KeywordGroupIDLink = &KeywordGroupInfo($KeywordGroupID,"short");
  print "<b>$KeywordGroupIDLink</b>\n";
  print "<ul>\n";
  foreach my $KeywordID (@KeywordIDs) {
    my $KeyLink;
    if ($Mode eq "chooser") {
      $KeyLink = "<a href=\"$ListKeywords?mode=chooser\" ".
                 "onclick=\"InsertKeyword('$Keywords{$KeywordID}{Short}');\">$Keywords{$KeywordID}{Short}</a>";
    } else {
      $KeyLink = &KeywordLinkByID($KeywordID,-format => "short");
    }
    print "<li>$KeyLink</li>\n";
  }  
  print "</ul>\n";
}

sub KeywordTable {
  my ($Mode) = @_;
  
  require "Sorts.pm";

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
  require "Sorts.pm";

  my @KeywordGroupIDs = sort byKeywordGroup keys %KeywordGroups;

  print "<table cellpadding=10>\n";
  print "<tr valign=top>\n";
  foreach my $KeywordGroupID (@KeywordGroupIDs) {
    my $KeywordGroup = &KeywordGroupInfo($KeywordGroupID,"short");
    my $Label = $KeywordGroup;
    $Label =~ s/\s+//;
    
    print "  <td>\n";
    print "  <a href=\"#$Label\"><b>$KeywordGroup</b>\n";
    print "  </td>\n";
  }
  print "</tr>\n";
  print "</table>\n";

  print "<table cellpadding=3>\n";
  foreach my $KeywordGroupIDID (@KeywordGroupIDs) {

    my @KeywordListIDs = sort byKeyword keys %Keywords;

    my $KeywordGroupIDLink = &KeywordGroupInfo($KeywordGroupIDID,"short");
    print "<tr valign=top>\n";
    print "  <td colspan=3>\n";
    my $Label = $KeywordGroupIDLink;
    $Label =~ s/\s+//;
    print "  <a name=$Label>\n";
    print "  <b>$KeywordGroupIDLink</b>\n";
    print "  </td>\n";
    print "</tr>\n";
    my @KeywordListIDs = sort byKeyword &GetKeywordsByKeywordGroupID($KeywordGroupIDID);
    foreach my $KeyID (@KeywordListIDs) {
      my $Link = &KeywordLinkByID($KeyID,-format => "short");
      my $Text = &KeywordLinkByID($KeyID,-format => "long", -nolink => "true");
      print "<tr valign=top>\n";
      print "  <td>&nbsp;</td>\n";
      print "  <td>$Link</td>\n";
      print "  <td>$Text</td>\n";
      print "</tr>\n";
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
  my $Disabled = $Params{-disabled} || "0";

  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
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
                                 -size => 10, -multiple => $Multiple, $Booleans );
};

sub KeywordGroupSelect (%) { # Scrolling selectable list for keyword groups
  my (%Params) = @_; 
  
  my $Format   = $Params{-format}   || "short";        # short, full
  my $Multiple = $Params{-multiple} || "";             # Any non-null text is "true"
  my $Name     = $Params{-name}     || "keywordgroup";
  my $Remove   = $Params{-remove}   || "";
  my $Disabled = $Params{-disabled} || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
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

  if ($Remove) {
    unshift @KeyGroupIDs,"-1";
    $GroupLabels{"-1"} = "Remove existing groups";
  }
    
  print $query -> scrolling_list(-name => $Name, 
                                 -values => \@KeyGroupIDs, 
                                 -labels => \%GroupLabels, -size => 10, 
                                 -multiple => $Multiple, $Booleans);
};

sub KeywordLinkByID ($;%) {
  my ($KeywordID,%Params) = @_;
  
  my $Format = $Params{-format} || "short"; # short, long
  my $NoLink = $Params{-nolink} || "";      # will just return information

  &FetchKeyword($KeywordID);
  my $Keyword = $Keywords{$KeywordID}{Short};
  my $Link;
  
  unless ($NoLink) {  
    $Link .= "<a href=\"$Search\?keywordsearchmode=anyword&amp;keywordsearch=$Keyword\">";
  }
  
  if ($Format eq "short") { 
    $Link .= $Keywords{$KeywordID}{Short};
  } elsif ($Format eq "long") {
    $Link .= $Keywords{$KeywordID}{Long};
  }  

  unless ($NoLink) {  
    $Link .=  "</a>";
  }
  
  return $Link;
}

sub KeywordLink ($;%) { # FIXME: Allow parameters of short, long, full a la Lynn (use KeywordID)
  my ($Keyword,%Params) = @_;

  my $Format = $Params{-format} || "short"; # short, full
  
  my $ret = "<a href=\"$Search\?keywordsearchmode=anyword&amp;keywordsearch=$Keyword\">";
  $ret .= "$Keyword";
  $ret .=  "</a>";
  return $ret;
}         

sub KeywordsBox (%) {
  my (%Params) = @_; 
  
  my $Required = $Params{-required}   || 0;

  print "<b><a ";
  &HelpLink("keywords");
  print "Keywords:</a></b>";
  if ($Required) {
    print $RequiredMark;
  } else {
    print " ";
  }   
  print "(space separated) - <a href=\"Javascript:keywordchooserwindow(\'$ListKeywords?mode=chooser\');\"><b>Keyword
  Chooser</b></a><br> \n";
  print $query -> textfield (-name => 'keywords', -default => $KeywordsDefault, 
                             -size => 70, -maxlength => 240);
};

1;
