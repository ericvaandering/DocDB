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
  my ($ArgRef) = @_;
  my @TopicIDs = exists $ArgRef->{-topicids} ? @{$ArgRef->{-topicids}} : ();
  my $ListFormat = exists $ArgRef->{-listformat} ? $ArgRef->{-listformat} : "dl";
  
  require "TopicSQL.pm";
  
  
  my @TopicLinks = ();
  if (@TopicIDs) {
    foreach my $TopicID (@TopicIDs) {
      my $TopicLink = TopicLink( {-topicid => $TopicID} );
      if ($TopicLink) {
        push @TopicLinks,$TopicLink;
      }  
    }
  } 
  
# Headers for different styles and handle no topics  
    
  if ($ListFormat eq "dl") {
    print "<div id=\"Topics\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Topics:</span></dt>\n";
    if (@TopicLinks) {
      print "</dl>\n";
      print "<ul>\n";
    } else {
      print "<dd>None</dd>\n";
      print "</dl>\n";
    } 
  }  
  
  if ($ListFormat eq "br") {
    unless (@TopicLinks) {
      print "None<br/>\n";
    }  
  }
  
  foreach my $TopicLink (@TopicLinks) {
    if ($ListFormat eq "dl") {
      print "<li>$TopicLink</li>\n";  
    } elsif ($ListFormat eq "br") {
      print "$TopicLink<br/>\n";
    }
  }
  
# Footers for different styles  
  
  if ($ListFormat eq "dl") {
    if (@TopicLinks) {
      print "</ul>\n";
    }   
    print "</div>\n";
  }  
}

sub TopicLink ($) {
  my ($ArgRef) = @_;
  my $TopicID = exists $ArgRef->{-topicid} ? $ArgRef->{-topicid} : "";

  require "TopicSQL.pm";
  my ($URL,$Text,$Tooltip);

  FetchTopic( {-topicid => $TopicID} );

  $URL     = $ListBy."?topicid=".$TopicID;
  $Text    = CGI::escapeHTML($Topics{$TopicID}{Short});
  $Tooltip = CGI::escapeHTML($Topics{$TopicID}{Long} );
  
  my $Link = "<a href=\"$URL\" title=\"$Tooltip\">$Text</a>";
  
  return $Link;
}

sub TopicsTable {
  require "Sorts.pm";
  require "TopicUtilities.pm";
  
#  my $NCols = 4;
#  my @MajorTopicIDs = sort byMajorTopic keys %MajorTopics;

#  my $Col   = 0;
#  my $Row   = 0;
#  print "<table class=\"HighPaddedTable\">\n";
#  foreach my $MajorID (@MajorTopicIDs) {
#    unless ($Col % $NCols) {
#      if ($Row) {
#        print "</tr>\n";
#      }  
#      print "<tr>\n";
#      ++$Row;
#    }
#    print "<td>\n";
#    &TopicsByMajorTopic($MajorID);
#    print "</td>\n";
#    ++$Col;
#  }  
#  print "</tr>\n";
#  print "</table>\n";

  my @RootTopicIDs = AllRootTopics();
  
  print TopicListWithChildren({ -topicids => \@RootTopicIDs }); 
}

sub TopicListWithChildren { # Recursive routine
  my ($ArgRef) = @_;
  my @TopicIDs = exists $ArgRef->{-topicids} ? @{$ArgRef->{-topicids}} : ();
  my $Depth    = exists $ArgRef->{-depth}    ?   $ArgRef->{-depth}     : 1;
  my @TopicIDs = sort TopicByAlpha @TopicIDs;

  my $HTML;
  
  if (@TopicIDs) {
    $HTML .= "<ul class=\"$Depth-deep\">\n";
    foreach my $TopicID (@TopicIDs) {
      $HTML .= "<li>".TopicLink( {-topicid => $TopicID} );
      if (@{$TopicChildren{$TopicID}}) {
        $HTML .= "\n";
        $HTML .= TopicListWithChildren({ -topicids => $TopicChildren{$TopicID}, -depth => $Depth+1 });
      }
      $HTML .= "</li>\n";
    }
    $HTML .= "</ul>\n";
  }    
  return $HTML;
}

sub ShortDescriptionBox  (;%) {
  my (%Params) = @_;
  
  my $HelpLink  =   $Params{-helplink}  || "shortdescription";
  my $HelpText  =   $Params{-helptext}  || "Short Description";           
  my $ExtraText =   $Params{-extratext} || "";                 # Not used
  my $Required  =   $Params{-required}  || 0;                  
  my $Name      =   $Params{-name}      || "short";
  my $Size      =   $Params{-size}      || 20;
  my $MaxLength =   $Params{-maxlength} || 40;
  my $Disabled  =   $Params{-disabled}  || $FALSE;
  my $Default   =   $Params{-default}   || "";                 # Not used

  print "<div class=\"ShortDescriptionEntry\">\n";
  TextField(-name     => $Name,     -helptext  => $HelpText,  
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
  my $Disabled  =   $Params{-disabled}  || $FALSE;
  my $Default   =   $Params{-default}   || "";

  print "<div class=\"LongDescriptionEntry\">\n";
  TextField(-name     => $Name,     -helptext  => $HelpText, 
            -helplink => $HelpLink, -required  => $Required, 
            -size     => $Size,     -maxlength => $MaxLength,
            -default  => $Default,  -disabled  => $Disabled);
  print "</div>\n";           
};

sub TopicScroll ($) {
  require "TopicSQL.pm";
  require "TopicUtilities.pm";
  require "FormElements.pm";
  
  my ($ArgRef) = @_;
  my $ItemFormat = exists $ArgRef->{-itemformat} ?   $ArgRef->{-itemformat} : "long";
  my $Multiple   = exists $ArgRef->{-multiple}   ?   $ArgRef->{-multiple}   : 0;
  my $HelpLink   = exists $ArgRef->{-helplink}   ?   $ArgRef->{-helplink}   : "topics";
  my $HelpText   = exists $ArgRef->{-helptext}   ?   $ArgRef->{-helptext}   : "Topics";
  my $ExtraText  = exists $ArgRef->{-extratext}  ?   $ArgRef->{-extratext}  : "";
  my $Required   = exists $ArgRef->{-required}   ?   $ArgRef->{-required}   : 0;
  my $Name       = exists $ArgRef->{-name}       ?   $ArgRef->{-name}       : "topics";
  my $Size       = exists $ArgRef->{-size}       ?   $ArgRef->{-size}       : 10;
  my $Disabled   = exists $ArgRef->{-disabled}   ?   $ArgRef->{-disabled}   : "0";
  my @Defaults   = exists $ArgRef->{-default}    ? @{$ArgRef->{-default}}   : ();

  my %Options = ();
 
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }  

  GetTopics();
  BuildTopicProvenance();
  my @TopicIDs = sort TopicByProvenance keys %Topics;
  my %TopicLabels = ();
  my @ActiveIDs = @TopicIDs; # Later can select single root topics, etc.
  
  foreach my $ID (@ActiveIDs) {
    # Can't use &nbsp; since some calls to scrolling_list double escape things. Very odd.
    my $Spaces = '-'x(1*(scalar(@{$TopicProvenance{$ID}})-1));
  
    if ($ItemFormat eq "short") {
      $TopicLabels{$ID} = $Spaces.CGI::escapeHTML($Topics{$ID}{Short}); 
    } elsif ($ItemFormat eq "long") {
      $TopicLabels{$ID} = $Spaces.CGI::escapeHTML($Topics{$ID}{Long}); 
    } elsif ($ItemFormat eq "full") {
      $TopicLabels{$ID} = $Spaces.CGI::escapeHTML($Topics{$ID}{Short}.
                                             " [".$Topics{$ID}{Long}."]"); 
    } 
  }  

  print FormElementTitle(-helplink  => $HelpLink, -helptext  => $HelpText ,
                         -text      => $Text    , -extratext => $ExtraText,
                         -required  => $Required);

  print $query -> scrolling_list(-name     => $Name, -values => \@ActiveIDs, 
                                 -size     => $Size, -labels => \%TopicLabels,
                                 -multiple => $Multiple,
                                 -default  => \@Defaults, %Options);  
}

1;
