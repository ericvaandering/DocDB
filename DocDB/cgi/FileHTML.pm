sub FileListByRevID {
  my ($DocRevID) = @_;
#  &FetchDocRevisionByID($DocRevID);
  my $Files_ref  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  if (@{$Files_ref}) {
    @RootFiles  = ();
    @OtherFiles = ();
    foreach $File (@{$Files_ref}) {
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
  } else {
    print "<b>Files in Document:</b> none<br>\n";
  }
}

sub ShortFileListByRevID {
  my ($DocRevID) = @_;
#  &FetchDocRevisionByID($DocRevID);
  my $Files_ref  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  @RootFiles  = ();
  foreach $File (@{$Files_ref}) {
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

  my ($documentID,$version,$shortfile,$description) = @_;
  my $shortname = $shortfile;
  $shortfile = CGI::escape($shortfile);
  my $base_url = &GetURLDir($documentID,$version);
  my $file_size = &FileSize(&FullFile($documentID,$version,$shortname));
  if ($description) {
    return "<a href=\"$base_url$shortfile\">$description</a> ($shortname, $file_size)";
  } else {
    return "<a href=\"$base_url$shortfile\">$shortfile</a> ($file_size)";
  }
}  

sub ShortFileLink {
  require "FSUtilities.pm";

  my ($documentID,$version,$shortfile,$description) = @_;
  $shortname = $shortfile;
  $shortfile = CGI::escape($shortfile);
  $base_url = &GetURLDir($documentID,$version);
  if ($description) {
    return "<a href=\"$base_url$shortfile\">$description</a>";
  } else {
    return "<a href=\"$base_url$shortfile\">$shortname</a>";
  }
}  

1;
