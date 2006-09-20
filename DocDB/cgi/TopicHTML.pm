#
#        Name: TopicHTML.pm
# Description: Routines to produce snippets of HTML dealing with topics 
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
  my @TopicIDs    = exists $ArgRef->{-topicids}    ? @{$ArgRef->{-topicids}}   : ();
  my $ListFormat  = exists $ArgRef->{-listformat}  ?   $ArgRef->{-listformat}  : "dl";
  my $ListElement = exists $ArgRef->{-listelement} ?   $ArgRef->{-listelement} : "short";
    
  require "TopicSQL.pm";
  
  my $HTML = "";
  
  my @TopicLinks = ();
  if (@TopicIDs) {
    foreach my $TopicID (@TopicIDs) {
      my $TopicLink = TopicLink( {-topicid => $TopicID, -format => $ListElement} );
      if ($TopicLink) {
        push @TopicLinks,$TopicLink;
      }  
    }
  } 
  
# Headers for different styles and handle no topics  
    
  if ($ListFormat eq "dl") {
    $HTML .= "<div id=\"Topics\">\n";
    $HTML .= "<dl>\n";
    $HTML .= "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Topics:</span></dt>\n";
    if (@TopicLinks) {
      $HTML .= "</dl>\n";
      $HTML .= "<ul>\n";
    } else {
      $HTML .= "<dd>None</dd>\n";
      $HTML .= "</dl>\n";
    } 
  }  
  
  if ($ListFormat eq "br") {
    unless (@TopicLinks) {
      $HTML .= "None<br/>\n";
    }  
  }
  
  foreach my $TopicLink (@TopicLinks) {
    if ($ListFormat eq "dl") {
      $HTML .= "<li>$TopicLink</li>\n";  
    } elsif ($ListFormat eq "br") {
      $HTML .= "$TopicLink<br/>\n";
    }
  }
  
# Footers for different styles  
  
  if ($ListFormat eq "dl") {
    if (@TopicLinks) {
      $HTML .= "</ul>\n";
    }   
    $HTML .= "</div>\n";
  }  
  return $HTML;
}

sub TopicLink ($) {
  my ($ArgRef) = @_;
  my $TopicID = exists $ArgRef->{-topicid} ? $ArgRef->{-topicid} : "";
  my $Format  = exists $ArgRef->{-format}  ? $ArgRef->{-format}  : "short";

  require "TopicSQL.pm";
  my ($URL,$Text,$Tooltip);

  FetchTopic( {-topicid => $TopicID} );

  $URL     = $ListBy."?topicid=".$TopicID;
  if ($Format eq "short") {
    $Text    = CGI::escapeHTML($Topics{$TopicID}{Short});
    $Tooltip = CGI::escapeHTML($Topics{$TopicID}{Long} );
  } elsif ($Format eq "long") {
    $Text    = CGI::escapeHTML($Topics{$TopicID}{Long} );
    $Tooltip = CGI::escapeHTML($Topics{$TopicID}{Short});
  }
  my $Link = "<a href=\"$URL\" title=\"$Tooltip\">$Text</a>";
  
  return $Link;
}

sub TopicsTable {
  require "Sorts.pm";
  require "TopicUtilities.pm";
  
  my $NCols = 4;

  my %Lists = ();
  my $TotalSize = 0;
  my @RootTopicIDs = sort TopicByAlpha AllRootTopics();
  foreach my $TopicID (@RootTopicIDs) {
    my $HTML = TopicListWithChildren({ -topicids => [$TopicID] }); 
    $List{$TopicID}{HTML} = $HTML; 
    my @Lines = split /\n/,$HTML;
    my $Size = grep /href/,@Lines;
    $List{$TopicID}{Size} = $Size;
    $TotalSize += $Size; 
  }   
  
  # This algorithm attempts to balance the length of columns in a multi-column
  # table. It sees if things "mostly" fit and recalculates the length of the 
  # columns on the fly

  my $Target = $TotalSize/$NCols;
  push @DebugStack,"Target column length $Target";
  print '<table class="HighPaddedTable CenteredTable">'."<tr><td>\n";
  my $Col      = 1;
  my $NThisCol = 0;
  my $NSoFar   = 0;
  foreach my $TopicID (@RootTopicIDs) {
    my $Size = $List{$TopicID}{Size};
    
# Insert new cell if current chunk is to large and it's not 
# the first thing in a column or the last column    
    
    if ($NThisCol != 0 && $Col != $NCols && $NThisCol + 0.5*$Size >= $Target) {
      $Target = ($TotalSize - $NSoFar)/($NCols-$Col);
      push @DebugStack,"New target column length $Target";
      print "</td><td>\n";
      ++$Col;
      $NThisCol = 0;
    }
    
    $NThisCol += $Size;
    $NSoFar   += $Size;
    print $List{$TopicID}{HTML}; 
  }  
  print "</td></tr></table>";
}

sub TopicListWithChildren { # Recursive routine
  my ($ArgRef) = @_;
  my @TopicIDs = exists $ArgRef->{-topicids} ? @{$ArgRef->{-topicids}} : ();
  my $Depth    = exists $ArgRef->{-depth}    ?   $ArgRef->{-depth}     : 1;
  my @TopicIDs = sort TopicByAlpha @TopicIDs;

  my $HTML;
  
  if (@TopicIDs) {
    if ($Depth > 1) {
      $HTML .= "<ul class=\"$Depth-deep\">\n";
    }  
    foreach my $TopicID (@TopicIDs) {
      if ($Depth > 1) {
        $HTML .= "<li>";
      }  
      $HTML .= TopicLink( {-topicid => $TopicID} );
      if (@{$TopicChildren{$TopicID}}) {
        $HTML .= "\n";
        $HTML .= TopicListWithChildren({ -topicids => $TopicChildren{$TopicID}, -depth => $Depth+1 });
      }
      if ($Depth > 1) {
        $HTML .= "</li>\n";
      }  
    }
    if ($Depth > 1) {
      $HTML .= "</ul>\n";
    }  
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
  my $Default   =   $Params{-default}   || "";

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

sub TopicScrollTable ($) {
  my ($ArgRef) = @_;

  my $NCols      = exists $ArgRef->{-ncols}      ?   $ArgRef->{-ncols}      : 4;
  my $MinLevel   = exists $ArgRef->{-minlevel}   ?   $ArgRef->{-minlevel}   : 1;
  my $HelpLink   = exists $ArgRef->{-helplink}   ?   $ArgRef->{-helplink}   : "topics";
  my $HelpText   = exists $ArgRef->{-helptext}   ?   $ArgRef->{-helptext}   : "Topics";
  my $Required   = exists $ArgRef->{-required}   ?   $ArgRef->{-required}   : 0;
  my @Defaults   = exists $ArgRef->{-default}    ? @{$ArgRef->{-default}}   : ();

  require "TopicSQL.pm";
  require "TopicUtilities.pm";
  require "FormElements.pm";

  print "<table class=\"MedPaddedTable\">\n";

  print "<tr><th colspan=\"$NCols\">\n";
  print FormElementTitle(-helplink  => $HelpLink, -helptext  => $HelpText ,
                         -required  => $Required);
  print "</th>"; # </tr> by table routine
   
  my @RootTopicIDs = sort TopicByAlpha AllRootTopics();

  my $Col = 0;
  foreach my $TopicID (@RootTopicIDs) {
    my @TopicIDs = TopicAndSubTopics({ -topicid => $TopicID });
    unless ($Col % $NCols) {
      print "</tr><tr>\n";
    }
    print "<td>\n";
    print "<strong>$Topics{$TopicID}{Short}</strong><br/>\n";
    TopicScroll({ -itemformat => "short",    -multiple => $TRUE, -helplink => "", 
                  -default    => \@Defaults, -topicids => \@TopicIDs,
                  -minlevel   => $MinLevel, });
    print "</td>\n";
    ++$Col;
  }   
  print "</tr></table>\n";
}


sub TopicScroll ($) {
  my ($ArgRef) = @_;
  my $ItemFormat = exists $ArgRef->{-itemformat} ?   $ArgRef->{-itemformat} : "long";
  my $MinLevel   = exists $ArgRef->{-minlevel}   ?   $ArgRef->{-minlevel}   : 1;
  my $Multiple   = exists $ArgRef->{-multiple}   ?   $ArgRef->{-multiple}   : 0;
  my $HelpLink   = exists $ArgRef->{-helplink}   ?   $ArgRef->{-helplink}   : "topics";
  my $HelpText   = exists $ArgRef->{-helptext}   ?   $ArgRef->{-helptext}   : "Topics";
  my $ExtraText  = exists $ArgRef->{-extratext}  ?   $ArgRef->{-extratext}  : "";
  my $Required   = exists $ArgRef->{-required}   ?   $ArgRef->{-required}   : 0;
  my $Name       = exists $ArgRef->{-name}       ?   $ArgRef->{-name}       : "topics";
  my $Size       = exists $ArgRef->{-size}       ?   $ArgRef->{-size}       : 10;
  my $Disabled   = exists $ArgRef->{-disabled}   ?   $ArgRef->{-disabled}   : "0";
  my @Defaults   = exists $ArgRef->{-default}    ? @{$ArgRef->{-default}}   : ();
  my @TopicIDs   = exists $ArgRef->{-topicids}   ? @{$ArgRef->{-topicids}}  : ();
  my %Options = ();
 
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }  
  
  require "TopicSQL.pm";
  require "TopicUtilities.pm";
  require "FormElements.pm";

  GetTopics();
  unless (@TopicIDs) {
    @TopicIDs = keys %Topics;
  }  
  @TopicIDs = sort TopicByProvenance @TopicIDs;
  
  my %TopicLabels = ();
#  my @ActiveIDs = @TopicIDs; # Later can select single root topics, etc.
  
  foreach my $ID (@TopicIDs) {
    my $Spaces = '&nbsp;&nbsp;'x(1*(scalar(@{$TopicProvenance{$ID}})-1));
    if ($ItemFormat eq "short") {
      $TopicLabels{$ID} = $Spaces.CGI::escapeHTML($Topics{$ID}{Short}); 
    } elsif ($ItemFormat eq "long") {
      $TopicLabels{$ID} = $Spaces.CGI::escapeHTML($Topics{$ID}{Long}); 
    } elsif ($ItemFormat eq "full") {
      $TopicLabels{$ID} = $Spaces.CGI::escapeHTML($Topics{$ID}{Short}.
                                             " [".$Topics{$ID}{Long}."]"); 
    }

    if (($ItemFormat eq "short" or $ItemFormat eq "long") && 
         scalar(@{$TopicProvenance{$ID}}) < $MinLevel) {
      $TopicLabels{$ID} = "[".$TopicLabels{$ID}."]";
    }
  }  

  print FormElementTitle(-helplink  => $HelpLink, -helptext  => $HelpText ,
                         -text      => $Text    , -extratext => $ExtraText,
                         -required  => $Required);

  $query ->  autoEscape(0);  # Turn off and on since sometimes scrolling_list double escape this.

  print $query -> scrolling_list(-name     => $Name, -values => \@TopicIDs, 
                                 -size     => $Size, -labels => \%TopicLabels,
                                 -multiple => $Multiple,
                                 -default  => \@Defaults, %Options);  
  $query ->  autoEscape(1);
}

1;
