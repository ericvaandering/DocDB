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

sub RequesterByID {
  my ($requesterID) = @_;
  &FetchAuthor($requesterID);
  
  print "<b>Requested by:</b> ";
  print "$Authors{$requesterID}{FULLNAME}<br>\n";
}

sub SubmitterByID {
  my ($requesterID) = @_;
  &FetchAuthor($requesterID);
  
  print "<b>Updated by:</b> ";
  print "$Authors{$requesterID}{FULLNAME}<br>\n";
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
  print "<b>Document #: </b>";
  print (&FullDocumentID($DocRevisions{$DocRevID}{DOCID}));
  print ", ";
  print "version $DocRevisions{$DocRevID}{VERSION}<br>\n";
  print "<b>Document type: </b>";
  my $doc_type = &FetchDocType($Documents{$DocRevisions{$DocRevID}{DOCID}}{TYPE});
  print "$doc_type<br>\n";
}

sub PrintAbstract {
  my ($abstract) = @_;
  if ($abstract) {
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
      $link = &FileLink($DocumentID,$Version,$DocFiles{$file}{NAME});
      print "<li>$link</li>\n";
    }  
    print "</ul>\n";
  } else {
    print "<b>Files:</b> none<br>\n";
  }
}

sub SecurityListByRevID {
  my ($DocRevID) = @_;
  @SecurityList = @{$DocRevisions{$DocRevID}{SECURITY}};
  if (@SecurityList) {
    print "<b>Restricted to:</b>\n";
    print "<ul>\n";
    foreach $security (@SecurityList) {
      print "<li>$security</li>\n";
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
  my $Files_ref  = &FetchDocFiles($DocRevID);

  @AuthorIDs = @{$Authors_ref};
  @TopicIDs = @{$Topics_ref};
 
  print "<center><table cellpadding=10>";
  print "<tr valign=top>";
  print "<td>"; 
  &PrintTitle($DocRevisions{$DocRevID}{TITLE});
  print "<td align=center>"; 
  &RequesterByID($Documents{$DocumentID}{REQUESTER});
  &SubmitterByID($DocRevisions{$DocRevID}{SUBMITTER});
  print "<td>"; 
  &PrintDocNumber($DocRevID);
  print "<tr valign=top>";
  print "<td>"; 
  &AuthorListByID(@AuthorIDs);
  print "<td>"; 
  &TopicListByID(@TopicIDs);
  print "<td>"; 
  &SecurityListByRevID($DocRevID);
  print "<tr valign=top>";
  print "<td colspan=2>"; 
  &PrintAbstract($DocRevisions{$DocRevID}{ABSTRACT});
  print "<td rowspan=2>"; 
  &FileListByRevID($DocRevID);
  print "<tr valign=top>";
  print "<td colspan=2>"; 
  &PrintPubInfo($DocRevisions{$DocRevID}{PUBINFO});
  print "</table></center>\n"; 
}
 

sub EndPage {
  my @errors = @_;
  print "<b>There was an error processing your request:</b><br>\n";
  foreach $message (@errors) {
    print "<dt><b>$message </b>\n";
  }  
  print $query->end_html;
  exit;
}

sub FullDocumentID {
  my ($documentID) = @_;
  return "BTeV-doc-$documentID";
}  

sub FileLink {
  my ($documentID,$version,$shortfile) = @_;
  $base_url = &GetURLDir($documentID,$version);
  return "<a href=\"$base_url$shortfile\">$shortfile</a>";
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
#  my @Versions = &VersionNumbersByDocID($DocumentID);
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

1;
