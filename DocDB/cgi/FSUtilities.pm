sub GetDirectory { # Returns a directory name
  my ($documentID,$version) = @_;
  
  # Any change in formats must be made in MakeDirectory too
  
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

  mkdir  $file_root.$hun_dir;
  mkdir  $file_root.$hun_dir.$sub_dir;
  mkdir  $file_root.$hun_dir.$sub_dir.$ver_dir;

  return $new_dir; # Returns directory name
}

sub ProtectDirectory {
  my ($documentID,$version,@users) = @_;

  my $AuthName = join ' or ',@users;

  $directory = &GetDirectory($documentID,$version);
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
    unlink "$directory$htaccess"; # Not tested
  }  
}

1;
