sub GetSecurityGroups { # Creates/fills a hash $SecurityGroups{$GroupID}{} with all authors
  my ($GroupID,$Name,$Description,$CanCreate,$CanAdminister,$TimeStamp);
  my $GroupList  = $dbh -> prepare(
     "select GroupID,Name,Description,CanCreate,CanAdminister,TimeStamp from SecurityGroup"); 
  $GroupList -> execute;
  $GroupList -> bind_columns(undef, \($GroupID,$Name,$Description,$CanCreate,$CanAdminister,$TimeStamp));
  %SecurityGroups = ();
  while ($GroupList -> fetch) {
    $SecurityGroups{$GroupID}{NAME}          = $Name;
    $SecurityGroups{$GroupID}{DESCRIPTION}   = $Description;
    $SecurityGroups{$GroupID}{CanCreate}     = $CanCreate;
    $SecurityGroups{$GroupID}{CanAdminister} = $CanAdminister;
    $SecurityGroups{$GroupID}{TIMESTAMP}     = $TimeStamp;
    $SecurityIDs{$Name} = $GroupID;
  }
  
  my ($HierarchyID,$ChildID,$ParentID);
  my $HierarchyList  = $dbh -> prepare(
     "select HierarchyID,ChildID,ParentID,TimeStamp from GroupHierarchy"); 
  $HierarchyList -> execute;
  $HierarchyList -> bind_columns(undef, \($HierarchyID,$ChildID,$ParentID,$TimeStamp));
  %GroupsHierarchy = ();
  while ($HierarchyList -> fetch) {
    $GroupsHierarchy{$HierarchyID}{CHILD}     = $ChildID;
    $GroupsHierarchy{$HierarchyID}{PARENT}    = $ParentID;
    $GroupsHierarchy{$HierarchyID}{TIMESTAMP} = $TimeStamp;
  }
}

sub FetchSecurityGroup {
  my ($GroupID) = @_;
  my ($Name,$Description,$CanCreate,$CanAdminister,$TimeStamp);
  my $GroupList  = $dbh -> prepare(
     "select Name,Description,CanCreate,CanAdminister,TimeStamp from SecurityGroup where GroupID=?"); 
  $GroupList -> execute($GroupID);
  $GroupList -> bind_columns(undef, \($Name,$Description,$CanCreate,$CanAdminister,$TimeStamp));
  while ($GroupList -> fetch) {
    $SecurityGroups{$GroupID}{NAME}          = $Name;
    $SecurityGroups{$GroupID}{DESCRIPTION}   = $Description;
    $SecurityGroups{$GroupID}{CanCreate}     = $CanCreate; 
    $SecurityGroups{$GroupID}{CanAdminister} = $CanAdminister;
    $SecurityGroups{$GroupID}{TIMESTAMP}     = $TimeStamp;
    $SecurityIDs{$Name} = $GroupID;
  }
  
  my ($HierarchyID,$ChildID,$ParentID);
  my $HierarchyList  = $dbh -> prepare(
     "select HierarchyID,ChildID,ParentID,TimeStamp from GroupHierarchy where ParentID=? or ChildID=?"); 
  $HierarchyList -> execute($GroupID,$GroupID);
  $HierarchyList -> bind_columns(undef, \($HierarchyID,$ChildID,$ParentID,$TimeStamp));
  while ($HierarchyList -> fetch) {
    $GroupsHierarchy{$HierarchyID}{CHILD}     = $ChildID;
    $GroupsHierarchy{$HierarchyID}{PARENT}    = $ParentID;
    $GroupsHierarchy{$HierarchyID}{TIMESTAMP} = $TimeStamp;
    print "$TimeStamp<br>\n";
 }

}

sub GetRevisionSecurityGroups {
  my ($DocRevID) = @_;
  
  if ($RevisionSecurities{$DocRevID}{DocRevID}) {
    return @{$RevisionSecurities{$DocRevID}{GROUPS}};
  }
    
  my @groups = ();
  my ($RevSecurityID,$GroupID);
  my $GroupList = $dbh->prepare(
    "select RevSecurityID,GroupID from RevisionSecurity where DocRevID=?");
  $GroupList -> execute($DocRevID);
  $GroupList -> bind_columns(undef, \($RevSecurityID,$GroupID));
  while ($GroupList -> fetch) {
    push @groups,$GroupID;
  }
  $RevisionSecurities{$DocRevID}{DocRevID} = $DocRevID;
  $RevisionSecurities{$DocRevID}{GROUPS}   = [@groups];
  return @{$RevisionSecurities{$DocRevID}{GROUPS}};
}

sub GetRevisionModifyGroups {
  my ($DocRevID) = @_;
  
  if ($RevisionModifies{$DocRevID}{DocRevID}) {
    return @{$RevisionModifies{$DocRevID}{GROUPS}};
  }
    
  my @groups = ();
  my ($RevModifyID,$GroupID);
  my $GroupList = $dbh->prepare(
    "select RevModifyID,GroupID from RevisionModify where DocRevID=?");
  $GroupList -> execute($DocRevID);
  $GroupList -> bind_columns(undef, \($RevModifyID,$GroupID));
  while ($GroupList -> fetch) {
    push @groups,$GroupID;
  }
  $RevisionModifies{$DocRevID}{DocRevID} = $DocRevID;
  $RevisionModifies{$DocRevID}{GROUPS}   = [@groups];
  return @{$RevisionModifies{$DocRevID}{GROUPS}};
}

sub SecurityLookup {
  my ($user) = @_;
  
  my $group_name = $dbh->prepare(
    "select Name from SecurityGroup where lower(Name) like lower(?)");
  $group_name -> execute($user);

  my ($Name) = $group_name -> fetchrow_array; 
  
  return $Name;
}


1;
