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

sub TitleBox (%) {
  my (%Params) = @_; 
  
  my $Required   = $Params{-required}   || 0;

  print "<b><a ";
  &HelpLink("title");
  print "Title:</a></b>";
  if ($Required) {
    print $RequiredMark;
  }  
  print "<br> \n";
  print $query -> textfield (-name => 'title', -default => $TitleDefault, 
                             -size => 70, -maxlength => 240);
};

sub AbstractBox (%) {
  my (%Params) = @_; 
  
  my $Required = $Params{-required} || 0;
  my $HelpLink = $Params{-helplink} || "abstract";
  my $HelpText = $Params{-helptext} || "Abstract";
  my $Name     = $Params{-name}     || "abstract";
  my $Columns  = $Params{-columns}  || 60;
  my $Rows     = $Params{-rows}     || 6;

  if ($HelpLink) {
    print "<b><a ";
    &HelpLink($HelpLink);
    print "$HelpText</a></b>";
    if ($Required) {
      print $RequiredMark;
    }  
    print "<br> \n";
  }  
  print $query -> textarea (-name    => $Name, -default => $AbstractDefault,
                            -rows    => $Rows, -columns => $Columns);
};

sub RevisionNoteBox {
  my (%Params) = @_;
  my $Default  = $Params{-default}  || "";
  my $JSInsert = $Params{-jsinsert} || "";
  print "<a name=\"RevisionNote\">";
  print "<b><a ";
  &HelpLink("revisionnote");
  print "Notes and Changes:</a> </b>\n";

  # Convert text string w/ control characters to JS literal

  if ($JSInsert) {
    $JSInsert =~ s/\n/\\n/g;
    $JSInsert =~ s/\r//g;
    $JSInsert =~ s/\'/\\\'/g;
    $JSInsert =~ s/\"/\\\'/g; # FIXME: See if there is a way to insert double quotes
                              #        Bad HTML/JS interaction, I think

    print "<a href=\"#RevisionNote\" onClick=\"InsertRevisionNote('$JSInsert');\">(Insert notes from previous version)</a>";
  }
  print "<br>\n";
  print $query -> textarea (-name => 'revisionnote', -default => $Default,
                            -columns => 60, -rows => 6);
};

sub DocTypeButtons (%) {
# FIXME Get rid of fetches, make sure GetDocTypes is executed
  my (%Params) = @_; 
  
  my $Required   = $Params{-required}   || 0;

  my ($DocTypeID,$ShortType,$LongType);
  my $doctype_list  = $dbh->prepare("select DocTypeID,ShortType,LongType from DocumentType");
  $doctype_list -> execute;
  $doctype_list -> bind_columns(undef, \($DocTypeID,$ShortType,$LongType));
  while ($doctype_list -> fetch) {
    $doc_type{$DocTypeID}{SHORT} = $ShortType;
    $short_type{$DocTypeID}      = $ShortType;
    $doc_type{$DocTypeID}{LONG}  = $LongType;
  }
  @values = keys %short_type;
  
  print "<b><a ";
  &HelpLink("doctype");
  print "Document type:</a></b>";
  if ($Required) {
    print $RequiredMark;
  }  
  print "<br> \n";
  print $query -> radio_group(-columns => 3, -name => "doctype", 
                              -values => \%short_type, -default => "-");
};

sub PrintRevisionInfo {
  require "FormElements.pm";
  require "Security.pm";

  require "AuthorSQL.pm";
  require "SecuritySQL.pm";
  require "TopicSQL.pm";
 
  require "AuthorHTML.pm";
  require "DocumentHTML.pm";
  require "FileHTML.pm";
  require "SecurityHTML.pm";
  require "TopicHTML.pm";
  require "XRefHTML.pm";
  
  my ($DocRevID,%Params) = @_;
  
  my $HideButtons  = $Params{-hidebuttons}  || 0;
  my $HideVersions = $Params{-hideversions} || 0;
  
  &FetchDocRevisionByID($DocRevID);
  
  my $DocumentID  = $DocRevisions{$DocRevID}{DOCID};
  my $Version     = $DocRevisions{$DocRevID}{VERSION};
  my @AuthorIDs   = &GetRevisionAuthors($DocRevID);
  my @TopicIDs    = &GetRevisionTopics($DocRevID);
  my @GroupIDs    = &GetRevisionSecurityGroups($DocRevID);
  my @ModifyIDs;
  if ($EnhancedSecurity) {
    @ModifyIDs   = &GetRevisionModifyGroups($DocRevID);
  }
  
  print "<div id=\"RevisionInfo\">\n";
  
  ### Header info
  
  print "<div id=\"Header3Col\">\n";

  print "<div id=\"DocTitle\">\n";
   &PrintTitle($DocRevisions{$DocRevID}{Title});
   if ($UseSignoffs) {
     require "SignoffUtilities.pm";
     my ($ApprovalStatus,$LastApproved) = &RevisionStatus($DocRevID);
     unless ($ApprovalStatus eq "Unmanaged") { 
       print "<h5>(Document Status: $ApprovalStatus)</h5>\n";
     }  
   }  
  print "</div>\n";  # DocTitle
  print "</div>\n";  # Header3Col

  ### Left Column

  print "<div id=\"LeftColumn3Col\">\n";
  
  print "<div id=\"BasicDocInfo\">\n";
  print "<dl>\n";
   &PrintDocNumber($DocRevID);
   &RequesterByID($Documents{$DocumentID}{REQUESTER});
   &SubmitterByID($DocRevisions{$DocRevID}{Submitter});
   &PrintModTimes;
  print "</dl>\n";
  print "</div>\n";  # BasicDocInfo

  if (&CanModify($DocumentID) && !$HideButtons) {
    print "<div id=\"UpdateButtons\">\n";
    &UpdateButton($DocumentID);
    &UpdateDBButton($DocumentID,$Version);
    &AddFilesButton($DocumentID,$Version);
    print "</div>\n";
  }  

  unless ($Public || $HideButtons) {
    require "NotificationHTML.pm";
    &DocNotifySignup(-docid => $DocumentID);
  }

  print "</div>\n";  # LeftColumn3Col

  ### Main Column
  
  print "<div id=\"MainColumn3Col\">\n";

  ### Right column (wrapped around by middle column)

  print "<div id=\"RightColumn3Col\">\n";
  
  &SecurityListByID(@GroupIDs);
  &ModifyListByID(@ModifyIDs);
  unless ($HideVersions) {
    &OtherVersionLinks($DocumentID,$Version);
  }
  
  print "</div>\n";  # RightColumn3Col

  &PrintAbstract($DocRevisions{$DocRevID}{ABSTRACT}); # All are called only here, so changes are OK
  &FileListByRevID($DocRevID); # All are called only here, so changes are OK
  &TopicListByID(@TopicIDs);
  &AuthorListByID(@AuthorIDs);
  &PrintKeywords($DocRevisions{$DocRevID}{Keywords});
  &PrintRevisionNote($DocRevisions{$DocRevID}{Note});
  &PrintXRefInfo($DocRevID);
  &PrintReferenceInfo($DocRevID);
  &PrintConfInfo(@TopicIDs);
  &PrintPubInfo($DocRevisions{$DocRevID}{PUBINFO});
  
  if ($UseSignoffs) {
    require "SignoffHTML.pm";
    &PrintRevisionSignoffInfo($DocRevID);
  }  

  print "</div>\n";  # MainColumn3Col
  
  print "<div id=\"Footer3Col\">\n"; # Must have to keep NavBar on true bottom
  print "</div>\n";  # Footer3Col
  print "</div>\n";  # RevisionInfo
}
 
sub PrintAbstract {
  my ($Abstract) = @_;
  
  if ($Abstract) {
    $Abstract = &URLify($Abstract);
    $Abstract =~ s/\n\n/<p\/>/g;
    $Abstract =~ s/\n/<br\/>/g;
  } else {
    $Abstract = "None";
  }  
  print "<div id=\"Abstract\">\n";
  print "<dl>\n";
  print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Abstract:</span></dt>\n";
  print "<dd>$Abstract</dd>\n";
  print "</dl>\n";
  print "</div>\n";
}

sub PrintKeywords {
  my ($Keywords) = @_;
  
  require "KeywordHTML.pm";
  
  $Keywords =~ s/^\s+//;
  $Keywords =~ s/\s+$//;
  
  if ($Keywords) {
    print "<div id=\"Keywords\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Keywords:</span></dt>\n";
    print "<dd>\n";
    my @Keywords = split /\,*\s+/,$Keywords;
    my $Link;
    foreach my $Keyword (@Keywords) {
      $Link = &KeywordLink($Keyword);
      print "$Link \n";
    }  
    print "</dd></dl>\n";
    print "</div>\n";
  }
}

sub PrintRevisionNote {
  require "Utilities.pm";

  my ($RevisionNote) = @_;
  if ($RevisionNote) {
    print "<div id=\"RevisionNote\">\n";
    $RevisionNote = &URLify($RevisionNote);
    $RevisionNote =~ s/\n\n/<p\/>/g;
    $RevisionNote =~ s/\n/<br\/>/g;
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Notes and Changes:</span></dt>\n";
    print "<dd>$RevisionNote</dd>\n";
    print "</dl>\n";
    print "</div>\n";
  }
}

sub PrintReferenceInfo ($) {
  require "MiscSQL.pm";
  require "ReferenceLinks.pm";
  
  my ($DocRevID) = @_;
  
  my @ReferenceIDs = &FetchReferencesByRevision($DocRevID);
  
  if (@ReferenceIDs) {
    &GetJournals;
    print "<div id=\"ReferenceInfo\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Journal References:</span></dt>\n";
    foreach my $ReferenceID (@ReferenceIDs) {
      $JournalID = $RevisionReferences{$ReferenceID}{JournalID};
      print "<dd>Published in ";
      my ($ReferenceLink,$ReferenceText) = &ReferenceLink($ReferenceID);
      if ($ReferenceLink) {
        print "<a href=\"$ReferenceLink\">";
      }  
      if ($ReferenceText) {
        print "$ReferenceText";
      } else {  
        print "$Journals{$JournalID}{Abbreviation} ";
        if ($RevisionReferences{$ReferenceID}{Volume}) {
          print " vol. $RevisionReferences{$ReferenceID}{Volume}";
        }
        if ($RevisionReferences{$ReferenceID}{Page}) {
          print " pg. $RevisionReferences{$ReferenceID}{Page}";
        }
      }  
      if ($ReferenceLink) {
        print "</a>";
      }  
      print ".</dd>\n";
    }
    print "</dl>\n";
    print "</div>\n";
  }
}

sub PrintConfInfo {
  require "TopicSQL.pm";
  require "MeetingSQL.pm";
  require "TopicHTML.pm";
  &SpecialMajorTopics;
  
  my (@topicIDs) = @_;
  my $HasConference = 0;
  foreach $topicID (@topicIDs) {
    if (&MajorIsConference($MinorTopics{$topicID}{MAJOR})) {
      &FetchConferenceByTopicID($topicID);
      unless ($HasConference) {
        print "<div id=\"ConferenceInfo\">\n";
        $HasConference = 1;
      }  
      my $ConferenceLink = &ConferenceLink($topicID,"long");
      my $ConferenceID = $ConferenceMinor{$topicID};
      my $Start = &EuroDate($Conferences{$ConferenceID}{StartDate});
      my $End   = &EuroDate($Conferences{$ConferenceID}{EndDate});
      print "<dl>\n";
      print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Conference Information:</span></dt> \n";
      print "<dd>Associated with ";
      print "$ConferenceLink ";
      print " held from $Start to $End \n";
      print " in $Conferences{$ConferenceID}{Location}.</dd></dl>\n";
    }
  }
  if ($HasConference) {
    print "</div>\n";
  }  
}

sub PrintPubInfo ($) {
  require "Utilities.pm";

  my ($pubinfo) = @_;
  if ($pubinfo) {
    print "<div id=\"PubInfo\">\n";
    $pubinfo = &URLify($pubinfo);
    $pubinfo =~ s/\n\n/<p>/g;
    $pubinfo =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Publication Information:</span></dt>\n";
    print "<dd>$pubinfo</dd>\n";
    print "</dl>\n";
    print "</div>\n";
  }
}

sub PrintModTimes {
  my ($DocRevID) = @_;
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  $DocTime     = &EuroDateHM($Documents{$DocumentID}{DATE}); 
  $RevTime     = &EuroDateHM($DocRevisions{$DocRevID}{DATE}); 
  $VersionTime = &EuroDateHM($DocRevisions{$DocRevID}{VersionDate}); 

  print "<dt>Document Created:</dt>\n<dd>$DocTime</dd>\n";
  print "<dt>Contents Revised:</dt>\n<dd>$VersionTime</dd>\n";
  print "<dt>DB Info Revised:</dt>\n<dd>$RevTime</dd>\n";
}

sub OtherVersionLinks {
  require "Sorts.pm";
  
  my ($DocumentID,$CurrentVersion) = @_;
  my @RevIDs   = reverse sort RevisionByVersion &FetchRevisionsByDocument($DocumentID);
  
  unless ($#RevIDs > 0) {return;}
  print "<div id=\"OtherVersions\">\n";
  print "<b>Other Versions:</b>\n";
  
  print "<table id=\"OtherVersionTable\" class=\"Alternating\">\n";
  my $RowClass = "Odd";
  
  foreach $RevID (@RevIDs) {
    my $Version = $DocRevisions{$RevID}{VERSION};
    if ($Version == $CurrentVersion) {next;}
    unless (&CanAccess($DocumentID,$Version)) {next;}
    $link = &DocumentLink($DocumentID,$Version);
    $date = &EuroDateHM($DocRevisions{$RevID}{DATE});
    print "<tr class=\"$RowClass\"><td>$link\n";
    if ($RowClass eq "Odd") {  
      $RowClass = "Even";
    } else {    
      $RowClass = "Odd";
    }  
    print "<br/>$date\n";
    if ($UseSignoffs) {
      require "SignoffUtilities.pm";
      my ($ApprovalStatus,$LastApproved) = &RevisionStatus($RevID);
      unless ($ApprovalStatus eq "Unmanaged") { 
        print "<br/>$ApprovalStatus";
      }  
    }  
    print "</td></tr>\n";
  }

  print "</table>\n";
  print "</div>\n";
}

1;
