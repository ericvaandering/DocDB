# FIXME: Get timestamps

sub GetKeywordList {

  my $keyword_list   = $dbh->prepare("select KeywordID,KeywordGroupID,ShortDescription,LongDescription from Keyword");
  my $keywordgroup_list   = $dbh->prepare("select KeywordGroupID,ShortDescription,LongDescription from KeywordGroup");

  %KeywordListEntries = ();
  %KeywordGroups = ();
  %FullKeywords  = ();

  my ($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription);

  $keywordgroup_list -> execute;
  $keywordgroup_list -> bind_columns(undef, \($KeywordGroupID,$ShortDescription,$LongDescription));
  while ($keywordgroup_list -> fetch) {
    $KeywordGroups{$KeywordGroupID}{KeywordGroupID} = $KeywordGroupID;
    $KeywordGroups{$KeywordGroupID}{Short} = $ShortDescription;
    $KeywordGroups{$KeywordGroupID}{Long}  = $LongDescription;
    $KeywordGroups{$KeywordGroupID}{Full}  = $ShortDescription." [".$LongDescription."]";
  }

  $keyword_list -> execute;
  $keyword_list -> bind_columns(undef, \($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription));
  while ($keyword_list -> fetch) {
    $KeywordListEntries{$KeywordID}{KeywordGroupID} = $KeywordGroupID;
    $KeywordListEntries{$KeywordID}{Short} = $ShortDescription;
    $KeywordListEntries{$KeywordID}{Long}  = $LongDescription;
    $KeywordListEntries{$KeywordID}{Full}  = $KeywordGroups{$KeywordGroupID}{Short}.":".$ShortDescription;
  }
  foreach $key (keys %KeywordListEntries) {
    $FullKeywords{$key} =  $KeywordListEntries{$key}{Full};
  }
};

sub GetKeywords {
  my ($KeywordGroupID) = @_;
  my @KeywordListIDs = ();
  my $KeyList = $dbh->prepare("select KeywordID from Keyword where KeywordGroupID=?");

  my ($KeywordID);
  $KeyList -> execute($KeywordGroupID);
  $KeyList -> bind_columns(undef, \($KeywordID));
  while ($KeyList -> fetch) {
    push @KeywordListIDs,$KeywordID;
  }
  return @KeywordListIDs;
};

sub FetchKeyword { # Fetches a Keyword by ID, adds to $KeywordListEntries{$KeyListID}{}

  # FIXME: KeyListID is really KeywordID

  my ($KeyListID) = @_;
  my ($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription);
  my $keyword_fetch   = $dbh -> prepare(
    "select KeywordID,KeywordGroupID,ShortDescription,LongDescription ".
    "from Keyword ".
    "where KeywordID=?");
  if ($KeywordListEntries{$KeyListID}{Short}) { # FIXME: Change to timestamps # We already have this one
    return $KeywordListEntries{$KeyListID}{Short};
  }
  
  $keyword_fetch -> execute($KeyListID);
  ($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription) = $keyword_fetch -> fetchrow_array;
  &FetchKeywordGroup($KeywordGroupID);
  $KeywordListEntries{$KeyListID}{KeywordGroupID} = $KeywordGroupID;
  $KeywordListEntries{$KeyListID}{Short} = $ShortDescription;
  $KeywordListEntries{$KeyListID}{Long}  = $LongDescription;
  $KeywordListEntries{$KeyListID}{Full}  = $KeywordGroups{$KeywordGroupID}{Short}.":".$ShortDescription;

  $FullKeywords{$KeyListID} = $KeywordListEntries{$KeyListID}{Full};

  return $KeywordListEntries{$KeyListID}{Short};
}

sub FetchKeywordGroup { # Fetches a KeywordGroup by ID, adds to $KeywordListEntries{$KeywordID}{}
  my ($KeywordGroupID) = @_;
  my ($KeywordGroupID,$ShortDescription,$LongDescription);
  my $keygroup_fetch   = $dbh -> prepare(
    "select KeywordGroupID,ShortDescription,LongDescription ".
    "from KeywordGroup ".
    "where KeywordGroupID=?");
  if ($KeywordGroups{$KeywordGroupID}{KeywordGroupID}) { # We already have this one
    return $KeywordGroups{$KeywordGroupID}{KeywordGroupID};
  }

  $keygroup_fetch -> execute($KeywordGroupID);
  ($KeywordGroupID,$ShortDescription,$LongDescription) = $keygroup_fetch -> fetchrow_array;
  $KeywordGroups{$KeywordGroupID}{KeywordGroupID} = $KeywordGroupID;
  $KeywordGroups{$KeywordGroupID}{Short} = $ShortDescription;
  $KeywordGroups{$KeywordGroupID}{Long}  = $LongDescription;

  return $KeywordGroups{$KeywordGroupID}{KeywordGroupID};
}

sub LookupKeywordGroup { # Returns KeywordGroupID from Keyword Group Name
  my ($KeywordGroupName) = @_;
  my $keygroup_fetch   = $dbh -> prepare(
    "select KeywordGroupID from KeywordGroup where ShortDescription=?");

  $keygroup_fetch -> execute($KeywordGroupName);
  my $KeywordGroupID = $keygroup_fetch -> fetchrow_array;
  &FetchKeywordGroup($KeywordGroupID);
  
  return $KeywordGroupID;
}

1;
