#
#        Name: FSUtilities.pm
# Description: Routines to deal with files stored in the file system.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#
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
#  ProcessURL
#    Using wget, fetches a URL and places the resulting file in the correct 
#    place in the file system
#    
#  ProcessUpload
#    Retrieves a file uploaded by the user's browser and places the resulting 
#    file in the correct place in the file system   
#    
#  ProcessArchive  
#    Retrieves an archive and places it in the correct place in the file 
#    system. Calls ExtractArchive to do the extraction.   
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
      if ($GroupsHierarchy{$HierarchyID}{CHILD} == $GroupID) {
        $all_users{$GroupsHierarchy{$HierarchyID}{PARENT}} = 1;
      }
    }
  }  

  foreach $GroupID (keys %all_users) {
    push @all_users,$SecurityGroups{$GroupID}{NAME}
  }

  my $AuthName = join ' or ',@users;

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

sub ProcessURL($$) {
  my ($new_dir,$url) = @_;
  
  my @url_parts = split /\//,$url;
  my $short_file = pop @url_parts;

  my $command   = $Wget.$Authentication.$url;
  my @url_lines = `$command`;

  open (OUTFILE,">$new_dir/$short_file");
  print OUTFILE @url_lines;
  close OUTFILE;

  unless (-s "$new_dir/$short_file") {
    push @WarnStack,"The file $short_file did not exist or was blank.";
  }  
  
  return $short_file;
}

sub ProcessUpload($$) {
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
    push @WarnStack,"The file $short_file did not exist or was blank.";
  }  
  
  return $short_file;
}

sub ProcessArchive($$) {
  my ($new_dir,$short_file) = @_;

  if  (-s "$new_dir/$short_file") {
    push @short_files,$short_file;
    push @Descriptions,"Document Archive";
    push @Roots,0;
    $status = &ExtractArchive($new_dir,$short_file); # FIXME No status yet
    $main_file = $params{mainfile};
    if (-s "$new_dir/$main_file") {
      push @short_files,$main_file;
      push @Descriptions,$params{filedesc};
      push @Roots,"on";
    } else {
      push @WarnStack,"The main file $main_file did not exist or was blank.";
    }
  } else {
    push @WarnStack,"The archive file $short_file did not exist or was blank.";
  }
  
  return $status;
}
  
sub ExtractArchive {
  my ($Directory,$File) = @_;

  use Cwd;
  $current_dir = cwd();
  chdir $Directory or die "<p>Fatal error in chdir<p>\n";
  
  my $Extract;
  chomp $File;
  if      (grep /\.tar$/,$File) {
    $Extract = $Tar." xf ";
  } elsif ((grep /\.tgz$/,$File) || (grep /\.tar\.gz$/,$File)) {
    $Extract = $Tar." xfz ";
  } elsif (grep /\.zip$/,$File) {
    $Extract = $Unzip." ";
  }  
  
  $Command = $Extract.$File;
  print "Unpacking the archive with the command <tt>$Command</tt> <br>\n";
  system ($Command);
  chdir $current_dir;
}  

1;
