sub CanAccess { # Can the user access (with current security) this version
  my ($documentID,$version) = @_;
  
  if ($documents{$document}{NVER} eq "") { # Bad documents (no revisions)
    return 0;
  } 
  
  return 1;     # Open access for now
}

sub LastAccess { # Highest version user can access (with current security)
  my ($documentID) = @_;
  return 999;    # Open access for now
}

1;
