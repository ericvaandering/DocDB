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
  foreach $GroupID (@GroupIDs) {
    unless ($GroupID) {next;} # Skip Public if present
    push @users,$SecurityGroups{$GroupID}{NAME};
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
     foreach $user (@users) { 
       $user =~ tr/[A-Z]/[a-z]/; #Make lower case
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
  
sub ExtractArchive {
  my ($Directory,$File) = @_;
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
}  

1;
