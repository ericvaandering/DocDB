#
#        Name: KeywordHTML.pm
# Description: Routines to produce snippets of HTML and form elements
#              dealing with keywords
#
#      Author: Lynn Garren (garren@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)
#

# Copyright 2001-2014 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

use HTML::Entities;
use URI::Escape;

require "HTMLUtilities.pm";

sub KeywordGroupInfo ($;$) {
  my ($KeyID,$mode) = @_;

  require "KeywordSQL.pm";

  &FetchKeywordGroup($KeyID);
  my $info;
  if ($mode eq "short") {
    $info = SmartHTML({-text=>$KeywordGroups{$KeyID}{Short}});
  } elsif ($mode eq "long") {
    $info = SmartHTML({-text=>$KeywordGroups{$KeyID}{Long}});
  } else {
    $info = SmartHTML({-text=>$KeywordGroups{$KeyID}{Short}});
  }

  return $info;
}

sub KeywordsbyKeywordGroup ($;$) {

  # FIXME_XSS: Check to make sure this kind of search still works.
  # May need to remove special characters or adapt search atoms
  my ($KeywordGroupID,$Mode) = @_;

  require "Sorts.pm";

  my @KeywordIDs = sort byKeyword &GetKeywordsByKeywordGroupID($KeywordGroupID);

  my $KeywordGroupIDLink = &KeywordGroupInfo($KeywordGroupID,"short");
  print "<b>$KeywordGroupIDLink</b>\n";
  print "<ul>\n";
  foreach my $KeywordID (@KeywordIDs) {
    my $KeyLink;
    if ($Mode eq "chooser") {
      my $SafeKeyword = SmartHTML({-text=>$Keywords{$KeywordID}{Short}});
      $SafeKeyword =~ s/\'/\\\'/g;
      $SafeKeyword =~ s/\&#x27;/\\\&#x27;/g;
      $SafeKeyword =~ s/\"//g;       # FIXME: Just remove double quotes for now
      $SafeKeyword =~ s/\&#x22;//g;  # FIXME: Just remove double quotes for now
      $KeyLink = "<a href=\"$ListKeywords?mode=chooser\" ".
                 "onclick=\"InsertKeyword('$SafeKeyword');\">$SafeKeyword</a>";
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
      $KeywordLabels{$ID} = SmartHTML({-text=>$Keywords{$ID}{Short}});
    } elsif ($Format eq "long") {
      $KeywordLabels{$ID} = SmartHTML({-text=>$Keywords{$ID}{Long}});
    } elsif ($Format eq "full") {
      $KeywordLabels{$ID} = SmartHTML({-text=>$Keywords{$ID}{Short}})." [";
      if ($MaxLabel) {
        if ( (length $Keywords{$ID}{Long}) > $MaxLabel) {
          $KeywordLabels{$ID} .= substr(SmartHTML({-text=>$Keywords{$ID}{Long}}),0,$MaxLabel)." ...";
        } else {
          $KeywordLabels{$ID} .= SmartHTML({-text=>$Keywords{$ID}{Long}});
        }
        $KeywordLabels{$ID} .= "]";
      }
    }
  }
  print FormElementTitle(-helplink => "keywords", -helptext => "Keywords");
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

  print FormElementTitle(-helplink => "keywordgroups", -helptext => "Keyword Groups");
  my @KeyGroupIDs = keys %KeywordGroups;
  my %GroupLabels = ();

  foreach my $ID (@KeyGroupIDs) {
    if ($Format eq "full") {
      $GroupLabels{$ID} = SmartHTML({-text=>$KeywordGroups{$ID}{Short}})." ".SmartHTML({-text=>$KeywordGroups{$ID}{Long}});
    } else {
      $GroupLabels{$ID} = SmartHTML({-text=>$KeywordGroups{$ID}{Short}});
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
  my $SafeShortKeyword = SmartHTML( {-text => $Keywords{$KeywordID}{Short}} );
  my $SafeLongKeyword = SmartHTML( {-text => $Keywords{$KeywordID}{Long}} );
  my $UnsafeURI = decode_entities($Keywords{$KeywordID}{Short});
  my $SafeURI = uri_escape($UnsafeURI);
  my $Link;

  # FIXME_XSS: Check to make sure this kind of search still works.
  # May need to remove special characters or adapt search atoms
  unless ($NoLink) {
    $Link .= "<a href=\"$Search\?keywordsearchmode=anyword&amp;keywordsearch=$SafeURI\">";
  }

  if ($Format eq "short") {
    $Link .= $SafeShortKeyword;
  } elsif ($Format eq "long") {
    $Link .= $SafeLongKeyword;
  }

  unless ($NoLink) {
    $Link .=  "</a>";
  }

  return $Link;
}

sub KeywordLink ($;%) { # FIXME: Allow parameters of short, long, full a la Lynn (use KeywordID)
  my ($Keyword,%Params) = @_;

  my $Format = $Params{-format} || "short"; # short, full
  my $SafeKeyword = SmartHTML( {-text => $Keyword} );
  my $UnsafeURI = decode_entities($Keyword);
  my $SafeURI = uri_escape($UnsafeURI);
  my $ret = "<a href=\"$Search\?keywordsearchmode=anyword&amp;keywordsearch=$SafeURI\">";
  $ret .= "$SafeKeyword";
  $ret .=  "</a>";
  return $ret;
}

sub KeywordsBox (%) {
  my (%Params) = @_;
  #FIXME: Get rid of global default

  my $Required = $Params{-required}   || 0;

  my $ElementTitle = &FormElementTitle(-helplink  => "keywords" ,
                                       -helptext  => "Keywords" ,
                                       -extratext => "(space separated) - <a href=\"Javascript:keywordchooserwindow(\'$ListKeywords?mode=chooser\');\"><b>Keyword
  Chooser</b></a>",
                                       -required  => $Required );
  print $ElementTitle,"\n";
  my $SafeDefault = SmartHTML({-text => $KeywordsDefault},);
  print $query -> textfield (-name => 'keywords', -default => $KeywordsDefault,
                             -size => 70, -maxlength => 240);
};

1;
