#
#        Name: TopicHTML.pm
# Description: Routines to produce snippets of HTML dealing with topics 
#              (major, minor and conferences which are special types of topics) 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub TopicListByID {
  my @TopicIDs = @_;
  
  require "TopicSQL.pm";
  
  print "<div id=\"Topics\">\n";
  if (@TopicIDs) {
    print "<b>Topics:</b><br/>\n";
    print "<ul>\n";
    foreach my $TopicID (@TopicIDs) {
      &FetchMinorTopic($TopicID);
      my $TopicLink = &MinorTopicLink($TopicID);
      print "<li>$TopicLink</li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Topics:</b> none<br/>\n";
  }
  print "</div>\n";
}

sub ShortTopicListByID {
  my @TopicIDs = @_;

  require "TopicSQL.pm";
  
  if (@TopicIDs) {
    foreach my $TopicID (@TopicIDs) {
      &FetchMinorTopic($TopicID);
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
  require "MeetingSQL.pm";
  require "MeetingSecurityUtilities.pm";
  
  my ($URL,$link,@MeetingOrderIDs);

  &FetchMinorTopic($TopicID);
  my $ConferenceID = &FetchConferenceByTopicID($TopicID);
  if ($ConferenceID && &CanAccessMeeting($ConferenceID)) {
    @MeetingOrderIDs = &FetchMeetingOrdersByConferenceID($ConferenceID);
  }  
  
  if ($ConferenceID && @MeetingOrderIDs && &CanAccessMeeting($ConferenceID)) {
    $URL = "$DisplayMeeting?conferenceid=$ConferenceID";
  } else {
    $URL = "$ListByTopic?topicid=$TopicID";
  }  
    
  $link = "<a href=\"$URL\" title=\"$MinorTopics{$TopicID}{LONG}\">";
  if ($mode eq "short") {
    $link .= $MinorTopics{$TopicID}{SHORT};
  } elsif ($mode eq "long") {
    $link .= $MinorTopics{$TopicID}{LONG};
  } else {
    $link .= $MinorTopics{$TopicID}{Full};
  }
  $link .= "</a>";
  
  return $link;
}

sub MajorTopicLink ($;$) {
  my ($TopicID,$mode) = @_;
  
  require "TopicSQL.pm";
  
  &FetchMajorTopic($TopicID);
  my $link;
  $link = "<a href=\"$ListByTopic?majorid=$TopicID\" title=\"$MajorTopics{$TopicID}{LONG}\">";
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

sub GatheringLink {
  my ($TopicID,$Mode) = @_;
  my $MajorID = $MinorTopics{$TopicID}{MAJOR};
  my $Link;
  if (&MajorIsConference($MajorID)) {
    $Link = &ConferenceLink($TopicID,$Mode);
  } elsif (&MajorIsMeeting($MajorID)) {
    $Link = &MeetingLink($TopicID,$Mode);
  }
}

sub MeetingLink {
  my ($TopicID,$Mode) = @_;
  
  require "TopicSQL.pm";
  
  &FetchMinorTopic($TopicID);
  my $link;
  $link = "<a href=\"$ListByTopic?topicid=$TopicID&mode=meeting\" title=\"$MinorTopics{$TopicID}{LONG}\">";
  if ($Mode eq "short") {
    $link .= $MinorTopics{$TopicID}{SHORT};
  } else {
    $link .= $MinorTopics{$TopicID}{Full};
  }
  $link .= "</a>";
  
  return $link;
}

sub ConferenceLink {
  my ($TopicID,$Mode) = @_;
  
  require "TopicSQL.pm";
  
  &FetchMinorTopic($TopicID);
  my $Link;
     $Link = "<a href=$ListByTopic?topicid=$TopicID&mode=conference>";
  if ($Mode eq "short" || $Mode eq "nodate") {
    $Link .= $MinorTopics{$TopicID}{SHORT};
  } elsif ($Mode eq "long") {
    $Link .= $MinorTopics{$TopicID}{LONG};
  } else {
    $Link .= $MinorTopics{$TopicID}{Full};
  }
  $Link .= "</a>";
  unless ($Mode eq "nodate") {
    my $ConferenceID = $ConferenceMinor{$TopicID};
    my ($Year,$Month,$Day) = split /\-/,$Conferences{$ConferenceID}{StartDate};
    $Link .= " (".@AbrvMonths[$Month-1]." $Year)"; 
  }
  return $Link;
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
  print "<table cellpadding=10>\n";
  foreach my $MajorID (@MajorTopicIDs) {
    unless ($Col % $NCols) {
      if ($Row) {
        print "</tr>\n";
      }  
      print "<tr valign=top>\n";
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

sub GatheringTable {
  require "Sorts.pm";
  require "TopicSQL.pm";
  require "ResponseElements.pm";
  
  my @MinorTopicIDs = sort byTopic keys %MinorTopics; #FIXME special sort 

  print "<table cellpadding=4>\n";

  print "<tr>\n";
  print "<th>Description</th>\n";
  print "<th>Long Description</th>\n";
  print "<th>Location</th>\n";
  print "<th>Dates</th>\n";
  print "<th>URL</th>\n";
  print "</tr>\n";
  
  foreach my $MajorID (@GatheringMajorIDs) { 
    print "<tr>\n";
    print "<th colspan=5><hr></th>\n";
    print "</tr>\n";
    print "<tr>\n";
    print "<th colspan=5>$MajorTopics{$MajorID}{SHORT}</th>\n";
    print "</tr>\n";

    foreach my $MinorID (@MinorTopicIDs) {
      if ($MajorID == $MinorTopics{$MinorID}{MAJOR}) {
        print "<tr>\n";
        
        my $ConferenceID = $ConferenceMinor{$MinorID};
        my $GatheringLink = &GatheringLink($MinorID,"short");
        my $Start = &EuroDate($Conferences{$ConferenceID}{StartDate});
        my $End   = &EuroDate($Conferences{$ConferenceID}{EndDate});
        my $Link;
        if ($Conferences{$ConferenceID}{URL}) {
          $Link = "<a href=\"$Conferences{$ConferenceID}{URL}\">$Conferences{$ConferenceID}{URL}</a>";
        } else {
          $Link = "None entered\n";
        }
        print "<td>$GatheringLink</td>\n";
        print "<td>$MinorTopics{$MinorID}{LONG}</td>\n";
        print "<td>$Conferences{$ConferenceID}{Location}</td>\n";
        print "<td>$Start - $End</td>\n";
        print "<td>$Link</td>\n";
        print "</tr>\n";
      }  
    }  
  }
  print "</table>";
}

sub ConferencesList {
  require "Sorts.pm";
  require "TopicSQL.pm";
  
  my @MinorTopicIDs = sort byTopic keys %MinorTopics; #FIXME special sort 

  my ($MajorID) = @ConferenceMajorIDs; 
  print "<ul>\n";
  foreach my $MinorID (@MinorTopicIDs) {
    if ($MajorID == $MinorTopics{$MinorID}{MAJOR}) {
      my $topic_link = &ConferenceLink($MinorID,"long");
      print "<li>$topic_link\n";
    }  
  }  
  print "</ul>";
}

sub MajorGatheringSelect (;%) { # Scrolling selectable list for major topics with dates
  require "Scripts.pm";

  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled} || "0";
  my $Mode     = $Params{-format}   || "short";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print "<b><a ";
  &HelpLink("majortopics");
  print "Major Topics:</a></b><br> \n";
  my @MajorIDs = keys %MajorTopics;
  my @MeetingMajorIDs = ();
  foreach my $MajorID (@MajorIDs) {
    if (&MajorIsMeeting($MajorID) || &MajorIsConference($MajorID)) {
      push @MeetingMajorIDs,$MajorID;
    }
  }    
  my %MajorLabels = ();
  foreach my $ID (@MeetingMajorIDs) {
    if ($Mode eq "full") {
      $MajorLabels{$ID} = $MajorTopics{$ID}{Full};
    } else {  
      $MajorLabels{$ID} = $MajorTopics{$ID}{SHORT};
    }  
  }  
  print $query -> scrolling_list(-name => "majortopic", -values => \@MeetingMajorIDs, 
                                 -labels => \%MajorLabels,  -size => 10,
                                 -default => $DefaultMajorID, $Booleans);
};

sub ConferenceSelect {
  require "TopicSQL.pm";
  
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  my @MinorIDs           = sort byTopic keys %MinorTopics;
  my @ConferenceTopicIDs = ();
  my %TopicLabels        = ();
  foreach my $MinorID (@MinorIDs) {
    unless (&MajorIsConference($MinorTopics{$MinorID}{MAJOR}) || &MajorIsMeeting($MinorTopics{$MinorID}{MAJOR})) {
      next;
    }  
    push @ConferenceTopicIDs,$MinorID;
    $TopicLabels{$MinorID} = $MinorTopics{$MinorID}{SHORT}; 
  }  
  print "<b><a ";
  &HelpLink("conference");
  print "Conferences:</a></b> <br> \n";
  print $query -> scrolling_list(-name => "conftopic", -values => \@ConferenceTopicIDs, 
                                 -labels => \%TopicLabels, -size => 10, $Booleans);
}

sub MeetingsTable {
  require "Sorts.pm";
  require "TopicSQL.pm";
  
  my @MeetingTopicIDs = ();
  my @MinorTopicIDs   = keys %MinorTopics; 
  my ($MajorID) = @MeetingMajorIDs; 

  foreach my $MinorID (@MinorTopicIDs) {
    if ($MajorID == $MinorTopics{$MinorID}{MAJOR}) {
      push @MeetingTopicIDs,$MinorID;
    }  
  }  

  @MeetingTopicIDs = sort byTopic @MeetingTopicIDs; 

  my $NCols     = 3;
  my $NPerCol   = int (scalar(@MeetingTopicIDs)/$NCols + 1);
  my $NThisCol  = 0;

  print "<table>\n";
  print "<tr valign=top>\n";
  
  print "<td>\n";
  print "<ul>\n";
  foreach my $MinorID (@MeetingTopicIDs) {
    if ($NThisCol >= $NPerCol) {
      print "</ul></td>\n";
      print "<td>\n";
      print "<ul>\n";
      $NThisCol = 0;
    }
    ++$NThisCol;
    my $topic_link = &MinorTopicLink($MinorID,"short");
    print "<li>$topic_link\n";
  }  
  print "</ul></td></tr>";
  print "</table>\n";
}

sub ShortDescriptionBox  (;%) {
  my (%Params) = @_;
  
  my $HelpLink  =   $Params{-helplink}  || "shortdescription"; #FIXME Not used, Blank might be needed later?
  my $HelpText  =   $Params{-helptext}  || "Topics";           # Not used
  my $ExtraText =   $Params{-extratext} || "";                 # Not used
  my $Required  =   $Params{-required}  || 0;                  # Not used
  my $Name      =   $Params{-name}      || "short";
  my $Size      =   $Params{-size}      || 20;
  my $MaxLength =   $Params{-maxlength} || 40;
  my $Disabled  =   $Params{-disabled}  || "0";
  my $Default   =   $Params{-default}   || "";                 # Not used

  print "<b><a ";
  &HelpLink("shortdescription");
  print "Short Description:</a></b><br> \n";
  if ($Disabled) {  # Doesn't scale
    print $query -> textfield (-name => $Name,  -default   => $DefaultShortDescription,
                               -size => $Size , -maxlength => $MaxLength, -disabled);
  } else {
    print $query -> textfield (-name => $Name,  -default   => $DefaultShortDescription,
                               -size => $Size , -maxlength => $MaxLength);
  }                               
};

sub LongDescriptionBox (;%) {
  my (%Params) = @_;
  
  my $HelpLink  =   $Params{-helplink}  || "longdescription";  #FIXME  Not used, Blank might be needed later?
  my $HelpText  =   $Params{-helptext}  || "Topics";           # Not used
  my $ExtraText =   $Params{-extratext} || "";                 # Not used
  my $Required  =   $Params{-required}  || 0;                  # Not used
  my $Name      =   $Params{-name}      || "long";
  my $Size      =   $Params{-size}      || 40;
  my $MaxLength =   $Params{-maxlength} || 120;
  my $Disabled  =   $Params{-disabled}  || "0";
  my $Default   =   $Params{-default}   || "";                 # Not used

  print "<b><a ";
  &HelpLink("longdescription");
  print "Long Description:</a></b><br> \n";
  if ($Disabled) {  # Doesn't scale
    print $query -> textfield (-name => $Name,  -default   => $DefaultLongDescription,
                               -size => $Size , -maxlength => $MaxLength, -disabled);
    
    
  } else {
    print $query -> textfield (-name => $Name,  -default   => $DefaultLongDescription,
                               -size => $Size , -maxlength => $MaxLength);
    
    
  }                               
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
    $TopicLabels{$ID} = $MinorTopics{$ID}{Full}; 
  }  
  print $query -> scrolling_list(-name => $ElementName, -values => \@TopicIDs, 
                                 -labels => \%TopicLabels,
                                 -size => 10, -multiple => $Multiple,
                                 -default => \@Defaults);
};

sub TopicScroll (%) {
  require "TopicSQL.pm";
  
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

  unless ($GotAllTopics) {
    &GetTopics;
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

  if ($HelpLink) {
    print "<b><a ";
    &HelpLink($HelpLink);
    print "$HelpText:</a></b>";
    if ($Required) {
      print $RequiredMark;
    }  
    if ($ExtraText) {
      print "&nbsp;$ExtraText";
    }  
    print "<br/> \n";
  }

  if ($Disabled) {  # Doesn't scale
    print $query -> scrolling_list(-name => $Name, -values => \@ActiveIDs, 
                                   -labels => \%TopicLabels,
                                   -size => 10, -multiple => $Multiple, -disabled,
                                   -default => \@Defaults);
  } else {
    print $query -> scrolling_list(-name => $Name, -values => \@ActiveIDs, 
                                   -labels => \%TopicLabels,
                                   -size => 10, -multiple => $Multiple,
                                   -default => \@Defaults);
  }                               
  
}

1;
