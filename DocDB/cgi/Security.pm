sub CanAccess { # Can the user access (with current security) this version
  my ($documentID,$version) = @_;
  my $DocRevID = &FetchDocRevision($documentID,$version);
  
  if ($Documents{$documentID}{NVER} eq "") { # Bad documents (no revisions)
    return 0;
  } 
  my $Groups_ref = &GetRevisionSecurityGroups($DocRevID);
  
  my @GroupIDs = @{$Groups_ref};
  
  unless (@GroupIDs) {return 1;}             # Public documents
  
  my $access = 0;

  foreach my $GroupID (@GroupIDs) {          # Check authorized users
    &FetchSecurityGroup($GroupID);           # vs. logged in user
    $ok_user = $SecurityGroups{$GroupID}{NAME};
    $ok_user =~ tr/[A-Z]/[a-z]/;             
    if ($ok_user eq $remote_user) {
      $access = 1;                           # User checks out
    }  
  }
  return $access;     
}

sub LastAccess { # Highest version user can access (with current security)
  my ($documentID) = @_;
  return 999;    # Open access for now
}

1;
