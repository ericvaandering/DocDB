#
# Description: Subroutines to provide various parts of HTML about documents
#              and linking to other docs, etc.
#
#              THIS FILE IS DEPRECATED. DO NOT PUT NEW ROUTINES HERE, USE *HTML
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2004 Eric Vaandering, Lynn Garren, Adam Bryant

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

require "AuthorHTML.pm"; #FIXME: Remove, move references to correct place
require "TopicHTML.pm";  #FIXME: Remove, move references to correct place
require "FileHTML.pm";   #FIXME: Remove, move references to correct place
require "RevisionHTML.pm";   #FIXME: Remove, move references to correct place

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
      my $ConferenceID = $ConferenceMinor{$topicID};
      my $Start = &EuroDate($Conferences{$ConferenceID}{StartDate});
      my $End   = &EuroDate($Conferences{$ConferenceID}{EndDate});
      print "<dl>\n";
      print "<dt><b>Conference Information:</b> \n";
      print "<dd>Associated with ";
      print "$ConferenceLink ";
      print " held from $Start to $End \n";
      print " in $Conferences{$ConferenceID}{Location}.</dl>\n";
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
  
  print "<b>Modifiable by:</b><br>\n";
  print "<ul>\n";
  if (@GroupIDs) {
    foreach $GroupID (@GroupIDs) {
      print "<li>$SecurityGroups{$GroupID}{NAME}</li>\n";
    }
  } else {
    print "<li>Same as Viewable by</li>\n";
  }
  print "</ul>\n";
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

sub DebugPage (;$) { # Debugging output
  my ($CheckPoint) = @_; 
  if (@DebugStack && $DebugOutput) {
    print "<b><font color=\"red\">Debugging messages: </font>$CheckPoint</b><br/>\n";
    foreach my $Message (@DebugStack) {
      print "<dt/>$Message<br/>\n";
    } 
    print "<p/>\n";
  } elsif ($CheckPoint && $DebugOutput) {
    print "No Debugging messages: $CheckPoint<br/>\n";
  }  
  @DebugStack = ();
  return @DebugStack;
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

sub DocumentLink { #FIXME: Make Version optional, Document URL, "title" mode 
  my ($DocumentID,$Version,$Title) = @_;
  my $DocNumber .= &FullDocumentID($DocumentID,$Version);
  my $Link = "<a title=\"$DocNumber\" href=\"$ShowDocument\?docid=$DocumentID\&version=$Version\">";
  if ($Title) {
    $Link .= $Title;
  } else {
    $Link .= $DocNumber;
  }
  $Link .=  "</a>";
}         

sub NewDocumentLink ($;$$) { # FIXME: Make this the default
  #FIXME: Figure out how to do modes like CGI.pm
  my ($DocumentID,$Version,$Mode) = @_;
  
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  
  &FetchDocument($DocumentID);
  my $GivenVersion = false;
  unless (defined $Version) {
    $Version      = $Documents{$DocumentID}{NVersions};
    $GivenVersion = true;
  }
  my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
  my $Link = "<a href=\"$ShowDocument\?docid=$DocumentID";
  if ($GivenVersion) {
    $Link .= "&version=$Version";
  }
  $Link .= "\">"; 
  if ($Mode eq "title") {
    $Link .= $DocRevisions{$DocRevID}{Title};
  } elsif ($Mode eq "number_only") {
    $Link .= $DocumentID."-v".$Version;
  } else {
    $Link .= &FullDocumentID($DocumentID,$Version);
  }
  $Link .=  "</a>";
  return $Link;
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
    print "<li>$link \n";
    if ($UseSignoffs) {
      require "SignoffUtilities.pm";
      my ($ApprovalStatus,$LastApproved) = &RevisionStatus($RevID);
      unless ($ApprovalStatus eq "Unmanaged") { 
        print " \&nbsp $ApprovalStatus";
      }  
    }  
    print " \&nbsp ($date)</li>\n";
  }
  print "</ul>\n";
  print "</td></tr></table>\n";
  print "</center>\n";
}

sub DocumentSummary { # One line summary for lists, uses non-standard <nobr>
  require "MiscSQL.pm";
  require "TopicSQL.pm";
  
  require "Utilities.pm";
  require "Security.pm";
  
  my ($DocumentID,$Mode,$Version) = @_;
  unless (defined $Version) {$Version = $Documents{$DocumentID}{NVersions}}
  unless ($Mode) {$Mode = "date"};
  
  if ($DocumentID) {
    &FetchDocument($DocumentID);
    unless (&CanAccess($DocumentID,$Version)) {return;}
    
    my $full_docid  = &DocumentLink($DocumentID,$Version);
    my $short_docid = &NewDocumentLink($DocumentID,$Version,"number_only");
    my $DocRevID    = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    my $title       = &DocumentLink($DocumentID,$Version,$DocRevisions{$DocRevID}{Title});
    if ($Mode eq "meeting") {
      my @FileIDs   = &FetchDocFiles($DocRevID);
    }

    if ($UseSignoffs) {
      require "SignoffUtilities.pm";
      my ($ApprovalStatus,$LastApproved) = &RevisionStatus($DocRevID);
      unless ($ApprovalStatus eq "Unmanaged") { 
        $title .= "<br>($ApprovalStatus";
        if ($ApprovalStatus eq "Unapproved") {
          if (defined $LastApproved) {
            my $DocumentID = $DocRevisions{$LastApproved}{DOCID};
            my $Version    = $DocRevisions{$LastApproved}{Version};
            my $LastLink   = &DocumentLink($DocumentID,$Version,"version $Version");
            $title .= " - Last approved: $LastLink";
          } else {
            $title .= " - No approved version";
          }
        }
        $title .= ")";
      }  
    }  
    
    my $rev_date    = &EuroDate($DocRevisions{$DocRevID}{DATE});
    my $author_link = &FirstAuthor($DocRevID);
    print "<tr valign=top>\n";
    if ($Mode eq "date") {
      print "<td><nobr>$short_docid</nobr></td>\n";
      print "<td>$title</td>\n";
      print "<td><nobr>$author_link</nobr></td>\n";
      print "<td><nobr>$rev_date</nobr></td>\n";
    } elsif ($Mode eq "meeting") {
      my @TopicIDs = &GetRevisionTopics($DocRevID);
      
      @TopicIDs = &RemoveArray(\@TopicIDs,@IgnoreTopics);

      print "<td>$title</td>\n";
      print "<td><nobr>$author_link</nobr></td>\n";
      print "<td>"; &ShortTopicListByID(@TopicIDs); print "</td>\n";
      print "<td>"; &ShortFileListByRevID($DocRevID); print "</td>\n";
    } elsif ($Mode eq "confirm") {
      my @TopicIDs = &GetRevisionTopics($DocRevID);
      
      @TopicIDs = &RemoveArray(\@TopicIDs,@IgnoreTopics);

      print "<td>$title</td>\n";
      print "<td><nobr>$author_link</nobr></td>\n";
      print "<td>"; &ShortTopicListByID(@TopicIDs); print "</td>\n";
      print "<td>\n";
      print $query -> start_multipart_form('POST',$ConfirmTalkHint);
      print $query -> hidden(-name => 'documentid',   -default => $ConfirmDocID);
      print $query -> hidden(-name => 'sessiontalkid',-default => $ConfirmSessionTalkID);
      print $query -> submit (-value => "Confirm");
      print $query -> end_multipart_form;
      
      print "</td>\n";
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
      print "<th>$ShortProject-doc-#</th>\n";
      print "<th>Title</th>\n";
      print "<th>Author</th>\n";
      print "<th>Last Updated</th>\n";
    } elsif ($Mode eq "meeting") {
      print "<th>Title</th>\n";
      print "<th>Author</th>\n";
      print "<th>Topic(s)</th>\n";
      print "<th>Files</th>\n";
    } elsif ($Mode eq "confirm") {
      print "<th>Title</th>\n";
      print "<th>Author</th>\n";
      print "<th>Topic(s)</th>\n";
      print "<th>Confirm?</th>\n";
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
    if ($DocRevisions{$DocRevID}{VERSION} != $Documents{$DocID}{NVersions}) {next;}
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
      if ($DocRevisions{$DocRevID}{VERSION} != $Documents{$DocID}{NVersions}) {next;}
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
