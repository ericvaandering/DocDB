#        Name: TalkHTML.pm
# Description: HTML producing routines for talk entries related to meetings 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub PrintSessionTalk($) {
  my ($SessionTalkID,$AccumulatedTime) = @_;
  
  require "Security.pm";

  require "RevisionSQL.pm";
  require "DocumentSQL.pm";
  require "TopicSQL.pm"; 
  require "MiscSQL.pm"; 

  require "AuthorHTML.pm";
  require "TopicHTML.pm"; 
  require "FileHTML.pm"; 
  require "ResponseElements.pm";
  
  require "SQLUtilities.pm";
  require "Utilities.pm";
  require "Scripts.pm";
  
  my $DocumentID = $SessionTalks{$SessionTalkID}{DocumentID};
  my $Confirmed  = $SessionTalks{$SessionTalkID}{Confirmed};
  my $Note       = $SessionTalks{$SessionTalkID}{Note};
  my $Time       = &TruncateSeconds($SessionTalks{$SessionTalkID}{Time});
  # Selected parts of how things are done in DocumentSummary

  &FetchDocument($DocumentID);
  my $Version = $Documents{$DocumentID}{NVersions};
  unless (&CanAccess($DocumentID,$Version)) {return;}
  
  my $DocRevID   = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
  my $AuthorLink = &FirstAuthor($DocRevID); 
  #FIXME: Make Version optional, see comment in ResponseElements.pm
  my $Title      = &DocumentLink($DocumentID,$Version,$DocRevisions{$DocRevID}{Title});
  my @FileIDs    = &FetchDocFiles($DocRevID);
  my @TopicIDs   = &GetRevisionTopics($DocRevID);

  @TopicIDs = &RemoveArray(\@TopicIDs,@IgnoreTopics);

  print "<tr valign=top>\n";
  print "<td align=right><b>",&TruncateSeconds($AccumulatedTime),"</b></td>\n";  
  if ($Confirmed) { # Put titles in italics for unconfirmed talks
    print "<td>$Title</td>\n";
  } else {
    my $SessionTalkSummary = &SessionTalkSummary($SessionTalkID);
    print "<td><i>$Title</i> [$SessionTalkSummary]</td>\n";
  }
  print "<td><nobr>$AuthorLink</nobr></td>\n";
  print "<td>"; &ShortTopicListByID(@TopicIDs);   print "</td>\n";
  print "<td>"; &ShortFileListByRevID($DocRevID); print "</td>\n";
  print "<td align=right>$Time</td>\n";
  if ($Note) {
    print "<td><b>",&TalkNoteLink,"</b></td>\n";
  } else {
    print "<td>",&TalkNoteLink,"</td>\n";
  }  
  print "</tr>\n";
}

sub TalkEntryForm (@) {
  my @SessionOrderIDs = @_; 

  require "Scripts.pm";
  print "<table cellpadding=3>\n";
  print "<tr valign=bottom>\n";
  print "<th><b><a "; &HelpLink("sessionorder");  print "Order,</a></b><br/>\n";
  print "    <b><a "; &HelpLink("talkconfirm");   print "Confirm</a><br/>\n";
  print "or  <b><a "; &HelpLink("talkdelete");    print "Delete</a></td>\n";
  print "<th><b><a "; &HelpLink("talkseparator"); print "Break</a></th>\n";
  print "<th><b><a "; &HelpLink("talkdocid");     print "Doc. #</a></th>\n";
  print "<th><b><a "; &HelpLink("talkinfo");      print "Talk Title & Note</a></th>\n";
  print "<th><b><a "; &HelpLink("talktime");      print "Time</a></th>\n";
  print "<th><b><a "; &HelpLink("authorhint");    print "Author Hints</a></b>\n";
  print "<th><b><a "; &HelpLink("topichint");     print "Topic Hints</a></b>\n";
  print "</tr>\n";
  
  # Sort session IDs by order
  
  my $ExtraTalks = 10;
  if (@SessionOrderIDs) { $ExtraTalks = 3; }
  for (my $Talk=1;$Talk<=$ExtraTalks;++$Talk) {
    push @SessionOrderIDs,"n$Talk";
  }
  
  my $TalkOrder = 0;
  foreach $SessionOrderID (@SessionOrderIDs) {
  
    ++$TalkOrder;
    $TalkDefaultOrder = $TalkOrder;  
    my $EntryTimeStamp;
    
    @TalkDefaultTopicHints  = ();
    @TalkDefaultAuthorHints = ();
    if (grep /n/,$SessionOrderID) { # Erase defaults
      $TalkDefaultTime        = "00:30";
      $TalkDefaultConfirmed   = "";
      $TalkDefaultTitle       = "";
      $TalkDefaultNote        = "";
      $TalkSeparatorDefault   = "";
      $TalkDefaultDocID       = "";
      @TalkDefaultAuthorHints = ();
      @TalkDefaultTopicHints  = ();
    } else { # Key off Meeting Order IDs, do differently for Sessions and Separators
      if ($SessionOrders{$SessionOrderID}{SessionTalkID}) {
        my $SessionTalkID     = $SessionOrders{$SessionOrderID}{SessionTalkID};
        $TalkDefaultConfirmed = $SessionTalks{$SessionTalkID}{Confirmed}  || "";
        $TalkDefaultTime      = $SessionTalks{$SessionTalkID}{Time}       || "00:30";
        $TalkDefaultTitle     = $SessionTalks{$SessionTalkID}{HintTitle}  || "";
        $TalkDefaultNote      = $SessionTalks{$SessionTalkID}{Note}       || "";
        $TalkDefaultDocID     = $SessionTalks{$SessionTalkID}{DocumentID} || "";
        $TalkSeparatorDefault = "No";
        $EntryTimeStamp       = $SessionTalks{$SessionTalkID}{TimeStamp}; 
        # Get hints and convert to format accepted by scrolling lists
        
        my @TopicHintIDs = &FetchTopicHintsBySessionTalkID($SessionTalkID);
        foreach my $TopicHintID (@TopicHintIDs) {
          push @TalkDefaultTopicHints,$TopicHints{$TopicHintID}{MinorTopicID};
        }
        my @AuthorHintIDs = &FetchAuthorHintsBySessionTalkID($SessionTalkID);
        foreach my $AuthorHintID (@AuthorHintIDs) {
          push @TalkDefaultAuthorHints,$AuthorHints{$AuthorHintID}{AuthorID};
        }
      } elsif ($SessionOrders{$SessionOrderID}{TalkSeparatorID}) {
        my $TalkSeparatorID   = $SessionOrders{$SessionOrderID}{TalkSeparatorID};
        $TalkDefaultConfirmed = "";
        $TalkDefaultTime      = $TalkSeparators{$TalkSeparatorID}{Time}  || "00:30";
        $TalkDefaultTitle     = $TalkSeparators{$TalkSeparatorID}{Title} || "";
        $TalkDefaultNote      = $TalkSeparators{$TalkSeparatorID}{Note}  || "";
        $TalkSeparatorDefault = "Yes";
        $EntryTimeStamp       = $TalkSeparators{$TalkSeparatorID}{TimeStamp}; 
      }
    } 

    print "<tr valign=top>\n";
    $query -> param('sessionorderid',$SessionOrderID);
    print $query -> hidden(-name => 'sessionorderid', -default => $SessionOrderID);
    print $query -> hidden(-name => 'timestamp',      -default => $TimeStamp);


    print "<td align=left rowspan=3>\n"; &TalkOrder; print "<br/>\n";
    &TalkConfirm($SessionOrderID);    print "<br/>\n";
    &TalkDelete($SessionOrderID);     print "<br/>\n";
    &TalkNewSession($SessionOrderID); print "</td>\n";
    
    print "<td align=center rowspan=3>\n"; &TalkSeparator($SessionOrderID); print "</td>\n";
    print "<td align=center rowspan=3>\n"; &TalkDocID($SessionOrderID);                      print "</td>\n";
    print "<td>\n"; &TalkTitle($TalkDefaultTitle);            print "</td>\n";
    print "<td rowspan=2>\n"; &TalkTimePullDown; print "</td>\n";
    print "<td rowspan=3>\n"; &TalkAuthors($SessionOrderID); print "</td>\n";
    print "<td rowspan=3>\n"; &TalkTopics($SessionOrderID); print "</td>\n";
    print "</tr>\n";
    print "<tr valign=top>\n";
    print "<td>\n"; &TalkNote;      print "</td>\n";
    print "</tr>\n";
    if ($TalkDefaultDocID) {
      my $TitleLink = &NewDocumentLink($TalkDefaultDocID,undef,"title");
      print "<tr valign=top>\n";
      print "<td colspan=2>Match: $TitleLink</td>\n";
      print "</tr>\n";
    } else {
      print "<tr><td colspan=2>&nbsp;</td></tr>\n";
    }    
    print "<tr valign=top><td colspan=7><hr width=95%></td>\n";
    print "</tr>\n";
  }
  print "</table>\n";
}

sub TalkTitle ($) {
  $query -> param('talktitle',$TalkDefaultTitle);
  print $query -> textfield (-name => 'talktitle', -size => 40, -maxlength => 128, 
                             -default => $TalkDefaultTitle);
}

sub TalkNote {
  $query -> param('talknote', $TalkDefaultNote);
  print $query -> textarea (-name => 'talknote',-value => $TalkDefaultNote, 
                            -columns => 40, -rows => 4);
}

sub TalkDelete ($) {
  my ($SessionOrderID) = @_;
  print "<nobr>";
  if ($TalkSeparatorDefault eq "Yes" || $TalkSeparatorDefault eq "No") {
    print $query -> checkbox(-name  => "talkdelete", 
                             -value => "$SessionOrderID", -label => 'Delete');
  } else {
    print "&nbsp\n";
  }
  print "</nobr>";
}

sub TalkConfirm ($) {
  my ($SessionOrderID) = @_;
  
  print "<nobr>";
  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } elsif ($TalkDefaultConfirmed) {  
    print $query -> checkbox(-name  => "talkconfirm", -checked => 'checked', 
                             -value => "$SessionOrderID", -label => 'Confirm');
  } else {  
    print $query -> checkbox(-name  => "talkconfirm", 
                             -value => "$SessionOrderID", -label => 'Confirm');
  }
  print "</nobr>";
}

sub TalkOrder {
  $query -> param('talkorder',$TalkDefaultOrder);
  print $query -> textfield (-name => 'talkorder', -value => $TalkDefaultOrder, 
                             -size => 4, -maxlength => 5);
}

sub TalkSeparator ($) {
  my ($SessionOrderID) = @_;

  if ($TalkSeparatorDefault eq "Yes") {
    print "Yes\n";	      
  } elsif ($TalkSeparatorDefault eq "No") {
    print "No\n";	      
  } else {
    $query -> param('talkseparator', "");
    print $query -> checkbox(-name => "talkseparator", -value => "$SessionOrderID", -label => 'Yes');
  }
}

sub TalkDocID {
  my ($SessionOrderID) = @_;
  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } else {  
    $query -> param("talkdocid-$SessionOrderID",$TalkDefaultDocID);
    print $query -> textfield (-name => "talkdocid-$SessionOrderID", -value => $TalkDocID, 
                               -size => 6, -maxlength => 7);
  }
}

sub TalkTimePullDown {
  
  require "SQLUtilities.pm";
  
  my $DefaultTime = &TruncateSeconds($TalkDefaultTime);

  my @hours = ("----");
  for (my $Hour = 0; $Hour<=5; ++$Hour) {
    for (my $Min = 0; $Min<=59; $Min=$Min+5) {
      push @hours,sprintf "%2.2d:%2.2d",$Hour,$Min;
    }  
  }  

  $query -> param('talktime', $DefaultTime);
  print $query -> popup_menu (-name => 'talktime', -values => \@hours, 
                              -default => $DefaultTime);
}

sub TalkAuthors ($) {
  my ($SessionOrderID) = @_;

  require "AuthorHTML.pm";

  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } else { 
    if ($AuthorMode eq "field") {
      unless (@TalkDefaultAuthorHints) {
        $query -> param("authortext-$SessionOrderID","");
      }  
      &AuthorTextEntry("authortext-$SessionOrderID",@TalkDefaultAuthorHints);
    } else {
      unless (@TalkDefaultAuthorHints) {
        $query -> param("authors-$SessionOrderID","");
      }  
      &AuthorScroll(0,1,"authors-$SessionOrderID",@TalkDefaultAuthorHints);
    }
  } 
}

sub TalkTopics ($) {
  my ($SessionOrderID) = @_;

  require "TopicHTML.pm";

  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } else {  
    unless (@TalkDefaultTopicHints) {
      $query -> param("topics-$SessionOrderID","");
    }  
    &FullTopicScroll(1,"topics-$SessionOrderID",@TalkDefaultTopicHints);
  }
}

sub TalkNewSession ($) {
  my ($SessionOrderID) = @_;
  
  require "MeetingSQL.pm";

  my $SessionTalkID   = $SessionOrders{$SessionOrderID}{SessionTalkID};
  my $TalkSeparatorID = $SessionOrders{$SessionOrderID}{TalkSeparatorID};
  
  my $SessionID;
  if ($SessionTalkID) {
    $SessionID = $SessionTalks{$SessionTalkID}{SessionID};
  } elsif ($TalkSeparatorID) {
    $SessionID = $TalkSeparators{$TalkSeparatorID}{SessionID};
  }

  my $ConferenceID = $Sessions{$SessionID}{ConferenceID};
  
  my @SessionIDs = &FetchSessionsByConferenceID($ConferenceID);

  $SessionLabels{0} = "Move to new session?";
  unshift @SessionIDs,"0";
  
  foreach my $SessionID (@SessionIDs) {
    $SessionLabels{$SessionID} = $Sessions{$SessionID}{Title}; 
  }
  print $query -> popup_menu (-name    => "newsessionid-$SessionOrderID", 
                              -labels => \%SessionLabels, 
                              -values  => \@SessionIDs);
}

sub SessionTalkPulldown {
  my (@SessionTalkIDs) = @_;
  
  require "TalkHintSQL.pm";
  require "AuthorSQL.pm";
  
  my %SessionTalkLabels = ();
  
  foreach my $SessionTalkID (@SessionTalkIDs) {
    $SessionTalkLabels{$SessionTalkID} = &SessionTalkSummary($SessionTalkID);
  }                                   
  $SessionTalkLabels{0} = "Select your talk from this list";
  unshift @SessionTalkIDs,"0";
  
  print "<b><a ";
  &HelpLink("talkfromagenda");
  print "Talk from Agenda:</a></b><br> \n";
  print $query -> popup_menu (-name    => 'sessiontalkid', 
                              -labels => \%SessionTalkLabels, 
                              -values  => \@SessionTalkIDs);

}

sub SessionTalkSummary {
  my ($SessionTalkID) = @_;
  
  require "TalkHintSQL.pm";
  require "AuthorSQL.pm";
  
  my @AuthorHintIDs = &FetchAuthorHintsBySessionTalkID($SessionTalkID); 
  my @Authors = ();
  foreach my $AuthorHintID (@AuthorHintIDs) {
    my $AuthorID = $AuthorHints{$AuthorHintID}{AuthorID}; 
    &FetchAuthor($AuthorID);
    $Author = $Authors{$AuthorID}{FULLNAME};
    push @Authors,$Author;
  }
  
  my $SessionTalkSummary = "";
  
  my $Authors = join ', ',@Authors;
  if ($SessionTalks{$SessionTalkID}{HintTitle}) {
    $SessionTalkSummary = $SessionTalks{$SessionTalkID}{HintTitle};
  } else {
    $SessionTalkSummary = "Unknown";
  }  
  $SessionTalkSummary .= " - ";
  if (@Authors) {
    $SessionTalkSummary .= $Authors;
  } else {
    $SessionTalkSummary .= "Unknown";
  }  
  return $SessionTalkSummary;
}

# Note on replacing NOBR. Error is in standard spec, but all implementations
# Obey

# > I strive to make XHTML files that validate. But when I have something like a
# > phone number or social security number that I don't want the browser to
# > break apart I have to use the <nobr> tag to do that. The <nobr> tag,
#> however, keeps the page from validating. Unfortunately, I can't find any
#> kind of "break" style in the CSS spec that would allow me to create a class
#> that would tell the browser to do basically what the <nobr> tag
#> does--something like <span class="PhoneNumber">999-999-9999</span>.
#>
#> Is there an alternative to the <nobr> tag

#In your example, this style rule:
#
#.PhoneNumber { white-space: nowrap; }

#> that works in all of the browsers?

#That works in all browsers that support all CSS1 properties (of which there
#are now several).

1;
