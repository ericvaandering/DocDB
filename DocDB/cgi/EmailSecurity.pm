sub ValidateEmailUser ($$) {
  my ($UserName,$Password) = @_;

  my $UserFetch =  $dbh->prepare("select EmailUserID,Password from EmailUser where Username=?");
     $UserFetch -> execute($UserName);
  my ($EmailUserID,$EncryptedPassword) = $UserFetch -> fetchrow_array;

  unless ($EmailUserID) {
    return 0;
  }  

  my $TryPassword = crypt($Password,$EncryptedPassword);

  if ($TryPassword eq $EncryptedPassword) {
    return $EmailUserID;
  } else {
    return 0;
  }     
}

sub ValidateEmailUserDigest ($$) {
  my ($UserName,$TryDigest) = @_;

  my $UserFetch =  $dbh->prepare("select EmailUserID,Password from EmailUser where Username=?");
     $UserFetch -> execute($UserName);
  my ($EmailUserID,$EncryptedPassword) = $UserFetch -> fetchrow_array;

  unless ($EmailUserID) {
    return 0;
  }  
  
  my $RealDigest = &EmailUserDigest($EmailUserID);
  if ($RealDigest eq $TryDigest) {
    return $EmailUserID;
  } else {
    return 0;
  }     
}

sub UserPrefForm($) {
  my ($EmailUserID) = @_;

  my $Username     = $EmailUser{$EmailUserID}{Username};
  my $Name         = $EmailUser{$EmailUserID}{Name};
  my $EmailAddress = $EmailUser{$EmailUserID}{EmailAddress};
  my $PreferHTML   = $EmailUser{$EmailUserID}{PreferHTML};

  print "<table cellspacing=5>";
  if ($Digest) { 
    print $query -> hidden(-name => 'username', -default => $Username);
    print $query -> hidden(-name => 'digest', -default => $Digest);
    print "<tr><td align=right><b>Username:</b></td>\n<td>$Username";
  } else {
    print "<tr><td align=right><b>Username:</b></td>\n<td>";
    print $query -> textfield(-name => 'username', -default => $Username,      
                            -size => 16, -maxlength => 32);
    print "<tr><td align=right><b>Password:</b></td>\n<td>";
    print $query -> password_field(-name => 'password', 
                            -size => 16, -maxlength => 32);
  }                          
  print "<tr><td align=right><b>Name:</b></td>\n<td>";
  print $query -> textfield(-name => 'name',     -default => $Name,     
                            -size => 24, -maxlength => 128);    
  print "<tr><td align=right><b>E-mail address:</b></td>\n<td>";
  print $query -> textfield(-name => 'email',    -default => $EmailAddress,     
                            -size => 24, -maxlength => 64);
  print "<tr><td align=right><b>New password:</b></td>\n<td>";
  print $query -> password_field(-name => 'newpass',    -default => "",     
                            -size => 24, -maxlength => 64, -override =>1 );
  print "<tr><td align=right><b>Confirm password:</b></td>\n<td>";
  print $query -> password_field(-name => 'confnewpass',    -default => "",     
                            -size => 24, -maxlength => 64, -override =>1 );
  print "<tr><td align=right><b>Prefer HTML e-mail:</b></td>\n<td>";
  if ($PreferHTML) {
    print $query -> checkbox(-name => "html", -checked => 'checked', -value => 1, -label => '');
  } else {
    print $query -> checkbox(-name => "html", -value => 1, -label => '');
  }                             

  print "</table>\n";
}

sub EmailUserDigest ($) {
  use Digest::SHA1 qw(sha1_hex);
  my ($EmailUserID) = @_;
  &FetchEmailUser($EmailUserID);
  
  my $day,$mon,$yr;
  my $Digest;
  (undef,undef,undef,$day,$mon,$yr) = localtime(time);
  if ($EmailUser{$EmailUserID}{Username}) {
    my $data = $EmailUser{$EmailUserID}{Password}.
               $EmailUser{$EmailUserID}{Username}.$day.$mon.$yr;
    $Digest = sha1_hex($data);
  } else {
    $Digest = 0;
  }  

  return $Digest;           
}

sub NewEmailUserForm {
  print "<b>Create a new account:</b><p>\n";
  print $query -> startform('POST',$SelectEmailPrefs);
  print $query -> hidden(-name => 'mode', -default => "newuser", -override => 1);

  print "<dl><dd><table>";
  print "<tr><td align=right><b>Username:</b></td>\n<td>";
  print $query -> textfield(-name => 'username',      -size => 16, -maxlength => 32);
  print "<tr><td align=right><b>Password:</b></td>\n<td>";
  print $query -> password_field(-name => 'password', -size => 16, -maxlength => 32);
  print "<tr><td align=right><b>Confirm password:</b></td>\n<td>";
  print $query -> password_field(-name => 'passconf', -size => 16, -maxlength => 32);
  print "<tr><td colspan=2 align=center>";
  print $query -> submit (-value => "Create new account");
  print "</table></dl>\n";
  print $query -> endform;
}

sub LoginEmailUserForm {
  print "<b>Change preferences on an existing account:</b><p>\n";
  print $query -> startform('POST',$SelectEmailPrefs);
  print $query -> hidden(-name => 'mode', -default => "login", -override => 1);

  print "<dl><dd><table>";
  print "<tr><td align=right><b>Username:</b></td>\n<td>";
  print $query -> textfield(-name => 'username',      -size => 16, -maxlength => 32);
  print "<tr><td align=right><b>Password:</b></td>\n<td>";
  print $query -> password_field(-name => 'password', -size => 16, -maxlength => 32);
  print "<tr><td colspan=2 align=center>";
  print $query -> submit (-value => "Login");
  print "</table></dl>\n";
  print $query -> endform;
}

1;
