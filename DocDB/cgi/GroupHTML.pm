sub PrintGroupParents ($) {
  my ($GroupID) = @_;

  print "<ul>\n";
  my @HierarchyIDs = keys %GroupsHierarchy;
  foreach $HierarchyID (@HierarchyIDs) {
    if ($GroupID == $GroupsHierarchy{$HierarchyID}{Child}) {
      my $ParentID = $GroupsHierarchy{$HierarchyID}{Parent};
      print "<li>$SecurityGroups{$ParentID}{NAME}\n";
    }  
  }
  print "</ul>\n";
}

sub PrintGroupChildren ($) {
  my ($GroupID) = @_;

  print "<ul>\n";
  my @HierarchyIDs = keys %GroupsHierarchy;
  foreach $HierarchyID (@HierarchyIDs) {
    if ($GroupID == $GroupsHierarchy{$HierarchyID}{Parent}) {
      my $ParentID = $GroupsHierarchy{$HierarchyID}{Child};
      print "<li>$SecurityGroups{$ParentID}{NAME}\n";
    }  
  }
  print "</ul>\n";
}

sub PrintGroupPermissions ($) {
  my ($GroupID) = @_;

  print "<ul>\n";
  print "<li>View\n";
  if ($SecurityGroups{$GroupID}{CanCreate}) {
    print "<li>Create/Modify\n";
  }  
  if ($SecurityGroups{$GroupID}{CanAdminister}) { # Doesn't exist yet
    print "<li>Administer\n";
  }  
  print "</ul>\n";
}
1;
