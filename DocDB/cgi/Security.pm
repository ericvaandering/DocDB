sub CanAccess { # Can the user access (with current security) this version
  my ($documentID,$version) = @_;
  &FetchDocRevision($documentID,$version);
  
  if ($Documents{$documentID}{NVER} eq "") { # Bad documents (no revisions)
    return 0;
  } 

  my @ok_users = split /\,/,$DocRevisions{$DocRevID}{SECURITY};
  
  unless (@ok_users) {return 1;}             # Public documents
  
  my $access = 0;

  foreach my $ok_user (@ok_users) {          # Check authorized users
    $ok_user =~ tr/[A-Z]/[a-z]/;             # vs. logged in user
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
