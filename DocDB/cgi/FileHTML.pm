sub FileListByRevID {
  my ($DocRevID) = @_;

  my @FileIDs  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  if (@FileIDs) {
    @RootFiles  = ();
    @OtherFiles = ();
    foreach $File (@FileIDs) {
      if ($DocFiles{$File}{ROOT}) {
        push @RootFiles,$File
      } else {
        push @OtherFiles,$File
      }  
    }
    if (@RootFiles) {
      print "<b>Files in Document:</b>\n";
      print "<ul>\n";
      &FileListByFileID(@RootFiles);
      print "</ul>\n";
    }   
    if (@OtherFiles) {
      print "<b>Other Files:</b>\n";
      print "<ul>\n";
      &FileListByFileID(@OtherFiles);
      print "</ul>\n";
    } 
    unless ($Public) {  
      my $ArchiveLink = &ArchiveLink($DocumentID,$Version);
      print "$ArchiveLink\n";
    }  
  } else {
    print "<b>Files in Document:</b> none<br>\n";
  }
}

sub ShortFileListByRevID {
  my ($DocRevID) = @_;

  my @FileIDs  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  @RootFiles  = ();
  foreach $File (@FileIDs) {
    if ($DocFiles{$File}{ROOT}) {
      push @RootFiles,$File
    }  
  }
  if (@RootFiles) {
    &ShortFileListByFileID(@RootFiles);

  } else {
    print "None<br>\n";
  }
}

sub FileListByFileID {
  my (@Files) = @_;
  foreach my $file (@Files) {
    my $DocRevID      = $DocFiles{$file}{DOCREVID};
    my $VersionNumber = $DocRevisions{$DocRevID}{VERSION};
    my $DocumentID    = $DocRevisions{$DocRevID}{DOCID};
    my $link;
    if ($DocFiles{$file}{DESCRIPTION}) {
      $link = &FileLink($DocumentID,$VersionNumber,$DocFiles{$file}{NAME},
                        $DocFiles{$file}{DESCRIPTION});
    } else { 
      $link = &FileLink($DocumentID,$VersionNumber,$DocFiles{$file}{NAME});
    }
    print "<li>$link</li>\n";
  }  
}

sub ShortFileListByFileID {
  my (@Files) = @_;
  foreach my $file (@Files) {
    my $DocRevID      = $DocFiles{$file}{DOCREVID};
    my $VersionNumber = $DocRevisions{$DocRevID}{VERSION};
    my $DocumentID    = $DocRevisions{$DocRevID}{DOCID};
    my $link;
    if ($DocFiles{$file}{DESCRIPTION}) {
      $link = &ShortFileLink($DocumentID,$VersionNumber,$DocFiles{$file}{NAME},
                        $DocFiles{$file}{DESCRIPTION});
    } else { 
      $link = &ShortFileLink($DocumentID,$VersionNumber,$DocFiles{$file}{NAME});
    }
    print "$link<br>\n";
  }  
}

sub FileLink {
  require "FSUtilities.pm";

  my ($documentID,$version,$shortname,$description) = @_;
  
  my $shortfile = CGI::escape($shortname);
  my $base_url = &GetURLDir($documentID,$version);
  my $file_size = &FileSize(&FullFile($documentID,$version,$shortname));
  $file_size =~ s/^\s+//; # Chop off leading spaces
  if ($description) {
    return "<a href=\"$base_url$shortfile\">$description</a> ($shortname, $file_size)";
  } else {
    return "<a href=\"$base_url$shortfile\">$shortname</a> ($file_size)";
  }
}  

sub ShortFileLink {
  require "FSUtilities.pm";

  my ($documentID,$version,$shortname,$description) = @_;
  my $shortfile = CGI::escape($shortname);
  $base_url = &GetURLDir($documentID,$version);
  if ($description) {
    return "<a href=\"$base_url$shortfile\">$description</a>";
  } else {
    return "<a href=\"$base_url$shortfile\">$shortname</a>";
  }
}  

sub ArchiveLink {
  my ($DocumentID,$Version) = @_;
  
  my @Types = ("tar.gz");
  if ($Zip) {push @Types,"zip";}
     @Types = sort @Types;
  
  my $link  = "<b>Retrieve archive of files as \n";
  @LinkParts = ();
  foreach my $Type (@Types) {
    push @LinkParts,"<a href=\"$RetrieveArchive?docid=$DocumentID\&version=$Version\&type=$Type\">$Type</a>";
  }  
  $link .= join ', ',@LinkParts;
  $link .= ".";
  $link .= "</b>";
  
  return $link;
}
  
1;
