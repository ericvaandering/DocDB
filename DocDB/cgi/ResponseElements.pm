require "AuthorHTML.pm";
require "TopicHTML.pm";
require "FileHTML.pm";

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
  print "<nobr><b>Document #: </b>";
  print (&FullDocumentID($DocRevisions{$DocRevID}{DOCID}));
  print "-v$DocRevisions{$DocRevID}{VERSION}</nobr><br>\n";
  print "<nobr><b>Document type: </b>";
  my $type_link = &TypeLink($Documents{$DocRevisions{$DocRevID}{DOCID}}{TYPE},"short");
  print "$type_link</nobr><br>\n";
}

sub PrintAbstract {
  my ($abstract) = @_;
  
  if ($abstract) {
    $abstract =~ s/\n\n/<p>/g;
    $abstract =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt><b>Abstract:</b><br>\n";
    print "<dd>$abstract<br>\n";
    print "</dl>\n";
  } else {
    print "<b>Abstract:</b> none<br>\n";
  }
}

sub PrintPubInfo {
  my ($pubinfo) = @_;
  if ($pubinfo) {
    $pubinfo =~ s/\n\n/<p>/g;
    $pubinfo =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt><b>Publication Information:</b><br>\n";
    print "<dd>$pubinfo<br>\n";
    print "</dl>\n";
  } else {
    print "<b>Publication Information:</b> none<br>\n";
  }
}

sub SecurityListByID {
  my @GroupIDs = @_;
  
  if (@GroupIDs) {
    print "<b>Restricted to:</b><br>\n";
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
 
  my ($DocRevID,$HideButtons) = @_;

  &FetchDocRevisionByID($DocRevID);

  my $DocumentID  = $DocRevisions{$DocRevID}{DOCID};
  my $Version     = $DocRevisions{$DocRevID}{VERSION};
  my $Authors_ref = &GetRevisionAuthors($DocRevID);
  my $Topics_ref  = &GetRevisionTopics($DocRevID);
  my $Groups_ref  = &GetRevisionSecurityGroups($DocRevID);

  my @AuthorIDs = @{$Authors_ref};
  my @TopicIDs  = @{$Topics_ref};
  my @GroupIDs  = @{$Groups_ref};
 
  print "<center><table cellpadding=10>";
  print "<tr><td colspan=6 align=center>\n";
  &PrintTitle($DocRevisions{$DocRevID}{TITLE});
  print "</td></tr>\n";
  print "<tr valign=top>";
  print "<td colspan=2 width=\"40%\">"; 
  &RequesterByID($Documents{$DocumentID}{REQUESTER});
  &SubmitterByID($DocRevisions{$DocRevID}{SUBMITTER});

  print "<td colspan=2>"; 
  &PrintDocNumber($DocRevID);

  print "<td colspan=2>"; 
  &ModTimes;

  print "</td></tr>\n";
  print "<tr valign=top>";
  print "<td colspan=2>"; 
  &AuthorListByID(@AuthorIDs);

  print "<td colspan=2>"; 
  &TopicListByID(@TopicIDs);

  print "<td colspan=2>"; 
  &SecurityListByID(@GroupIDs);

  print "</td></tr>\n";
  print "<tr valign=top>";
  print "<td colspan=3>"; 
  &PrintAbstract($DocRevisions{$DocRevID}{ABSTRACT});

  print "<td rowspan=2 colspan=3>"; 
  &FileListByRevID($DocRevID);

  print "</td></tr>\n";
  print "<tr valign=top>";
  print "<td colspan=3>"; 
  &PrintPubInfo($DocRevisions{$DocRevID}{PUBINFO});
  print "</td></tr>\n";
  if (&CanModify($DocumentID) && !$HideButtons) {
    print "<tr valign=top>";
    print "<td colspan=2 align=center>";
    &UpdateButton($DocumentID);
    print "<td colspan=2 align=center>";
    &UpdateDBButton($DocumentID);
    print "<td colspan=2 align=center>";
    &AddFilesButton($DocumentID,$Version);
    print "</td></tr>\n";
  }  

  print "</table></center>\n"; 
}
 
sub WarnPage {
  my @errors = @_;
  print "<b><font color=\"red\">There was a non-fatal error processing your
  request: </font></b><br>\n";
  foreach $message (@errors) {
    print "<dt><b>$message </b><p>\n";
  }  
}

sub EndPage {
  my @errors = @_;
  print "<b><font color=\"red\">There was a fatal error processing your request:
  </font></b><br>\n";
  foreach $message (@errors) {
    print "<dt><b>$message </b>\n";
  }  
  &DocDBNavBar();
  &BTeVFooter($DBWebMasterEmail,$DBWebMasterName);
  exit;
}

sub FullDocumentID {
  my ($documentID) = @_;
  return "BTeV-doc-$documentID";
}  

sub DocumentLink {
  my ($DocumentID,$Version,$Title) = @_;
  my $ret = "<a href=\"$ShowDocument\?docid=$DocumentID\&version=$Version\">";
  if ($Title) {
    $ret .= $Title;
  } else {
    $ret .= &FullDocumentID."-v$Version";
  }
  $ret .=  "</a>";
}         

sub ModTimes {
  my ($DocRevID) = @_;
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  $DocTime = &EuroDate($Documents{$DocumentID}{DATE}); 
  $RevTime = &EuroDate($DocRevisions{$DocRevID}{DATE}); 
  print "<nobr><b>Created: </b>$DocTime</nobr><br>\n";
  print "<nobr><b>Revised: </b>$RevTime</nobr><br>\n";
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

sub OtherVersionLinks {
  my ($DocumentID,$CurrentVersion) = @_;
  my @RevIDs   = &FetchRevisionsByDocument($DocumentID);
  
  unless ($#RevIDs >0) {return;}
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
  
  my ($DocumentID,$Mode) = @_;
  unless ($Mode) {$Mode = "date"};
  
  if ($DocumentID) {
    &FetchDocument($DocumentID);
    unless (&CanAccess($DocumentID,$Documents{$DocumentID}{NVER})) {return;}
    
    my $full_docid  = &DocumentLink($DocumentID,$Documents{$DocumentID}{NVER});
    my $DocRevID    = &FetchDocRevision($DocumentID,$Documents{$DocumentID}{NVER});
    my $title       = &DocumentLink($DocumentID,$Documents{$DocumentID}{NVER},$DocRevisions{$DocRevID}{TITLE});
    my $Files_ref   = &FetchDocFiles($DocRevID);
    my $rev_date    = &EuroDate($DocRevisions{$DocRevID}{DATE});
    my $author_link = &FirstAuthor($DocRevID);
    print "<tr valign=top>\n";
    if ($Mode eq "date") {
      print "<td><nobr>$full_docid</nobr></td>\n";
      print "<td>$title</td>\n";
      print "<td><nobr>$author_link</nobr></td>\n";
      print "<td><nobr>$rev_date</nobr></td>\n";
    } elsif ($Mode eq "meeting") {
      print "<td><nobr>$full_docid</nobr></td>\n";
      print "<td>$title</td>\n";
      print "<td><nobr>$author_link</nobr></td>\n";
      print "<td>"; &ShortFileListByRevID($DocRevID); print "</td>\n";
    }  
    print "</tr>\n";
  } else { # Print header if $DocumentID = 0
    print "<tr valign=bottom>\n";
    if ($Mode eq "date") {
      print "<th>Document Number</th>\n";
      print "<th>Title</th>\n";
      print "<th>Author</th>\n";
      print "<th>Last Modified</th>\n";
    } elsif ($Mode eq "meeting") {
      print "<th>Document Number</th>\n";
      print "<th>Title</th>\n";
      print "<th>Author</th>\n";
      print "<th>Files</th>\n";
    }  
    print "</tr>\n";
  } 
}

sub DocDBNavBar {
  
  my ($ExtraDesc,$ExtraURL) = @_;

  print "<p><div align=\"center\">\n";
  if ($ExtraDesc && $ExtraURL) {
    print "[&nbsp;<a href=\"$ExtraURL\"l>$ExtraDesc</a>&nbsp;]&nbsp;\n";
  } 
  print "[&nbsp;<a href=\"$MainPage\">DocDB&nbsp;Home</a>&nbsp;]&nbsp;\n";
  print "[&nbsp;<a href=\"$DocumentAddForm?mode=add\">New&nbsp;Document</a>&nbsp;]&nbsp;\n";
  print "[&nbsp;<a href=\"$DocumentAddForm\">Reserve</a>&nbsp;]&nbsp;\n";
  print "[&nbsp;<a href=\"$ListAuthors\">List&nbsp;Authors</a>&nbsp;]\n";
  print "[&nbsp;<a href=\"$ListTopics\">List&nbsp;Topics</a>&nbsp;]\n";
  print "[&nbsp;<a href=\"$HelpFile\">Help</a>&nbsp;]\n";
  print "</div>\n";
}

sub TypesTable {
#  require "Sorts.pm";

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
  my $link;
  $link = "<a href=$ListByType?typeid=$TypeID>";
  if ($mode eq "short") {
    $link .= $DocumentTypes{$TypeID}{SHORT};
  } else {
    $link .= $DocumentTypes{$TypeID}{LONG};
  }
  $link .= "</a>";
  
  return $link;
}

1;
