# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

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
#  RevisionNoteSearchBox
#    A box to type words/strings and a mode selecter for text searches 
#    on Keywords
#   
#  PubInfoSearchBox
#    A box to type words/strings and a mode selecter for text searches 
#    on PublicationInfo
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
#    
#  ModeSelect
#    A pulldown to select the display mode for searches
#

require "SearchModes.pm";
require "FormElements.pm";

sub TitleSearchBox { # Box and mode selecter for searches on DocumentTitle
  print "<tr><th>";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Titles", -nobreak => $TRUE);
  print "</th>\n";
  print "<td>\n";
  print $query -> textfield (-name      => 'titlesearch', 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'titlesearchmode', 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub AbstractSearchBox { # Field and mode selecter for searches on Abstract
  print "<tr><th>";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Abstract", -nobreak => $TRUE);
  print "</th>\n";
  print "<td>\n";
  print $query -> textfield (-name      => 'abstractsearch', 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'abstractsearchmode', 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub KeywordsSearchBox { # Field and mode selecter for searches on Keywords
  print "<tr><th>";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Keywords", -nobreak => $TRUE);
  print "</th>\n";
  print "<td>\n";
  print $query -> textfield (-name      => 'keywordsearch', 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'keywordsearchmode', 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub RevisionNoteSearchBox { # Field and mode selecter for searches on Note
  print "<tr><th>";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Notes and Changes", -nobreak => $TRUE);
  print "</th>\n";
  print "<td>\n";
  print $query -> textfield (-name      => 'revisionnotesearch', 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'revisionnotesearchmode', 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub PubInfoSearchBox { # Field and mode selecter for searches on PublicationInfo
  print "<tr><th>";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Publication Info", -nobreak => $TRUE);
  print "</th>\n";
  print "<td>\n";
  print $query -> textfield (-name      => 'pubinfosearch', 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'pubinfosearchmode', 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub FileNameSearchBox { # Field and mode selecter for searches on Files
  print "<tr><th>";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "File names", -nobreak => $TRUE);
  print "</th>\n";
  print "<td>\n";
  print $query -> textfield (-name      => 'filesearch', 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'filesearchmode', 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub DescriptionSearchBox { # Field and mode selecter for searches on Files
  print "<tr><th>";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "File descriptions", -nobreak => $TRUE);
  print "</th>\n";
  print "<td>\n";
  print $query -> textfield (-name      => 'filedescsearch', 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'filedescsearchmode', 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub ContentSearchBox { # Field and mode selecter for searches on Files
  print "<tr><th>";
  print FormElementTitle(-helplink => "contentsearch", -helptext => "File contents", -nobreak => $TRUE);
  print "</th>\n";
  print "<td>\n";
  print $query -> textfield (-name      => 'filecontsearch', 
                             -size      => 40, 
                             -maxlength => 240);
  print "</td>\n";
  print "<td>\n";
  print $query -> popup_menu (-name    => 'filecontsearchmode', 
                              -values  => \%SearchModes);
  print "</td></tr>\n";
};

sub DocTypeMulti { # Scrolling selectable list for doc type search
  my %DocTypeLabels = ();
  foreach my $DocTypeID (keys %DocumentTypes) {
    $DocTypeLabels{$DocTypeID} = $DocumentTypes{$DocTypeID}{SHORT};
  }  
  print FormElementTitle(-helplink => "doctypemulti", -helptext => "Document type");
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
  for ($i = $FirstYear; $i<=$year; ++$i) { # $FirstYear - current year
    push @years,$i;
  }  

  print $query -> popup_menu (-name => 'afterday',  -values => \@days);    
  print $query -> popup_menu (-name => 'aftermonth',-values => \@months);
  print $query -> popup_menu (-name => 'afteryear', -values => \@years); 
  print " (Start)\n";
  print "<br/><strong><big>&nbsp;</big>&nbsp;and</strong><br/>\n";

  print $query -> popup_menu (-name => 'beforeday',  -values => \@days);
  print $query -> popup_menu (-name => 'beforemonth',-values => \@months);
  print $query -> popup_menu (-name => 'beforeyear', -values => \@years);
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
  print FormElementTitle(-helplink => "dynamictopic", -helptext => "Topic Groups");
  print $query -> scrolling_list(-name => "majortopic", -values => \@MajorIDs, 
                                 -labels => \%MajorLabels,  
                                 -size => 10, 
                                 -onchange => "selectProduct(this.form);",
                                 -multiple => 'true');
  print "</td>\n";
  
  print "<td colspan=\"2\">\n";
  my @MinorIDs = sort byTopic keys %MinorTopics;
  my %MinorLabels = ();
  foreach my $ID (@MinorIDs) {
    $MinorLabels{$ID} = $MinorTopics{$ID}{Full};
  }  
  print FormElementTitle(-helplink => "dynamictopic", -helptext => "Topics");
  print $query -> scrolling_list(-name => "minortopic", -values => \@MinorIDs, 
                                 -labels => \%MinorLabels,  
                                 -size => 10,
                                 -multiple => 'true');
  print "</td>\n";
}

sub LogicTypeButtons { # Two buttons allow control whether inner and outer 
                       # logic are done with ANDs or ORs
  my @Values = ["AND","OR"];
  
  print FormElementTitle(-helplink => "logictype", -helptext => "Between Fields", -nobreak => $TRUE);
  print $query -> radio_group(-name => "outerlogic", 
                              -values => @Values, -default => "AND");
  
  print "&nbsp;&nbsp;&nbsp;&nbsp;";
  
  print FormElementTitle(-helplink => "logictype", -helptext => "Within Fields", -nobreak => $TRUE);
  print $query -> radio_group(-name => "innerlogic", 
                              -values => @Values, -default => "OR");
}

sub ModeSelect { # Display Mode selecter for searches 
  print FormElementTitle(-helptext => "Sort by", -helplink => "displaymode", -nobreak => $TRUE);
  my %Modes = ();
  $Modes{date}    = "Date with document #";
  $Modes{meeting} = "Author with topics and files";
  print $query -> popup_menu (-name    => 'mode', 
                              -values  => \%Modes,
                              -default => 'date');
}

1;
