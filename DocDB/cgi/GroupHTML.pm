sub PrintGroupParents ($) {
  my ($GroupID) = @_;

  print "<ul>\n";
  my @HierarchyIDs = keys %GroupsHierarchy;
  foreach $HierarchyID (@HierarchyIDs) {
    if ($GroupID == $GroupsHierarchy{$HierarchyID}{CHILD}) {
      my $ParentID = $GroupsHierarchy{$HierarchyID}{PARENT};
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
    if ($GroupID == $GroupsHierarchy{$HierarchyID}{PARENT}) {
      my $ParentID = $GroupsHierarchy{$HierarchyID}{CHILD};
      print "<li>$SecurityGroups{$ParentID}{NAME}\n";
    }  
  }
  print "</ul>\n";
}

sub PrintGroupPermissions ($) {
  my ($GroupID) = @_;

  print "<ul>\n";
  if ($SecurityGroups{$GroupID}{CanCreate}) {
    print "<li>Create\n";
  }  
  print "</ul>\n";
}
1;
