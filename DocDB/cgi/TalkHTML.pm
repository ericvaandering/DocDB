#        Name: TalkHTML.pm
# Description: HTML producing routines for talk entries related to meetings 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub PrintSessionTalk($) {
  my ($SessionTalkID,$StartTime) = @_;
  
  require "Security.pm";

  require "RevisionSQL.pm";
  require "DocumentSQL.pm";
  require "TopicSQL.pm"; 
  require "MiscSQL.pm"; 

  require "AuthorHTML.pm";
  require "TopicHTML.pm"; 
  require "FileHTML.pm"; 
  require "ResponseElements.pm";
  
  require "Utilities.pm";
  
  my $DocumentID = $SessionTalks{$SessionTalkID}{DocumentID};
  my $Confirmed  = $SessionTalks{$SessionTalkID}{Confirmed};
  my $Note       = $SessionTalks{$SessionTalkID}{Note};
  my $Time       = $SessionTalks{$SessionTalkID}{Time};

  # Selected parts of how things are done in DocumentSummary

  if ($DocumentID) {
    &FetchDocument($DocumentID);
    unless (&CanAccess($DocumentID,$Version)) {return;}
    my $DocRevID   = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    my $AuthorLink = &FirstAuthor($DocRevID); 
    #FIXME: Make Version optional, see comment in ResponseElements.pm
    my $Title      = &DocumentLink($DocumentID,$Version,$DocRevisions{$DocRevID}{TITLE});
    my @FileIDs    = &FetchDocFiles($DocRevID);
    my @TopicIDs   = &GetRevisionTopics($DocRevID);

    @TopicIDs = &RemoveArray(\@TopicIDs,@IgnoreTopics);

    print "<tr>\n";
    print "<td>$StartTime</td>\n";
    if ($Confirmed) {  
      print "<td>$Title</td>\n";
    } else {
      print "<td><i>$Title</i></td>\n";
    }
    print "<td><nobr>$AuthorLink</nobr></td>\n";
    print "<td>"; &ShortTopicListByID(@TopicIDs);   print "</td>\n";
    print "<td>"; &ShortFileListByRevID($DocRevID); print "</td>\n";
    print "<td>$Time</td>\n";
    print "</tr>\n";
  } else {
    #Print out headers here or elsewhere?
  }
}

sub TalkEntryForm (@) {
  my @SessionOrderIDs = @_; 

  require "Scripts.pm";
  print "<table cellpadding=3>\n";
  print "<tr valign=bottom>\n";
  print "<th><b><a "; &HelpLink("sessionorder");  print "Order,</a></b><br/>\n";
  print "    <b><a "; &HelpLink("talkconfirm");   print "Confirm</a><br/>\n";
  print "or  <b><a "; &HelpLink("talkdelete");    print "Delete</a></td>\n";
  print "<th><b><a "; &HelpLink("talkseparator"); print "Separator</a></th>\n";
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
    
    if (grep /n/,$SessionOrderID) { # Erase defaults
      $TalkDefaultTime      = "00:30";
      $TalkDefaultConfirmed = "";
      $TalkDefaultTitle     = "";
      $TalkDefaultNote      = ""; 
      $TalkSeparatorDefault = "";
      $TalkDefaultDocID     = "";
    } else { # Key off Meeting Order IDs, do differently for Sessions and Separators
      if ($SessionOrders{$SessionOrderID}{SessionTalkID}) {
        my $SessionTalkID     = $SessionOrders{$SessionOrderID}{SessionTalkID};
        $TalkDefaultConfirmed = $SessionTalks{$SessionTalkID}{Confirmed}  || "";
        $TalkDefaultTime      = $SessionTalks{$SessionTalkID}{Time}       || "00:30";
        $TalkDefaultTitle     = $SessionTalks{$SessionTalkID}{HintTitle}  || "";
        $TalkDefaultNote      = $SessionTalks{$SessionTalkID}{Note}       || "";
        $TalkDefaultDocID     = $SessionTalks{$SessionTalkID}{DocumentID} || "";
        $TalkSeparatorDefault = "No";
      } elsif ($SessionOrders{$SessionOrderID}{TalkSeparatorID}) {
        my $TalkSeparatorID   = $SessionOrders{$SessionOrderID}{TalkSeparatorID};
        $TalkDefaultConfirmed = "";
        $TalkDefaultTime      = $TalkSeparators{$TalkSeparatorID}{Time}  || "00:30";
        $TalkDefaultTitle     = $TalkSeparators{$TalkSeparatorID}{Title} || "";
        $TalkDefaultNote      = $TalkSeparators{$TalkSeparatorID}{Note}  || "";
        $TalkSeparatorDefault = "Yes";
      }
    } 

    print "<tr valign=top>\n";
    $query -> param('sessionorderid',$SessionOrderID);
    print $query -> hidden(-name => 'sessionorderid', -default => $SessionOrderID);


    print "<td align=left rowspan=2>\n"; &TalkOrder; print "<br/>\n";
    &TalkConfirm($SessionOrderID) ; print "<br/>\n";
    &TalkDelete($SessionOrderID) ; print "</td>\n";

    print "<td align=center rowspan=2>\n"; &TalkSeparator($SessionOrderID); print "</td>\n";
    print "<td align=center rowspan=2>\n"; &TalkDocID($SessionOrderID);                      print "</td>\n";
    print "<td>\n"; &TalkTitle($TalkDefaultTitle);            print "</td>\n";
    print "<td rowspan=2>\n"; &TalkTimePullDown; print "</td>\n";
    print "<td rowspan=2>\n"; &TalkAuthors($SessionOrderID); print "</td>\n";
    print "<td rowspan=2>\n"; &TalkTopics($SessionOrderID); print "</td>\n";
    print "</tr>\n";
    print "<tr valign=top>\n";
    print "<td>\n"; &TalkNote;      print "</td>\n";
    print "</tr>\n";
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
  if ($TalkSeparatorDefault eq "Yes" || $TalkSeparatorDefault eq "No") {
    print $query -> checkbox(-name  => "talkdelete", 
                             -value => "$SessionOrderID", -label => 'Delete');
  } else {
    print "&nbsp\n";
  }
}

sub TalkConfirm ($) {
  my ($SessionOrderID) = @_;
  
  #FIXME Need default here
  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } elsif ($TalkDefaultConfirmed) {  
    print $query -> checkbox(-name  => "talkconfirm", -checked => 'checked', 
                             -value => "$SessionOrderID", -label => 'Confirm');
  } else {  
    print $query -> checkbox(-name  => "talkconfirm", 
                             -value => "$SessionOrderID", -label => 'Confirm');
  }
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
    &AuthorScroll(0,1,"authors-$SessionOrderID",@defaultauthors);
  } 
}

sub TalkTopics ($) {
  my ($SessionOrderID) = @_;

  require "TopicHTML.pm";

  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } else {  
    &FullTopicScroll(1,"topics-$SessionOrderID",@defaulttopics);
  }
}

1;
