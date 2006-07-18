#
# Description: Subroutines to provide links for files, groups of 
#              files and archives.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA


sub FileListByRevID {
  require "MiscSQL.pm";
  my ($DocRevID) = @_;

  my @FileIDs  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  print "<div id=\"Files\">\n";
  print "<dl>\n";
  print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Files in Document:</span></dt>\n";

  if (@FileIDs) {
    @RootFiles  = ();
    @OtherFiles = ();
    foreach my $FileID (@FileIDs) {
      if ($DocFiles{$FileID}{ROOT}) {
        push @RootFiles,$FileID;
      } else {
        push @OtherFiles,$FileID;
      }  
    }
    if (@RootFiles) {
      print "<dd class=\"FileList\">\n";
      &FileListByFileID(@RootFiles);
      print "</dd>\n";
    }   
    if (@OtherFiles) {
      print "<dd class=\"FileList\"><em>Other Files:</em>\n";
      &FileListByFileID(@OtherFiles);
      print "</dd>\n";
    } 
    unless ($Public) {  
      my $ArchiveLink = &ArchiveLink($DocumentID,$Version);
      print "<dd class=\"FileList\"><em>$ArchiveLink</em></dd>\n";
    }  
  } else {
    print "<dd>None</dd>\n";
  }
  print "</dl>\n";
  print "</div>\n";
}

sub ShortFileListByRevID {
  require "MiscSQL.pm";
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
  require "Sorts.pm";
  
  my (@Files) = @_;
  unless (@Files) {
    return;
  }  
  
  @Files = sort FilesByDescription @Files;
  
  print "<ul>\n";
  foreach my $FileID (@Files) {
    my $DocRevID   = $DocFiles{$FileID}{DOCREVID};
    my $Version    = $DocRevisions{$DocRevID}{VERSION};
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    my $Link = FileLink( {-docid => $DocumentID, -version => $Version,
                          -shortname   => $DocFiles{$FileID}{NAME},
                          -description => $DocFiles{$FileID}{DESCRIPTION}} );
    print "<li>$Link</li>\n";
  }  
  print "</ul>\n";
}

sub ShortFileListByFileID { # FIXME: Make special case of FileListByFileID
  require "Sorts.pm";
  
  my (@Files) = @_;
  
  @Files = sort FilesByDescription @Files;
  
  foreach my $FileID (@Files) {
    my $DocRevID   = $DocFiles{$FileID}{DOCREVID};
    my $Version    = $DocRevisions{$DocRevID}{VERSION};
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    my $Link = FileLink( {-maxlength => 20, -format => "short", -docid => $DocumentID, -version => $Version,
                          -shortname   => $DocFiles{$FileID}{NAME},
                          -description => $DocFiles{$FileID}{DESCRIPTION}} );
    print "$Link<br/>\n";
  }  
}

sub FileLink ($) {
  my ($ArgRef) = @_;
  
  my $DocumentID  = exists $ArgRef->{-docid}       ? $ArgRef->{-docid}       : 0;
  my $Version     = exists $ArgRef->{-version}     ? $ArgRef->{-version}     : 0;
  my $ShortName   = exists $ArgRef->{-shortname}   ? $ArgRef->{-shortname}   : "";
  my $Description = exists $ArgRef->{-description} ? $ArgRef->{-description} : "";
  my $MaxLength   = exists $ArgRef->{-maxlength}   ? $ArgRef->{-maxlength}   : 60;
  my $MaxExt      = exists $ArgRef->{-maxext}      ? $ArgRef->{-maxext}      : 4;
  my $Format      = exists $ArgRef->{-format}      ? $ArgRef->{-format}      : "long";

  require "FSUtilities.pm";
  require "FileUtilities.pm";

  my $ShortFile = CGI::escape($ShortName);
  my $BaseURL   = GetURLDir($DocumentID,$Version);
  my $FileSize  = FileSize(FullFile($DocumentID,$Version,$ShortName));

  $FileSize =~ s/^\s+//; # Chop off leading spaces
  
  my $PrintedName = $ShortName; 
  if ($MaxLength) { 
    $PrintedName = AbbreviateFileName(-filename  => $ShortName,
                                      -maxlength => $MaxLength, -maxext => $MaxExt);
  }  

  my $URL = $BaseURL.$ShortFile;
  if ($UserValidation eq "certificate" || $Preferences{Options}{AlwaysRetrieveFile}) {                                          
    $URL = $RetrieveFile."?docid=".$DocumentID."&amp;version=".$Version."&amp;filename=".$ShortFile;
  }
  
  my $Link = "";
  
  if ($Format eq "short") {
    if ($Description) {
      return "<a href=\"$URL\" title=\"$ShortName\">$Description</a>";
    } else {
      return "<a href=\"$URL\" title=\"$ShortName\">$PrintedName</a>";
    }
  } else {
    if ($Description) {
      return "<a href=\"$URL\" title=\"$ShortName\">$Description</a> ($PrintedName, $FileSize)";
    } else {
      return "<a href=\"$URL\" title=\"$ShortName\">$PrintedName</a> ($FileSize)";
    }
  }
}

sub ArchiveLink {
  my ($DocumentID,$Version) = @_;
  
  my @Types = ("tar.gz");
  if ($Zip) {push @Types,"zip";}
  
  @Types = sort @Types;
  
  my $link  = "Get all files as \n";
  @LinkParts = ();
  foreach my $Type (@Types) {
    push @LinkParts,"<a href=\"$RetrieveArchive?docid=$DocumentID\&amp;version=$Version\&amp;type=$Type\">$Type</a>";
  }  
  $link .= join ', ',@LinkParts;
  $link .= ".";
  
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
  
  require "Sorts.pm";
  
  if ($DocRevID) {
    require "MiscSQL.pm";
    @FileIDs = &FetchDocFiles($DocRevID);
  }
  
  my @RootFiles  = ();
  my @OtherFiles = ();

  foreach my $FileID (@FileIDs) {
    if ($DocFiles{$FileID}{ROOT}) {
      push @RootFiles,$FileID;
    } else {
      push @OtherFiles,$FileID;
    }  
  }
  
  @RootFiles  = sort FilesByDescription @RootFiles;
  @OtherFiles = sort FilesByDescription @OtherFiles;
  @FileIDs    = (@RootFiles,@OtherFiles);
  
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

  print "<table class=\"LowPaddedTable LeftHeader\">\n";
  print "<tr><td colspan=\"2\">";
  print $query -> hidden(-name => 'maxfiles', -default => $MaxFiles);
 
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
    my $NewName     = "newname$i";
   
    my $FileHelp        = FormElementTitle(-helplink => $FileHelpLink, -helptext => $FileHelpText);
    my $DescriptionHelp = FormElementTitle(-helplink => $DescHelpLink, -helptext => $DescHelpText);
    my $NewNameHelp     = FormElementTitle(-helplink => "newfilename", -helptext => "New Filename");
    my $MainHelp        = FormElementTitle(-helplink => "main", -helptext => "Main?", -nocolon => true, -nobold => true);
    my $DefaultDesc = $DocFiles{$FileID}{DESCRIPTION};
    
    if ($DescOnly) {
      print "<tr>\n";
      print "<th>Filename:</th>";
      print "<td>\n";
      print $DocFiles{$FileID}{NAME};
      print $query -> hidden(-name => $FileIDName, -value => $FileID);
      print "</td>\n";
      print "</tr>\n";
    } else {
      print "<tr><th>\n";
      print $FileHelp;
      print "</th>\n";

      print "<td>\n";
      if ($Type eq "file") {
        print $query -> filefield(-name      => $ElementName, -size => $FileSize,
                                  -maxlength => $FileMaxSize);
      } elsif ($Type eq "http") {
        print $query -> textfield(-name      => $URLName,     -size => $FileSize, 
                                  -maxlength => $FileMaxSize);
      }
      print "</td>\n";
      print "</tr>\n";
      
      if ($Type eq "http") {
        print "<tr><th>\n";
        print $NewNameHelp;
        print "</th>\n";

        print "<td>\n";
        print $query -> textfield(-name      => $NewName, -size => $FileSize, 
                                  -maxlength => $FileMaxSize);
        print "</td>\n";
        print "</tr>\n";
      }
    }  
    print "<tr><th>\n";
    print $DescriptionHelp;
    print "</th>\n";
    print "<td>\n";
    print $query -> textfield (-name      => $DescName, -size    => 60, 
                               -maxlength => 128,       -default => $DefaultDesc);

    if ($DocFiles{$FileID}{ROOT} || !$FileID) {
      print $query -> checkbox(-name => $MainName, -checked => 'checked', -label => '');
    } else {
      print $query -> checkbox(-name => $MainName, -label => '');
    }
    
    print $MainHelp;
    print "</td></tr>\n";
    if ($FileID && $AllowCopy && !$DescOnly) {
      print "<tr><td>&nbsp;</td><td colspan=\"2\">\n";
      print "Copy <tt>$DocFiles{$FileID}{NAME}</tt> from previous version:";
      print $query -> hidden(-name => $FileIDName, -value => $FileID);
      print $query -> checkbox(-name => $CopyName, -label => '');
      print "</td></tr>\n";
    }  
    print "<tr><td colspan=\"3\"></td></tr>\n";
  }
  if ($Type eq "http") {
    print "<tr><th>User:</th>\n";
    print "<td>\n";
    print $query -> textfield (-name => 'http_user', -size => 20, -maxlength => 40);
    print "<b>&nbsp;&nbsp;&nbsp;&nbsp;Password:</b>\n";
    print $query -> password_field (-name => 'http_pass', -size => 20, -maxlength => 40);
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

1;
