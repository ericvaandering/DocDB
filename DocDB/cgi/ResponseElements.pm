#
# Description: Subroutines to provide various parts of HTML about documents
#              and linking to other docs, etc.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

require "AuthorHTML.pm"; #FIXME: Remove, move references to correct place
require "TopicHTML.pm";  #FIXME: Remove, move references to correct place
require "FileHTML.pm";   #FIXME: Remove, move references to correct place

sub PrintTitle {
  my ($Title) = @_;
  if ($Title) {
    print "<h3>$Title</h3>\n";
  } else {
    print "<h3><b>Title:</b> none<br></h3>\n";
  }
}

sub PrintDocNumber { # And type
  my ($DocRevID) = @_;
  print "<table>\n";
  print "<tr><td><b>Document #:</b></td><td>";
  print (&FullDocumentID($DocRevisions{$DocRevID}{DOCID}));
  print "-v$DocRevisions{$DocRevID}{VERSION}";
  print "</td></tr>\n";
  print "<tr><td><b>Document type:</b></td><td>";
  my $type_link = &TypeLink($Documents{$DocRevisions{$DocRevID}{DOCID}}{TYPE},"short");
  print "$type_link</nobr><br>\n";
  print "</td></tr>\n";
  print "</table>\n";
}

sub PrintAbstract {
  my ($Abstract) = @_;
  
  if ($Abstract) {
    $Abstract = &URLify($Abstract);
    $Abstract =~ s/\n\n/<p>/g;
    $Abstract =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt><b>Abstract:</b><br>\n";
    print "<dd>$Abstract<br>\n";
    print "</dl>\n";
  } else {
    print "<b>Abstract:</b> none<br>\n";
  }
}

sub PrintKeywords {
  my ($Keywords) = @_;
  
  $Keywords =~ s/^\s+//;
  $Keywords =~ s/\s+$//;
  
  if ($Keywords) {
    print "<dl>\n";
    print "<dt><b>Keywords:</b><br>\n";
    print "<dd>\n";
    my @Keywords = split /\,*\s+/,$Keywords;
    my $Link;
    foreach my $Keyword (@Keywords) {
      $Link = &KeywordLink($Keyword);
      print "$Link \n";
    }  
    print "<br></dl>\n";
  }
}

sub PrintPubInfo {
  require "Utilities.pm";

  my ($pubinfo) = @_;
  if ($pubinfo) {
    $pubinfo = &URLify($pubinfo);
    $pubinfo =~ s/\n\n/<p>/g;
    $pubinfo =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt><b>Publication Information:</b><br>\n";
    print "<dd>$pubinfo<br>\n";
    print "</dl>\n";
  }
}

sub PrintConfInfo {
  require "TopicSQL.pm";
  require "MeetingSQL.pm";
  require "TopicHTML.pm";
  &SpecialMajorTopics;
  
  my (@topicIDs) = @_;
  foreach $topicID (@topicIDs) {
    if (&MajorIsConference($MinorTopics{$topicID}{MAJOR})) {
      &FetchConferenceByTopicID($topicID);
      my $ConferenceLink = &ConferenceLink($topicID,"long");
      my $Start = &EuroDate($Conferences{$topicID}{StartDate});
      my $End   = &EuroDate($Conferences{$topicID}{EndDate});
      print "<dl>\n";
      print "<dt><b>Conference Information:</b> \n";
      print "<dd>Associated with ";
      print "$ConferenceLink ";
      print " held from $Start to $End \n";
      print " in $Conferences{$topicID}{Location}.</dl>\n";
    }
  }
}

sub PrintReferenceInfo ($) {
  require "MiscSQL.pm";
  require "ReferenceLinks.pm";
  
  my ($DocRevID) = @_;
  
  my @ReferenceIDs = &FetchReferencesByRevision($DocRevID);
  
  if (@ReferenceIDs) {
    &GetJournals;
    print "<dl>\n";
    print "<dt><b>References:</b> \n";
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
      print ".\n";
    }
    print "</dl>\n";
  }
}

sub SecurityListByID {
  my (@GroupIDs) = @_;
  
  if ($EnhancedSecurity) {
    print "<b>Viewable by:</b><br>\n";
  } else {  
    print "<b>Restricted to:</b><br>\n";
  }  
  
  print "<ul>\n";
  if (@GroupIDs) {
    foreach $GroupID (@GroupIDs) {
      print "<li>$SecurityGroups{$GroupID}{NAME}</li>\n";
    }
  } else {
    print "<li>Public document</li>\n";
  }
  print "</ul>\n";
}

sub ModifyListByID {
  my (@GroupIDs) = @_;
  
  if (@GroupIDs) {
    print "<b>Modifiable by:</b><br>\n";
    print "<ul>\n";
    foreach $GroupID (@GroupIDs) {
      print "<li>$SecurityGroups{$GroupID}{NAME}</li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Security:</b> Public document<br>\n";
  }
}

sub PrintRevisionInfo {

  require "FormElements.pm";
  require "AuthorSQL.pm";
  require "SecuritySQL.pm";
  require "TopicSQL.pm";
 
  my ($DocRevID,$HideButtons) = @_;

  &FetchRevisionByDocumentAndVersion($DocRevID);

  my $DocumentID  = $DocRevisions{$DocRevID}{DOCID};
  my $Version     = $DocRevisions{$DocRevID}{VERSION};
  my @AuthorIDs   = &GetRevisionAuthors($DocRevID);
  my @TopicIDs    = &GetRevisionTopics($DocRevID);
  my @GroupIDs    = &GetRevisionSecurityGroups($DocRevID);
  my @ModifyIDs;
  if ($EnhancedSecurity) {
    @ModifyIDs   = &GetRevisionModifyGroups($DocRevID);
  }
  print "<center><table cellpadding=10 width=95%>\n";
  print "<tr><td colspan=3 align=center>\n";
  &PrintTitle($DocRevisions{$DocRevID}{TITLE});
  print "</td></tr>\n";
  print "<tr valign=top>";
  print "<td>";
  
  print "<table>\n"; 
  &RequesterByID($Documents{$DocumentID}{REQUESTER});
  &SubmitterByID($DocRevisions{$DocRevID}{SUBMITTER});
  print "</table>\n"; 

  print "<td>"; 
  &PrintDocNumber($DocRevID);

  print "<td>"; 
  &ModTimes;

  print "</td></tr>\n";
  print "</table>\n";
  print "<table cellpadding=10 width=95%>\n";
  print "<tr valign=top>";
  print "<td>"; 
  &AuthorListByID(@AuthorIDs);

  print "<td>"; 
  &TopicListByID(@TopicIDs);

  print "<td>"; 
  &SecurityListByID(@GroupIDs);
  if ($EnhancedSecurity) {
    print "<td>"; 
    &ModifyListByID(@ModifyIDs);
  }
  print "</td></tr>\n";
  print "</table>\n";
  print "<table cellpadding=10 width=95%>\n";
  print "<tr valign=top>";
  print "<td>"; 
  &PrintAbstract($DocRevisions{$DocRevID}{ABSTRACT});

  print "<td rowspan=3>"; 
  &FileListByRevID($DocRevID);

  print "</td></tr>\n";

  print "<tr valign=top>";
  print "<td>"; 
  &PrintKeywords($DocRevisions{$DocRevID}{Keywords});

  print "<tr valign=top>";
  print "<td>"; 
  &PrintPubInfo($DocRevisions{$DocRevID}{PUBINFO});
  &PrintConfInfo(@TopicIDs);
  &PrintReferenceInfo($DocRevID);
  print "</td></tr>\n";
  print "</table>\n";
  print "<table cellpadding=10>\n";
  if (&CanModify($DocumentID) && !$HideButtons) {
    print "<tr valign=top>";
    print "<td align=center width=33%>";
    &UpdateButton($DocumentID);
    print "<td align=center width=33%>";
    &UpdateDBButton($DocumentID,$Version);
    print "<td align=center width=33%>";
    &AddFilesButton($DocumentID,$Version);
    print "</td></tr>\n";
  }  

  print "</table></center>\n"; 
}
 
sub WarnPage { # Non-fatal errors
  my @errors = @_;
  if (@errors) {
    if ($#errors) {
      print "<b><font color=\"red\">There were non-fatal errors processing your
             request: </font></b><br>\n";
    } else {
      print "<b><font color=\"red\">There was a non-fatal error processing your
             request: </font></b><br>\n";
    } 
    foreach $message (@errors) {
      print "<dt><b>$message</b><br>\n";
    } 
    print "<p>\n";
  }   
}

sub EndPage {  # Fatal errors, aborts page if present
  my @errors = @_;
  if (@errors) {
    if ($#errors) {
      print "<b><font color=\"red\">There were fatal errors processing your
             request: </font></b><br>\n";
    } else {
      print "<b><font color=\"red\">There was a fatal error processing your
             request: </font></b><br>\n";
    } 
    foreach $message (@errors) {
      print "<dt><b>$message</b><br>\n";
    }  
    print "<p>\n";
    &DocDBNavBar();
    &DocDBFooter($DBWebMasterEmail,$DBWebMasterName);
    exit;
  }  
}

sub ErrorPage { # Fatal errors, continues page
  my @errors = @_;
  if (@errors) {
    print "<b><font color=\"red\">There was a fatal error processing your request:
    </font></b><br>\n";
    foreach $message (@errors) {
      print "<dt><b>$message</b><br>\n";
    }  
    print "<p>\n";
  }  
}

sub FullDocumentID ($;$) {
  my ($DocumentID,$Version) = @_;
  if (defined $Version) {
    return "$ShortProject-doc-$DocumentID-v$Version";
  } else {  
    return "$ShortProject-doc-$DocumentID";
  }  
}  

sub DocumentLink { #FIXME: Make Version optional, Document URL 
  my ($DocumentID,$Version,$Title) = @_;
  my $Link = "<a href=\"$ShowDocument\?docid=$DocumentID\&version=$Version\">";
  if ($Title) {
    $Link .= $Title;
  } else {
    $Link .= &FullDocumentID($DocumentID,$Version);
  }
  $Link .=  "</a>";
}         

sub DocumentURL {
  my ($DocumentID,$Version) = @_;
  my $URL;
  if (defined $Version) {
    $URL =  "$ShowDocument\?docid=$DocumentID\&version=$Version";
  } else {  
    $URL =  "$ShowDocument\?docid=$DocumentID";
  }  
  return $URL
}

sub KeywordLink {
  my ($Keyword) = @_;
  my $ret = "<a href=\"$Search\?innerlogic=AND&outerlogic=AND&keywordsearchmode=anysub&keywordsearch=$Keyword\">";
  $ret .= "$Keyword";
  $ret .=  "</a>";
  return $ret;
}         

sub ModTimes {
  my ($DocRevID) = @_;
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  $DocTime     = &EuroDateHM($Documents{$DocumentID}{DATE}); 
  $RevTime     = &EuroDateHM($DocRevisions{$DocRevID}{DATE}); 
  $VersionTime = &EuroDateHM($DocRevisions{$DocRevID}{VersionDate}); 
  print "<table>\n";
  print "<tr><td align=right><b>Document Created:</b></td><td>$DocTime</td></tr>\n";
  print "<tr><td align=right><b>Contents Revised:</b></td><td>$VersionTime</td></tr>\n";
  print "<tr><td align=right><b>DB Info Revised:</b></td><td>$RevTime</td></tr>\n";
  print "</table>\n";
}

sub EuroDate {
  my ($sql_datetime) = @_;
  unless ($sql_datetime) {return "";}
  
  my ($date,$time) = split /\s+/,$sql_datetime;
  my ($year,$month,$day) = split /\-/,$date;
  $return_date = "$day ".("Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec")[$month-1].
                 " $year"; 
  return $return_date;
}

sub EuroDateTime {
  my ($sql_datetime) = @_;
  unless ($sql_datetime) {return "";}
  
  my ($date,$time) = split /\s+/,$sql_datetime;
  my ($year,$month,$day) = split /\-/,$date;
  $return_date = "$time ".
                 "$day ".("Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec")[$month-1].
                 " $year"; 
  return $return_date;
}

sub EuroDateHM($) {
  my ($SQLDatetime) = @_;
  unless ($SQLDatetime) {return "";}
  
  my ($Date,$Time) = split /\s+/,$SQLDatetime;
  my ($Year,$Month,$Day) = split /\-/,$Date;
  my ($Hour,$Min,$Sec) = split /:/,$Time;
  $ReturnDate = "$Day ".("Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec")[$Month-1].
                " $Year, $Hour:$Min"; 
  return $ReturnDate;
}

sub OtherVersionLinks {
  require "Sorts.pm";
  
  my ($DocumentID,$CurrentVersion) = @_;
  my @RevIDs   = reverse sort RevisionByVersion &FetchRevisionsByDocument($DocumentID);
  
  unless ($#RevIDs > 0) {return;}
  print "<center>\n";
  print "<table><tr><td>\n";
  print "<b>Other Versions of this document: </b>\n";
  print "<ul>\n";
  foreach $RevID (@RevIDs) {
    my $Version = $DocRevisions{$RevID}{VERSION};
    if ($Version == $CurrentVersion) {next;}
    unless (&CanAccess($DocumentID,$Version)) {next;}
    $link = &DocumentLink($DocumentID,$Version);
    $date = &EuroDateTime($DocRevisions{$RevID}{DATE});
    print "<li>$link \&nbsp \&nbsp ($date)</li>\n";
  }
  print "</ul>\n";
  print "</td></tr></table>\n";
  print "</center>\n";
}

sub DocumentSummary { # One line summary for lists, uses non-standard <nobr>
  require "MiscSQL.pm";
  require "TopicSQL.pm";
  
  my ($DocumentID,$Mode,$Version) = @_;
  unless (defined $Version) {$Version = $Documents{$DocumentID}{NVER}}
  unless ($Mode) {$Mode = "date"};
  
  if ($DocumentID) {
    &FetchDocument($DocumentID);
    unless (&CanAccess($DocumentID,$Version)) {return;}
    
    my $full_docid  = &DocumentLink($DocumentID,$Version);
    my $DocRevID    = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    my $title       = &DocumentLink($DocumentID,$Version,$DocRevisions{$DocRevID}{TITLE});
    if ($Mode eq "meeting") {
      my @FileIDs   = &FetchDocFiles($DocRevID);
    }

    my $rev_date    = &EuroDate($DocRevisions{$DocRevID}{DATE});
    my $author_link = &FirstAuthor($DocRevID);
    print "<tr valign=top>\n";
    if ($Mode eq "date") {
      print "<td><nobr>$full_docid</nobr></td>\n";
      print "<td>$title</td>\n";
      print "<td><nobr>$author_link</nobr></td>\n";
      print "<td><nobr>$rev_date</nobr></td>\n";
    } elsif ($Mode eq "meeting") {
      my @TopicIDs = &GetRevisionTopics($DocRevID);
      foreach my $ID (@IgnoreTopics) {
        my $Index = 0;
        foreach my $TopicID (@TopicIDs) {
          if ($TopicID == $ID) {
            splice @TopicIDs,$Index,1;
            last;
          }
          ++$Index;  
        }
      }  
      print "<td>$title</td>\n";
      print "<td><nobr>$author_link</nobr></td>\n";
      print "<td>"; &ShortTopicListByID(@TopicIDs); print "</td>\n";
      print "<td>"; &ShortFileListByRevID($DocRevID); print "</td>\n";
    } elsif ($Mode eq "conference") {
      print "<td>$title</td>\n";
      print "<td>\n";

      my @topics = &GetRevisionTopics($DocRevID);
      foreach my $topic (@topics) {
        if (&MajorIsConference($MinorTopics{$topic}{MAJOR})) {
          my $conference_link = &ConferenceLink($topic,"short");
          print "$conference_link<br>\n";
        }  
      }
      print "</td>\n";
      print "<td><nobr>$author_link</nobr></td>\n";
      print "<td>"; &ShortFileListByRevID($DocRevID); print "</td>\n";
    }  
    print "</tr>\n";
  } else { # Print header if $DocumentID = 0
    print "<tr valign=bottom>\n";
    if ($Mode eq "date") {
      print "<th>Document #</th>\n";
      print "<th>Title</th>\n";
      print "<th>Author</th>\n";
      print "<th>Last Updated</th>\n";
    } elsif ($Mode eq "meeting") {
      print "<th>Title</th>\n";
      print "<th>Author</th>\n";
      print "<th>Topic(s)</th>\n";
      print "<th>Files</th>\n";
    } elsif ($Mode eq "conference") {
      &GetTopics;
      print "<th>Title</th>\n";
      print "<th>Conference</th>\n";
      print "<th>Author</th>\n";
      print "<th>Files</th>\n";
    }  
    print "</tr>\n";
  } 
}

sub TypesTable {
  my $NCols = 3;
  my @TypeIDs = keys %DocumentTypes;

  my $Col   = 0;
  print "<table cellpadding=10>\n";
  foreach my $TypeID (@TypeIDs) {
    unless ($Col % $NCols) {
      print "<tr valign=top>\n";
    }
    $link = &TypeLink($TypeID,"short");
    print "<td>$link\n";
    ++$Col;
  }  

  print "</table>\n";
}

sub TypeLink {
  my ($TypeID,$mode) = @_;
  
  require "MiscSQL.pm";
  
  &FetchDocType($TypeID);
  my $link = "";
  unless ($Public) {
    $link .= "<a href=$ListByType?typeid=$TypeID>";
  }
  if ($mode eq "short") {
    $link .= $DocumentTypes{$TypeID}{SHORT};
  } else {
    $link .= $DocumentTypes{$TypeID}{LONG};
  }
  unless ($Public) {
    $link .= "</a>";
  }
  
  return $link;
}

sub PrintAgenda {
  my ($MeetingID) = @_; 
  
  my ($DocRevID) = &FindAgendaRevision($MeetingID);
  if ($DocRevID) {
    &FetchDocRevisionByID($DocRevID); 
    my @FileIDs  = &FetchDocFiles($DocRevID);                                                                                             
    my $FirstFile = shift @FileIDs;   #FIXME: Collapse to one line

    print "<h3>Agenda:</h3>\n";
    &PrintFile($FirstFile);
  }
}

sub FindAgendaRevision {
  require "MiscSQL.pm";
  my ($MeetingID) = @_; 
  
  my $agenda_base = 
    "select DocumentRevision.DocRevID from DocumentRevision,RevisionTopic ".
    "where DocumentRevision.DocRevID=RevisionTopic.DocRevID ".
     "and RevisionTopic.MinorTopicID=$MeetingID "; 
  my $agenda_find = $dbh -> prepare ($agenda_base.
     "and lower(DocumentRevision.DocumentTitle) like lower(\"agenda%\") ".
     "and DocumentRevision.Obsolete=0");
  
  my $AgendaRevID = 0;
  my $DocRevID;

  $agenda_find -> execute();
  $agenda_find -> bind_columns(undef, \($DocRevID));
  while ($agenda_find -> fetch && !$AgendaRevID) {
    &FetchDocRevisionByID($DocRevID); 
    if ($DocRevisions{$DocRevID}{OBSOLETE}) {next;}
    my $DocID = &FetchDocument($DocRevisions{$DocRevID}{DOCID});
    if ($DocRevisions{$DocRevID}{VERSION} != $Documents{$DocID}{NVER}) {next;}
    $AgendaRevID = $DocRevID;
  }

  unless ($AgendaRevID) {
    my $agenda_find = $dbh -> prepare ($agenda_base.
       "and lower(DocumentRevision.DocumentTitle) like lower(\"%agenda%\") ".
       "and DocumentRevision.Obsolete=0");
  
    $agenda_find -> execute();
    $agenda_find -> bind_columns(undef, \($DocRevID));
    while ($agenda_find -> fetch && !$AgendaRevID) {
      &FetchDocRevisionByID($DocRevID); 
      if ($DocRevisions{$DocRevID}{OBSOLETE}) {next;}
      my $DocID = &FetchDocument($DocRevisions{$DocRevID}{DOCID});
      if ($DocRevisions{$DocRevID}{VERSION} != $Documents{$DocID}{NVER}) {next;}
      $AgendaRevID = $DocRevID;
    }
  }
    
  return $AgendaRevID;
}

sub FindAgendaURL {
  require "FSUtilities.pm";
  my ($MeetingID) = @_; 
  
  my ($DocRevID) = &FindAgendaRevision($MeetingID);

  if ($DocRevID) {
    &FetchDocRevisionByID($DocRevID); 
    my @FileIDs  = &FetchDocFiles($DocRevID);  
    foreach my $FileID (@FileIDs) {
      unless ($DocFiles{$FileID}{ROOT}) {next;}
      my $VersionNumber = $DocRevisions{$DocRevID}{VERSION};
      my $DocumentID    = $DocRevisions{$DocRevID}{DOCID}  ;

      my $Directory     = &GetURLDir($DocumentID,$VersionNumber);  

      my $FileName      = $Directory.$DocFiles{$FileID}{NAME};
      return $FileName;
    }
  } else {
    return 0;
  }  
}

sub PrintFile {
  require "FSUtilities.pm";
  my ($FileID) = @_;
  
  my $DocRevID      = $DocFiles{$FileID}{DOCREVID};
  my $VersionNumber = $DocRevisions{$DocRevID}{VERSION};
  my $DocumentID    = $DocRevisions{$DocRevID}{DOCID}  ;
  
  my $Directory     = &GetDirectory($DocumentID,$VersionNumber);  
  
  my $FileName      = $Directory.$DocFiles{$FileID}{NAME};  
    
  if (grep /text/,`file $FileName`) {
    open FILE,$FileName;
    my @FileLines = <FILE>;
    close FILE;

    if (grep /html$/,$FileName) {
      print "<div id=\"includedfile\">\n";
      print @FileLines;
      print "</div>\n";
    } else {
      print "<pre>\n";
      print @FileLines;
      print "</pre>\n";
    }    
  } else {
    print "<b>Non-text file</b>\n";
  }  
}
    
1;
