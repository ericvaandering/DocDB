sub CanAccess { # Can the user access (with current security) this version
  my ($documentID,$version) = @_;
  my $DocRevID = &FetchDocRevision($documentID,$version);
  
  if ($Documents{$documentID}{NVER} eq "") { # Bad documents (no revisions)
    return 0;
  } 
  my $Groups_ref = &GetRevisionSecurityGroups($DocRevID);
  
  my @GroupIDs = @{$Groups_ref};
  
  unless (@GroupIDs) {return 1;}             # Public documents

# See if current user is in the list of users who can access this document
  
  my $access = 0;

  foreach my $GroupID (@GroupIDs) { # Check auth. users vs. logged in user
    $ok_user = $SecurityGroups{$GroupID}{NAME};
    $ok_user =~ tr/[A-Z]/[a-z]/; 
    if ($ok_user eq $remote_user) {
      $access = 1;                           # User checks out
    }  
  }
  if ($access) {return $access;}

# See if current users children can access this document

  my @HierarchyIDs = keys %GroupsHierarchy;
  foreach $ID (@HierarchyIDs) {
    $Parent = $SecurityGroups{$GroupsHierarchy{$ID}{PARENT}}{NAME}; 
    $Child  = $SecurityGroups{$GroupsHierarchy{$ID}{CHILD}}{NAME}; 
    $Parent =~ tr/[A-Z]/[a-z]/;
    $Child  =~ tr/[A-Z]/[a-z]/;
    if ($Parent eq $remote_user) {
      foreach my $GroupID (@GroupIDs) { 
        $ok_user = $SecurityGroups{$GroupID}{NAME};
        $ok_user =~ tr/[A-Z]/[a-z]/; 
        if ($ok_user eq $Child) {
          $access = 1;                           
        }  
      }
    }  
  }
  return $access;       
}

sub CanModify { # Can the user modify (with current security) this docuement
  my ($documentID) = @_;
  unless ($remote_user) {return 0;} #No user logged in, can't modify 

# If they can access last version they can modify the document    

  &FetchDocument($documentID);
  my $version = $Documents{$documentID}{NVER}; 
  my $access = &CanAccess($documentID,$version); 
  
  return $access;
}

sub LastAccess { # Highest version user can access (with current security)
  my ($documentID) = @_;
  return 999;    # Open access for now
}

1;
