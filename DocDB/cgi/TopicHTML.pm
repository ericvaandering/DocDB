#
#        Name: TopicHTML.pm
# Description: Routines to produce snippets of HTML dealing with topics 
#              (major and minor) 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

sub TopicListByID {
  my @TopicIDs = @_;
  
  require "TopicSQL.pm";
  
  print "<div id=\"Topics\">\n";
  print "<dl>\n";
  print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Topics:</span></dt>\n";
  if (@TopicIDs) {
    print "</dl>\n";
    print "<ul>\n";
    foreach my $TopicID (@TopicIDs) {
      my $TopicLink = &MinorTopicLink($TopicID);
      print "<li>$TopicLink</li>\n";
    }
    print "</ul>\n";
  } else {
    print "<dd>None</dd>\n";
    print "</dl>\n";
  }
  print "</div>\n";
}

sub ShortTopicListByID {
  my @TopicIDs = @_;

  require "TopicSQL.pm";
  
  if (@TopicIDs) {
    foreach my $TopicID (@TopicIDs) {
      my $TopicLink = &MinorTopicLink($TopicID);
      print "$TopicLink<br/>\n";
    }
  } else {
    print "None<br/>\n";
  }
}

sub MinorTopicLink ($;$) {
  my ($TopicID,$mode) = @_;
  
  require "TopicSQL.pm";
  
  my ($URL,$Link);

  &FetchMinorTopic($TopicID);

  $URL = "$ListBy?topicid=$TopicID";
    
  $Link = "<a href=\"$URL\" title=\"$MinorTopics{$TopicID}{LONG}\">";
  if ($mode eq "short") {
    $Link .= $MinorTopics{$TopicID}{SHORT};
  } elsif ($mode eq "long") {
    $Link .= $MinorTopics{$TopicID}{LONG};
  } else {
    $Link .= $MinorTopics{$TopicID}{Full};
  }
  $Link .= "</a>";
  
  return $Link;
}

sub MajorTopicLink ($;$) {
  my ($TopicID,$mode) = @_;
  
  require "TopicSQL.pm";
  
  &FetchMajorTopic($TopicID);
  my $link;
  $link = "<a href=\"$ListBy?majorid=$TopicID\" title=\"$MajorTopics{$TopicID}{LONG}\">";
  if ($mode eq "short") {
    $link .= $MajorTopics{$TopicID}{SHORT};
  } elsif ($mode eq "long") {
    $link .= $MajorTopics{$TopicID}{LONG};
  } else {
    $link .= $MajorTopics{$TopicID}{SHORT};
  }
  $link .= "</a>";
  
  return $link;
}

sub TopicsByMajorTopic ($) {
  my ($MajorTopicID) = @_;
  
  require "Sorts.pm";

  my @MinorTopicIDs = sort byTopic keys %MinorTopics;

  my $MajorLink = &MajorTopicLink($MajorTopicID,"short");
  print "<b>$MajorLink</b>\n";
  print "<ul>\n";
  foreach my $MinorTopicID (@MinorTopicIDs) {
    if ($MajorTopicID == $MinorTopics{$MinorTopicID}{MAJOR}) {
      my $TopicLink = &MinorTopicLink($MinorTopicID,"short");
      print "<li>$TopicLink</li>\n";
    }  
  }  
  print "</ul>\n";
}

sub TopicsTable {
  require "Sorts.pm";

  my $NCols = 4;
  my @MajorTopicIDs = sort byMajorTopic keys %MajorTopics;

  my $Col   = 0;
  my $Row   = 0;
  print "<table class=\"HighPaddedTable\">\n";
  foreach my $MajorID (@MajorTopicIDs) {
    unless ($Col % $NCols) {
      if ($Row) {
        print "</tr>\n";
      }  
      print "<tr>\n";
      ++$Row;
    }
    print "<td>\n";
    &TopicsByMajorTopic($MajorID);
    print "</td>\n";
    ++$Col;
  }  
  print "</tr>\n";
  print "</table>\n";
}

sub ShortDescriptionBox  (;%) {
  my (%Params) = @_;
  
  my $HelpLink  =   $Params{-helplink}  || "shortdescription"; #FIXME Not used, Blank might be needed later?
  my $HelpText  =   $Params{-helptext}  || "Topics";           # Not used
  my $ExtraText =   $Params{-extratext} || "";                 # Not used
  my $Required  =   $Params{-required}  || 0;                  
  my $Name      =   $Params{-name}      || "short";
  my $Size      =   $Params{-size}      || 20;
  my $MaxLength =   $Params{-maxlength} || 40;
  my $Disabled  =   $Params{-disabled}  || "0";
  my $Default   =   $Params{-default}   || "";                 # Not used

  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  print "<div class=\"ShortDescriptionEntry\">\n";
  &TextField(-name     => $Name,     -helptext  => $HelpText,  
             -helplink => $HelpLink, -required  => $Required,  
             -size     => $Size,     -maxlength => $MaxLength, 
             -default  => $Default,  -disabled  => $Disabled);
  print "</div>\n";           
}

sub LongDescriptionBox (;%) {
  my (%Params) = @_;
  
  my $HelpLink  =   $Params{-helplink}  || "longdescription";  
  my $HelpText  =   $Params{-helptext}  || "Long Description";           
  my $ExtraText =   $Params{-extratext} || "";                 # Not used
  my $Required  =   $Params{-required}  || 0;                  
  my $Name      =   $Params{-name}      || "long";
  my $Size      =   $Params{-size}      || 40;
  my $MaxLength =   $Params{-maxlength} || 120;
  my $Disabled  =   $Params{-disabled}  || 0;
  my $Default   =   $Params{-default}   || "";                 # FIXME: Not used

  print "<div class=\"LongDescriptionEntry\">\n";
  &TextField(-name     => $Name,     -helptext  => $HelpText, 
             -helplink => $HelpLink, -required  => $Required, 
             -size     => $Size,     -maxlength => $MaxLength,
             -default  => $Default,  -disabled  => $Disabled);
  print "</div>\n";           
};

sub FullTopicScroll ($$;@) { # Scrolling selectable list for topics, all info

  #FIXME: Use TopicScroll

  my ($Multiple,$ElementName,@Defaults) = @_;

  require "TopicSQL.pm";
  
  unless ($GotAllTopics) {
    &GetTopics;
  }
  
  if ($Multiple) {
    $Multiple = "true";
  } else { 
    $Multiple = "false";
  }  
  
  my @TopicIDs = sort byTopic keys %MinorTopics;
  my %TopicLabels = ();
  foreach my $ID (@TopicIDs) {
    $TopicLabels{$ID} = &SafeHTML($MinorTopics{$ID}{Full}); 
  }  
  print $query -> scrolling_list(-name => $ElementName, -values => \@TopicIDs, 
                                 -labels => \%TopicLabels,
                                 -size => 10, -multiple => $Multiple,
                                 -default => \@Defaults);
};

sub TopicScroll (%) {
  require "TopicSQL.pm";
  require "FormElements.pm";
  
  my (%Params) = @_;
  
  my $Format    =   $Params{-format}    || "full";
  my $Multiple  =   $Params{-multiple}  || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Topics";
  my $ExtraText =   $Params{-extratext} || "";
  my $Required  =   $Params{-required}  || 0;
  my $Name      =   $Params{-name}      || "topics";
  my $Size      =   $Params{-size}      || 10;
  my $Disabled  =   $Params{-disabled}  || "0";
  my @Defaults  = @{$Params{-default}};

  my %Options = ();
 
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }  

  unless ($GotAllTopics) {
    GetTopics();
  }
  
  my @TopicIDs = sort byTopic keys %MinorTopics;
  my %TopicLabels = ();
  my @ActiveIDs = @TopicIDs; # Later can select single major topics, etc.
  
  foreach my $ID (@ActiveIDs) {
    if ($Format eq "full") {
      $TopicLabels{$ID} = $MinorTopics{$ID}{Full}; 
    } elsif ($Format eq "long") {
      $TopicLabels{$ID} = $MinorTopics{$ID}{Full}." [$MinorTopics{$ID}{LONG}]"; 
    } 
  }  

  print FormElementTitle(-helplink  => $HelpLink, -helptext  => $HelpText ,
                         -text      => $Text    , -extratext => $ExtraText,
                         -required  => $Required);

  print $query -> scrolling_list(-name     => $Name, -values => \@ActiveIDs, 
                                 -size     => 10,    -labels => \%TopicLabels,
                                 -multiple => $Multiple,
                                 -default  => \@Defaults, %Options);  
}

1;
