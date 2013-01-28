#
#        Name: FSUtilities.pm
# Description: Routines to deal with files stored in the file system.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

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

#  Functions in this file:
#
#  FullFile
#    Given a document ID, version number, and short file name,
#    returns the full path of the file.
#
#  FileSize
#    Returns the size of a file in human readable format
#
#  GetDirectory
#    Given a document ID and a version number, returns the name of the
#    directory where the document files are stored.
#
#  MakeDirectory
#    Given a document ID and a version number, makes the directory
#    where the document files are stored and any parent directories
#    that haven't been created. Safe to call on existing directories.
#
#  GetURLDir
#    The counterpart to GetDirectory, this function returns the base URL
#    where document files are stored
#
#  ProtectDirectory
#    Given a document ID, version number and the ID numbers of authorized
#    groups, this function will protect a directory from unauthorized
#    web access. (Writes and appropriate .htaccess file.) If no users IDs
#    are specified, it removes .htaccess (for public documents).
#
#  WindowsBaseFile
#    Windows browsers will upload files with C: and back-slashes. This routine
#    removes these and gives just the actual file name.
#
#  UnixBaseFile
#    Like WindowsBaseFile, but removes Unix-style directory names. It's not
#    clear this ever needs to be done.
#
#  ProcessUpload
#    Retrieves a file uploaded by the user's browser and places the resulting
#    file in the correct place in the file system
#
#  ExtractArchive
#    Detects the type of archive and extracts it into the correct
#    location on the file system. Does NOT protect against archives
#    with files that have /../ in the directory name, so files can,
#    in theory, leak into other documents and/or revisions.

sub FullFile {
  my ($DocumentID,$Version,$ShortFile) = @_;

  my $FullFile = &GetDirectory($DocumentID,$Version).$ShortFile;

  return $FullFile;
}

sub FileSize {
  my ($File) = @_;

  my $RawSize = (-s $File);
  my $Size;

  if (-e $File) {
    if ($RawSize > 1024*1024*1024) {
      $Size = sprintf "%8.1f GB",$RawSize/(1024*1024*1024);
    } elsif ($RawSize > 1024*1024) {
      $Size = sprintf "%8.1f MB",$RawSize/(1024*1024);
    } elsif ($RawSize > 1024) {
      $Size = sprintf "%8.1f kB",$RawSize/(1024);
    } else {
      $Size = "$RawSize bytes";
    }
  } else {
    $Size = "file does not exist";
  }

  return $Size;
}

sub GetDirectory { # Returns a directory name
  my ($documentID,$version) = @_;

  # Any change in formats must be made in GetURLDir too

  my $hun_dir = sprintf "%4.4d/",int($documentID/100);
  my $sub_dir = sprintf "%6.6d/",$documentID;
  my $ver_dir = sprintf "%3.3d/",$version;
  my $new_dir = $file_root.$hun_dir.$sub_dir.$ver_dir;

  return $new_dir;
}

sub MakeDirectory { # Makes a directory, safe for existing directories
  my ($documentID,$version) = @_;

  my $hun_dir = sprintf "%4.4d/",int($documentID/100);
  my $sub_dir = sprintf "%6.6d/",$documentID;
  my $ver_dir = sprintf "%3.3d/",$version;
  my $new_dir = $file_root.$hun_dir.$sub_dir.$ver_dir;

  mkdir  $file_root.$hun_dir,oct 777; #FIXME something more reasonable
  mkdir  $file_root.$hun_dir.$sub_dir,oct 777;
  mkdir  $file_root.$hun_dir.$sub_dir.$ver_dir,oct 777;

  return $new_dir; # Returns directory name
}

sub GetURLDir { # Returns a directory name
  my ($documentID,$version) = @_;

  # Any change in formats must be made in MakeDirectory too

  my $hun_dir = sprintf "%4.4d/",int($documentID/100);
  my $sub_dir = sprintf "%6.6d/",$documentID;
  my $ver_dir = sprintf "%3.3d/",$version;
  my $new_dir = $web_root.$hun_dir.$sub_dir.$ver_dir;

  return $new_dir;
}

sub ProtectDirectory { # Write (or delete) correct .htaccess file in directory
  my ($documentID,$version,@GroupIDs) = @_;

  my @users = ();
  my %all_users = ();
  my @all_users = ();
  foreach $GroupID (@GroupIDs) {
    unless ($GroupID) {next;} # Skip Public if present
    push @users,$SecurityGroups{$GroupID}{NAME};
    $all_users{$GroupID} = 1; # Add user
    foreach $HierarchyID (keys %GroupsHierarchy) {
      if ($GroupsHierarchy{$HierarchyID}{Child} == $GroupID) {
        $all_users{$GroupsHierarchy{$HierarchyID}{Parent}} = 1;
      }
    }
  }

  foreach $GroupID (keys %all_users) {
    push @all_users,$SecurityGroups{$GroupID}{NAME}
  }

  my $AuthName = join ' or ',@users;
  if ($Preferences{Security}{AuthName}) {
     $AuthName = $Preferences{Security}{AuthName};
  }

  my $directory = &GetDirectory($documentID,$version);
  if (@users) {
    open HTACCESS,">$directory$htaccess";
     print HTACCESS "AuthType Basic\n";
     print HTACCESS "AuthName \"$AuthName\"\n";
     print HTACCESS "AuthUserFile $AuthUserFile\n";
     print HTACCESS "<Limit GET>\n";
     print HTACCESS "require user";
     foreach $user (@all_users) {
       if ($CaseInsensitiveUsers) {
	 $user =~ tr/[A-Z]/[a-z]/; #Make lower case
       }
       print HTACCESS " $user";
     }
     print HTACCESS "\n";
     print HTACCESS "</Limit>\n";
    close HTACCESS;
  } else {
    unlink "$directory$htaccess"; # No users or public, remove .htaccess
  }
}

sub WindowsBaseFile {    # Strips off Windows directories
  my ($long_file) = @_;
  @parts = split /\\/,$long_file;
  my $short_file = pop @parts;
  return $short_file;
}

sub UnixBaseFile {       # Strips off Unix directories
  my ($long_file) = @_;
  @parts = split /\//,$long_file;
  my $short_file = pop @parts;
  return $short_file;
}

sub ProcessUpload ($$) {
  my ($new_dir,$long_file) = @_;
  $short_file = $long_file;
  if (grep /\\/,$long_file) {
    $short_file = &WindowsBaseFile($long_file);
  }
  if (grep /\//,$long_file) {
    $short_file = &UnixBaseFile($long_file);
  }

  open (OUTFILE,">$new_dir/$short_file");
  while ($bytes_read = read($long_file,$buffer,1024)) {
    print OUTFILE $buffer
  }
  close OUTFILE;

  unless (-s "$new_dir/$short_file") {
    push @WarnStack,"The file $short_file ($long_file) did not exist or was blank.";
  }

  return $short_file;
}

sub CopyFile ($$$$) {
  my ($NewDir,$ShortFile,$OldDocID,$OldVersion) = @_;
  my $OldDir = &GetDirectory($OldDocID,$OldVersion);
  my $OldFile = $OldDir."/".$ShortFile;
  push @DebugStack,"Copying $OldFile,$NewDir";
  system ("cp",$OldFile,$NewDir);
  return $ShortFile;
}

sub ExtractArchive {
  my ($Directory,$File) = @_;

  use Cwd;
  $current_dir = cwd();
  chdir $Directory or die "<p>Fatal error in chdir<p>\n";

  my $Command = "";
  chomp $File;
  if      (grep /\.tar$/,$File) {
    $Command = $Tar." xf ".$File;
  } elsif ((grep /\.tgz$/,$File) || (grep /\.tar\.gz$/,$File)) {
    if ($GTar) {
      $Command = $GTar." xfz ".$File;
    } elsif ($Tar && $GZip) {
      $Command = $GUnzip." -c ".$File." | ".$Tar." xf -";
    }
  } elsif (grep /\.zip$/,$File) {
    $Command = $Unzip." ".$File;
  }

  if ($Command) {
    print "Unpacking the archive with the command <tt>$Command</tt> <br>\n";
    system ($Command);
  } else {
    print "Could not unpack the archive; contact an
    <a href=\"mailto:$DBWebMasterEmail\">administrator</a>. <br>\n";
  }
  chdir $current_dir;
}

sub DownloadURLs (%) {
  use Cwd;
  require "WebUtilities.pm";

  my %Params = @_;

  my $TmpDir = $Params{-tmpdir} || "/tmp";
  my %Files    = %{$Params{-files}}; # Documented in FileUtilities.pm

  my $Status;
  $CurrentDir = cwd();
  chdir $TmpDir or die "<p>Fatal error in chdir<p>\n";

  my @Filenames = ();

  foreach my $FileKey (keys %Files) {
    if ($Files{$FileKey}{URL}) {
      my $URL = $Files{$FileKey}{URL};
      unless (&ValidFileURL($URL)) {
        push @ErrorStack,"The URL <tt>$URL</tt> is not well formed. Don't forget ".
                         "http:// on the front and a file name after the last /.";
      }
      my @Options = ();
      if ($Files{$FileKey}{User} && $Files{$FileKey}{Pass}) {
        push @DebugStack,"Using authentication";
        @Options = ("--http-user=".$Files{$FileKey}{User},
	            "--http-password=".$Files{$FileKey}{Pass});
      }

      # Allow for a new filename as supplied by the user

      if ($Files{$FileKey}{NewFilename}) {
        my @Parts = split /\//,$Files{$FileKey}{NewFilename};
        my $SecureFilename = pop @Parts;
        $Files{$FileKey}{NewFilename} = $SecureFilename;
        push @Options,"--output-document=".$Files{$FileKey}{NewFilename};
      }
      push @DebugStack,"Command is: ",join ' ',$Wget,"--quiet",@Options,$Files{$FileKey}{URL};
      my @Wget = split /\s+/,$Wget;
      $Status = system (@Wget,"--quiet",@Options,$Files{$FileKey}{URL});

      my @URLParts = split /\//,$Files{$FileKey}{URL};
      my $Filename;
      if ($Files{$FileKey}{NewFilename}) {
        $Filename = $Files{$FileKey}{NewFilename};
      } else {
        $Filename = CGI::unescape(pop @URLParts); # As downloaded, we hope
      }
      push @DebugStack, "Download ($Files{$FileKey}{URL}) status: $Status";
      if (-e "$TmpDir/$Filename") {
        push @Filenames,$Filename;
	delete $Files{$FileKey}{URL};
	$Files{$FileKey}{Filename} =  "$TmpDir/$Filename";
      } else {
        push @DebugStack,"Check for existence of $TmpDir/$Filename failed. Check unescape function.";
        push @WarnStack,"The URL $Files{$FileKey}{URL} did not exist, was not accessible or was not downloaded successfully.";
      }
    }
  }

  unless (@Filenames) {
    push @DebugStack,"No files were downloaded.";
    push @ErrorStack,"No files were downloaded.";
  }

  chdir $CurrentDir;
  return %Files;
}

sub MakeTmpSubDir {
  my $TmpSubDir = $TmpDir."/".(time ^ $$ ^ unpack "%32L*", `ps -eaf`);
  mkdir $TmpSubDir, oct 755 or die "Could not make temporary directory";
  return $TmpSubDir;
}

1;
