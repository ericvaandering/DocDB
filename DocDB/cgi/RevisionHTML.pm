sub AbstractBox {
  print "<b><a ";
  &HelpLink("abstract");
  print "Abstract:</a></b><br> \n";
  print $query -> textarea (-name => 'abstract', -default => $AbstractDefault,
                            -columns => 60, -rows => 6);
};

sub RevisionNoteBox {
  my (%Params) = @_;
  my $Default  = $Params{-default}  || "";
  my $JSInsert = $Params{-jsinsert} || "";
  print "<b><a ";
  &HelpLink("revisionnote");
  print "Notes and Changes:</a></b>\n";
  print "(insert javascript link)<br> \n";
  print $query -> textarea (-name => 'revisionnote', -default => $Default,
                            -columns => 60, -rows => 6);
};

sub PrintRevisionInfo {

  require "FormElements.pm";
  require "AuthorSQL.pm";
  require "SecuritySQL.pm";
  require "TopicSQL.pm";
 
  my ($DocRevID,$HideButtons) = @_;

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
  print "<center><table cellpadding=10 width=95%>\n";
  print "<tr><td colspan=3 align=center>\n";
  &PrintTitle($DocRevisions{$DocRevID}{Title});
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
  &PrintRevisionNote($DocRevisions{$DocRevID}{Note});

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
  
  require "KeywordHTML.pm";
  
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

sub PrintRevisionNote {
  require "Utilities.pm";

  my ($RevisionNote) = @_;
  if ($RevisionNote) {
    $RevisionNote = &URLify($RevisionNote);
    $RevisionNote =~ s/\n\n/<p>/g;
    $RevisionNote =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt><b>Notes and Changes:</b><br>\n";
    print "<dd>$RevisionNote<br>\n";
    print "</dl>\n";
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



1;
