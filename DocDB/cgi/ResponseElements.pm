sub AuthorListByID {
  my @AuthorIDs = @_;
  
  if (@AuthorIDs) {
    print "<b>Authors:</b><br>\n";
    print "<ul>\n";
    foreach $AuthorID (@AuthorIDs) {
      &FetchAuthor($AuthorID);
      print "<li> $Authors{$AuthorID}{FULLNAME} </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Authors:</b> none<br>\n";
  }
}

sub RequesterByID { # Uses non HTML-4.01 <nobr> tag. 
  my ($requesterID) = @_;
  &FetchAuthor($requesterID);
  
  print "<nobr><b>Requested by:</b> ";
  print "$Authors{$requesterID}{FULLNAME}</nobr><br>\n";
}

sub SubmitterByID { # Uses non HTML-4.01 <nobr> tag.
  my ($requesterID) = @_;
  &FetchAuthor($requesterID);
  
  print "<nobr><b>Updated by:</b> ";
  print "$Authors{$requesterID}{FULLNAME}</nobr><br>\n";
}

sub TopicListByID {
  my @topicIDs = @_;
  if (@topicIDs) {
    print "<b>Topics:</b><br>\n";
    print "<ul>\n";
    foreach $topicID (@topicIDs) {
      &FetchMinorTopic($topicID);
      print "<li> $MinorTopics{$topicID}{FULL} </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Topics:</b> none<br>\n";
  }
}

sub PrintTitle {
  my ($Title) = @_;
  if ($Title) {
    print "<b>Title:</b> $Title<br>\n";
  } else {
    print "<b>Title:</b> none<br>\n";
  }
}

sub PrintDocNumber { # And type
  my ($DocRevID) = @_;
  print "<nobr><b>Document #: </b>";
  print (&FullDocumentID($DocRevisions{$DocRevID}{DOCID}));
  print "-v$DocRevisions{$DocRevID}{VERSION}</nobr><br>\n";
  print "<nobr><b>Document type: </b>";
  my $doc_type = &FetchDocType($Documents{$DocRevisions{$DocRevID}{DOCID}}{TYPE});
  print "$doc_type</nobr><br>\n";
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

sub FileListByRevID {
  my ($DocRevID) = @_;
  my $Files_ref  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};
  if (@{$Files_ref}) {
    print "<b>Files:</b>\n";
    print "<ul>\n";
    foreach $file (@{$Files_ref}) {
      if ($DocFiles{$file}{DESCRIPTION}) {
        $link = &FileLink($DocumentID,$Version,$DocFiles{$file}{NAME},
                          $DocFiles{$file}{DESCRIPTION});
      } else { 
        $link = &FileLink($DocumentID,$Version,$DocFiles{$file}{NAME});
      }
      print "<li>$link</li>\n";
    }  
    print "</ul>\n";
  } else {
    print "<b>Files:</b> none<br>\n";
  }
}

sub SecurityListByID {
  my @GroupIDs = @_;
  
  if (@GroupIDs) {
    print "<b>Restricted to:</b><br>\n";
    print "<ul>\n";
    foreach $GroupID (@GroupIDs) {
      &FetchSecurityGroup($GroupID);
      print "<li>$SecurityGroups{$GroupID}{NAME}</li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Security:</b> Public document<br>\n";
  }
}

sub PrintRevisionInfo {
  my ($DocRevID) = @_;
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};

  my $Authors_ref = &GetRevisionAuthors($DocRevID);
  my $Topics_ref  = &GetRevisionTopics($DocRevID);
  my $Groups_ref  = &GetRevisionSecurityGroups($DocRevID);
  my $Files_ref  = &FetchDocFiles($DocRevID);  # FIXME: Move to FileListBy

  my @AuthorIDs = @{$Authors_ref};
  my @TopicIDs = @{$Topics_ref};
  my @GroupIDs = @{$Groups_ref};
 
  print "<center><table cellpadding=10>";
  print "<tr valign=top>";
  print "<td colspan=2>"; 
  &PrintTitle($DocRevisions{$DocRevID}{TITLE});
  print "<td colspan=2>"; 
  &RequesterByID($Documents{$DocumentID}{REQUESTER});
  &SubmitterByID($DocRevisions{$DocRevID}{SUBMITTER});
  print "<td colspan=2>"; 
  &PrintDocNumber($DocRevID);
  print "<tr valign=top>";
  print "<td colspan=2>"; 
  &AuthorListByID(@AuthorIDs);
  print "<td colspan=2>"; 
  &TopicListByID(@TopicIDs);
  print "<td colspan=2>"; 
  &SecurityListByID(@GroupIDs);
  print "<tr valign=top>";
  print "<td colspan=3>"; 
  &PrintAbstract($DocRevisions{$DocRevID}{ABSTRACT});
  print "<td rowspan=2 colspan=3>"; 
  &FileListByRevID($DocRevID);
  print "<tr valign=top>";
  print "<td colspan=3>"; 
  &PrintPubInfo($DocRevisions{$DocRevID}{PUBINFO});
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
  &BTeVFooter($DBWebMasterEmail,$DBWebMasterName);
  exit;
}

sub FullDocumentID {
  my ($documentID) = @_;
  return "BTeV-doc-$documentID";
}  

sub FileLink {
  my ($documentID,$version,$shortfile,$description) = @_;
  $base_url = &GetURLDir($documentID,$version);
  if ($description) {
    return "<a href=\"$base_url$shortfile\">$description</a> ($shortfile)";
  } else {
    return "<a href=\"$base_url$shortfile\">$shortfile</a>";
  }
}  

sub DocumentLink {
  my ($DocumentID,$Version) = @_;
  $ret = "<a href=\"$ShowDocument\?docid=$DocumentID\&version=$Version\">".
         (&FullDocumentID)."-v$Version</a>";
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
    $date = &EuroDate($DocRevisions{$RevID}{DATE});
    print "<li>$link \&nbsp \&nbsp ($date)</li>\n";
  }
  print "</ul>\n";
  print "</td></tr></table>\n";
  print "</center>\n";
}

sub DocumentSummary { # One line document summary for listings
  my ($DocumentID) = @_;
  if ($DocumentID) {
    &FetchDocument($DocumentID);
    unless (&CanAccess($DocumentID,$Documents{$DocumentID}{NVER})) {return;}
    
    my $full_docid = &DocumentLink($DocumentID,$Documents{$DocumentID}{NVER});
    my $DocRevID   = &FetchDocRevision($DocumentID,$Documents{$DocumentID}{NVER});
    my $Files_ref  = &FetchDocFiles($DocRevID);
    my $title      = $DocRevisions{$DocRevID}{TITLE};
    my $rev_date   = &EuroDate($DocRevisions{$DocRevID}{DATE});
    print "<tr valign=top>\n";
    print "<td>$full_docid </td>\n";
    print "<td>$title</td>\n";
    print "<td>$Authors{$Documents{$DocumentID}{REQUESTER}}{FULLNAME}</td>\n";
    print "<td>$rev_date</td>\n";
    print "</tr>\n";
  } else { # Print header
    print "<tr valign=bottom>\n";
    print "<th>Document Number</th>\n";
    print "<th>Title</th>\n";
    print "<th>Primary Author</th>\n";
    print "<th>Last Modified</th>\n";
    print "</tr>\n";
  } 
}

1;
