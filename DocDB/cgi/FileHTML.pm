#
# Description: Subroutines to provide links for files, groups of 
#              files and archives.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub FileListByRevID {
  my ($DocRevID) = @_;

  my @FileIDs  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  print "<div id=\"Files\">\n";
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
  print "</div>\n";
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
    return "<a href=\"$base_url$shortfile\" title=\"$shortname\">$description</a> ($shortname, $file_size)";
  } else {
    return "<a href=\"$base_url$shortfile\" title=\"$shortname\">$shortname</a> ($file_size)";
  }
}  

sub ShortFileLink {
  require "FSUtilities.pm";

  my ($documentID,$version,$shortname,$description) = @_;
  my $shortfile = CGI::escape($shortname);
  $base_url = &GetURLDir($documentID,$version);
  if ($description) {
    return "<a href=\"$base_url$shortfile\" title=\"$shortname\">$description</a>";
  } else {
    return "<a href=\"$base_url$shortfile\" title=\"$shortname\">$shortname</a>";
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

sub FileUploadBox (%) {
  my (%Params) = @_; 

  my $Type        = $Params{-type}        || "file";
  my $DescOnly    = $Params{-desconly}    || 0;
  my $AllowCopy   = $Params{-allowcopy}   || 0;
  my $MaxFiles    = $Params{-maxfiles}    || 0;
  my $AddFiles    = $Params{-addfiles}    || 0;
  my $DocRevID    = $Params{-docrevid}    || 0;
  my $Required    = $Params{-required}    || 0;
  my $FileSize    = $Params{-filesize}    || 60;
  my $FileMaxSize = $Params{-filemaxsize} || 250;
  
  my @FileIDs = @{$Params{-fileids}};
  
  if ($DocRevID) {
    require "MiscSQL.pm";
    @FileIDs = &FetchDocFiles($DocRevID);
  }
  
  @FileIDs = sort @FileIDs;
  
  unless ($MaxFiles) {
    if (@FileIDs) {
      $MaxFiles = @FileIDs + $AddFiles;
    } elsif ($NumberUploads) {
      $MaxFiles = $NumberUploads;	  
    } elsif ($UserPreferences{NumFiles}) {
      $MaxFiles = $UserPreferences{NumFiles};
    } else {
      $MaxFiles = 1;   
    }   
  }   
  
  &DebugPage("Test point");
  
  print $query -> hidden(-name => 'maxfiles', -default => $MaxFiles);
  
  print "<table cellpadding=3>\n";
  print "<tr><td colspan=2><b><a ";
  
  my ($HelpLink,$HelpText,$FileHelpLink,$FileHelpText,$DescHelpLink,$DescHelpText);
  if ($Type eq "file") {
    $HelpLink = "fileupload";
    $HelpText = "Local file upload";
    $FileHelpLink = "localfile";
    $FileHelpText = "File";
  } elsif ($Type eq "http") {
    $HelpLink = "httpupload";
    $HelpText = "Upload by HTTP";
    $FileHelpLink = "remoteurl";
    $FileHelpText = "URL";
  }
  
  if ($DescOnly) {
    $HelpLink = "filechar";
    $HelpText = "Update File Characteristics";
  }
    
  $DescHelpLink = "description";
  $DescHelpText = "Description";
    
  my $BoxTitle = &FormElementTitle(-helplink => $HelpLink, -helptext => $HelpText,
                                   -required => $Required);
  print $BoxTitle;
  
  print $query -> hidden(-name => "maxfiles", -default => $MaxFiles);
                            
  for (my $i = 1; $i <= $MaxFiles; ++$i) {
    my $FileID = shift @FileIDs;
    my $ElementName = "upload$i";
    my $DescName    = "filedesc$i";
    my $MainName    = "main$i";
    my $FileIDName  = "fileid$i";
    my $CopyName    = "copyfile$i";
    my $URLName     = "url$i";
   
    my $FileHelp        = &FormElementTitle(-helplink => $FileHelpLink, -helptext => $FileHelpText);
    my $DescriptionHelp = &FormElementTitle(-helplink => $DescHelpLink, -helptext => $DescHelpText);
    my $MainHelp        = &FormElementTitle(-helplink => "main", -helptext => "Main?", -nocolon => true, -nobold => true);
    my $DefaultDesc = $DocFiles{$FileID}{DESCRIPTION};
    
    if ($DescOnly) {
      print "<tr>\n";
      print "<td align=right>Filename:</td>";
      print "<td>\n";
      print $DocFiles{$FileID}{NAME};
      print $query -> hidden(-name => $FileIDName, -value => $FileID);
      print "</td>\n";
      print "</tr>\n";
    } else {
      print "<tr><td align=right>\n";
      print $FileHelp;
      print "</td>\n";

      print "<td>\n";
      if ($Type eq "file") {
        print $query -> filefield(-name      => $ElementName, -size => $FileSize,
                                  -maxlength => $FileMaxSize);
      } elsif ($Type eq "http") {
        print $query -> textfield(-name      => $URLName, -size => $FileSize, 
                                  -maxlength => $FileMaxSize);
      }
      print "</td>\n";
      print "</tr>\n";
    }  
    print "<tr><td align=right>\n";
    print $DescriptionHelp;
    print "</td>\n";
    print "<td>\n";
    print $query -> textfield (-name      => $DescName, -size    => 60, 
                               -maxlength => 128,       -default => $DefaultDesc);

    if ($DocFiles{$FileID}{ROOT} || !$FileID) {
#    if ($DocFiles{$FileID}{ROOT} || $NewFiles) {
      print $query -> checkbox(-name => $MainName, -checked => 'checked', -label => '');
    } else {
      print $query -> checkbox(-name => $MainName, -label => '');
    }
    
    print $MainHelp;
    print "</td></tr>\n";
    if ($FileID && $AllowCopy && !$DescOnly) {
      print "<tr><td>&nbsp;</td><td colspan=2>\n";
      print "Copy <tt>$DocFiles{$FileID}{NAME}</tt> from previous version:";
      print $query -> hidden(-name => $FileIDName, -value => $FileID);
      print $query -> checkbox(-name => $CopyName, -label => '');
      print "</td></tr>\n";
    }  
    print "<tr><td colspan=3></td></tr>\n";
  }
  if ($Type eq "http") {
    print "<tr><td align=right><b>User:</b></td>\n";
    print "<td>\n";
    print $query -> textfield (-name => 'http_user', -size => 20, -maxlength => 40);
    print "<b>&nbsp;&nbsp;&nbsp;&nbsp;Password:</b>\n";
    print $query -> password_field (-name => 'http_pass', -size => 20, -maxlength => 40);
    print "</td></tr>\n";
  }
  print "</table>\n";
}
   
    
sub SingleUploadBox (%) {
  my (%Params) = @_; 

  my $NoDesc     = $Params{-nodesc}  || 0;     
  my $Required   = $Params{-required}  || 0;
  my $CopyOption = $Params{-allowcopy} || 0;

  print "<table cellpadding=3>\n";
  print "<tr><td colspan=2><b><a ";
  &HelpLink("fileupload");
  print "Local file upload:</a></b>";
  if ($Required) {
    print $RequiredMark;
  } 
  print "<br></td></tr>\n";
  my @FileIDs = sort keys %DocFiles;
  my $NewFiles = 0; # FIXME: Is this the same as "nodesc"
  unless (@FileIDs) {
    $NewFiles = 1;
  }
  for (my $i=1;$i<=$NumberUploads;++$i) {
    my $FileID = shift @FileIDs;
    print "<tr><td align=right>\n";
    print "<a "; &HelpLink("localfile"); print "<b>File:</b></a>\n";
    print "</td>\n";
    print "<td>\n";
    print $query -> filefield(-name => "single_upload", -size => 60,
                              -maxlength=>250);
    print "</td></tr>\n";
    print "<tr><td align=right>\n";
    print "<a "; &HelpLink("description"); print "<b>Description:</b></a>\n";
    print "</td>\n";
    print "<td>\n";
    if ($NoDesc) {
      print $query -> textfield (-name => 'filedesc', -size => 60, 
                                 -maxlength => 128);
    } else {
      print $query -> textfield (-name => 'filedesc', -size => 60, 
                                 -maxlength => 128,
                                 -default => $DocFiles{$FileID}{DESCRIPTION});
    }
    if ($DocFiles{$FileID}{ROOT} || $NewFiles) {
      print $query -> checkbox(-name => "root", -value => $i, -checked => 'checked', -label => '');
    } else {
      print $query -> checkbox(-name => "root", -value => $i, -label => '');
    }
    print "<a "; &HelpLink("main"); print "Main?</a>\n";
    print "</td></tr>\n";
    if ($FileID && $CopyOption) {
      print "<tr><td>&nbsp;</td><td colspan=2>\n";
      print "Copy <tt>$DocFiles{$FileID}{NAME}</tt> from previous version:";
      print $query -> hidden(-name => 'copyfileid', -value => $FileID);
      print $query -> checkbox(-name => "copyfile", -value => $i, -label => '');
      print "</td></tr>\n";
    }  
    print "<tr><td colspan=3></td></tr>\n";
  }
  print "</table>\n";
};

sub SingleHTTPBox (%) {
  my (%Params) = @_; 

  my $NoDesc     = $Params{-nodesc}  || 0;     
  my $Required   = $Params{-required}  || 0;
  my $CopyOption = $Params{-allowcopy} || 0;

  print "<table cellpadding=3>\n";
  print "<tr><td colspan=4><b><a ";
  &HelpLink("httpupload");
  print "Upload by HTTP:</a></b>";
  if ($Required) {
    print $RequiredMark;
  } 
  print "<br></td><tr>\n";
  my @FileIDs = sort keys %DocFiles;
  my $NewFiles = 0; # FIXME: Is this the same as "nodesc"
  unless (@FileIDs) {
    $NewFiles = 1;
  }
  for (my $i=1;$i<=$NumberUploads;++$i) {
    my $FileID = shift @FileIDs;
    print "<tr><td align=right>\n";
    print "<a "; &HelpLink("remoteurl"); print "<b>URL:</b></a>\n";
    print "</td>\n";
    print "<td colspan=3>\n";
    print $query -> textfield (-name => 'single_http', -size => 70, -maxlength => 240);
    print "</td></tr>\n";
    print "<tr><td align=right>\n";
    print "<a "; &HelpLink("description"); print "<b>Description:</b></a>\n";
    print "</td>\n";
    print "<td colspan=3>\n";
    if ($NoDesc) {
      print $query -> textfield (-name => 'filedesc', -size => 60, 
                                 -maxlength => 128);
    } else {
      print $query -> textfield (-name => 'filedesc', -size => 60, 
                                 -maxlength => 128,
                                 -default => $DocFiles{$FileID}{DESCRIPTION});
    }
    if ($DocFiles{$FileID}{ROOT} || $NewFiles) {
      print $query -> checkbox(-name => "root", -value => $i, -checked => 'checked', -label => '');
    } else {
      print $query -> checkbox(-name => "root", -value => $i, -label => '');
    }
    print "<a "; &HelpLink("main"); print "Main?</a>\n";
    print "</td></tr>\n";
    if ($FileID && $CopyOption) {
      print "<tr><td>&nbsp;</td><td colspan=2>\n";
      print "Copy <tt>$DocFiles{$FileID}{NAME}</tt> from previous version:";
      print $query -> checkbox(-name => "copyfile", -value => $i, -label => '');
      print "</td></tr>\n";
    }  
    print "<tr><td colspan=3></td></tr>\n";
  }
  print "<tr><td align=right><b>User:</b></td>\n";
  print "<td>\n";
  print $query -> textfield (-name => 'http_user', -size => 20, -maxlength => 40);
  print "</td><td align=right>\n";
  print "<b>Password:</b></td>\n";
  print "<td>\n";
  print $query -> password_field (-name => 'http_pass', -size => 20, -maxlength => 40);
  print "</td></tr>\n";
  print "</table>\n";
};

sub FileUpdateBox {
  my ($DocRevID) = @_; 
  my @FileIDs = &FetchDocFiles($DocRevID);

  print "<table cellpadding=3>\n";
  print "<tr>";
   print "<td align=left>\n";
   print "<a "; &HelpLink("filename"); print "<b>File Name</b></a>\n";
   print "</td>\n";
   print "<td align=left>\n";
   print "<a "; &HelpLink("description"); print "<b>Description</b></a>\n";
   print "</td>\n";
   print "<td align=left>\n";
   print "<a "; &HelpLink("main"); print "<b>Main</b></a>\n";
   print "</td>\n";  
  print "</tr>\n";
  foreach my $FileID (@FileIDs) {
    print "<tr><td align=right>\n";
    print "$DocFiles{$FileID}{NAME}\n";
    print "</td>\n";
    print "<td>\n";
    print $query -> hidden (-name => 'fileid', -default => $FileID);
    print $query -> textfield (-name => 'filedesc', -size => 60, -maxlength => 128, 
                               -default => $DocFiles{$FileID}{DESCRIPTION});
    print "</td>\n";
    print "<td>\n";
    if ($DocFiles{$FileID}{ROOT}) {
      print $query -> checkbox(-name => "root", -value => $FileID, -checked => 'checked', -label => '');
    } else {
      print $query -> checkbox(-name => "root", -value => $FileID, -label => '');
    }
    print "</td></tr>\n";
  }
  print "</table>\n";
}

sub ArchiveUploadBox (%)  {
  my (%Params) = @_; 
  
  my $Required   = $Params{-required}   || 0;        # short, long, full

  print "<table cellpadding=3>\n";
  print "<tr><td colspan=2><b><a ";
  &HelpLink("filearchive");
  print "Archive file upload:</a></b>";
  if ($Required) {
    print $RequiredMark;
  } 
  print "<br> \n";
  print "<tr><td align=right>\n";
  print "<b>Archive File:</b>\n";
  print "</td><td>\n";
  print $query -> filefield(-name => "single_upload", -size => 60,
                              -maxlength=>250);

  print "<tr><td align=right>\n";
  print "<b>Main file in archive:</b>\n";
  print "</td><td>\n";
  print $query -> textfield (-name => 'mainfile', -size => 70, -maxlength => 128);

  print "<tr><td align=right>\n";
  print "<b>Description of file:</b>\n";
  print "</td><td>\n";
  print $query -> textfield (-name => 'filedesc', -size => 70, -maxlength => 128);
  print "</td></tr></table>\n";
};

sub ArchiveHTTPBox (%)  {
  my (%Params) = @_; 
  
  my $Required   = $Params{-required}   || 0;        # short, long, full

  print "<table cellpadding=3>\n";
  print "<tr><td colspan=4><b><a ";
  &HelpLink("httparchive");
  print "Upload Archive by HTTP:</a></b>";
  if ($Required) {
    print $RequiredMark;
  } 
  print "<br> \n";

  print "<tr><td align=right><b>Archive URL:</b>\n";
  print "<td colspan=3>\n";
  print $query -> textfield (-name => 'single_http', -size => 70, -maxlength => 240);

  print "<tr><td align=right>\n";
  print "<b>Main file in archive:</b>\n";
  print "<td colspan=3>\n";
  print $query -> textfield (-name => 'mainfile', -size => 70, -maxlength => 128);

  print "<tr><td align=right>\n";
  print "<b>Description of file:</b>\n";
  print "<td colspan=3>\n";
  print $query -> textfield (-name => 'filedesc', -size => 70, -maxlength => 128);

  print "<tr><td align=right><b>User:</b>\n";
  print "<td>\n";
  print $query -> textfield (-name => 'http_user', -size => 20, -maxlength => 40);
  print "<td align=right>\n";
  print "<b>Password:</b>\n";
  print "<td>\n";
  print $query -> password_field (-name => 'http_pass', -size => 20, -maxlength => 40);
  print "</td></tr>\n";
  print "</table>\n";
};

1;
