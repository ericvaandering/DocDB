# FIXME: Get timestamps

sub ClearKeywords {
  %Keywords = ();
  %FullKeywords       = ();
  %KeywordGroups      = ();
}

sub GetKeywords {

  my $KeywordList = $dbh -> prepare("select KeywordID from Keyword");

  $KeywordList -> execute;
  $KeywordList -> bind_columns(undef, \($KeywordID));
  while ($KeywordList -> fetch) {
    push @KeywordListIDs,$KeywordID;
    &FetchKeyword($KeywordID);
  }
  return @KeywordListIDs;
};

sub GetKeywordsByKeywordGroupID { # FIXME: Rename GetKeywords by KeywordGroupID
  my ($KeywordGroupID) = @_;
  my @KeywordListIDs = ();
  my $KeyList = $dbh -> prepare("select KeywordID from Keyword where KeywordGroupID=?");

  my ($KeywordID);
  $KeyList -> execute($KeywordGroupID);
  $KeyList -> bind_columns(undef, \($KeywordID));
  while ($KeyList -> fetch) {
    push @KeywordListIDs,$KeywordID;
    &FetchKeyword($KeywordID);
  }
  return @KeywordListIDs;
};

sub FetchKeyword { # Fetches a Keyword by ID, adds to $Keywords{$keywordID}{}

  my ($keywordID) = @_;

  my ($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription,$TimeStamp);
  my $KeywordFetch   = $dbh -> prepare(
    "select KeywordID,KeywordGroupID,ShortDescription,LongDescription,TimeStamp ".
    "from Keyword ".
    "where KeywordID=?");
  if ($Keywords{$keywordID}{TimeStamp}) { # We already have this one
    return $Keywords{$keywordID}{Short};
  }
  
  $KeywordFetch -> execute($keywordID);
  ($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription,$TimeStamp) = $KeywordFetch -> fetchrow_array;

  if ($KeywordID) {
    &FetchKeywordGroup($KeywordGroupID); # Do we need this?
    $Keywords{$KeywordID}{KeywordGroupID} = $KeywordGroupID; # FIXME: Will go away
    $Keywords{$KeywordID}{Short}          = $ShortDescription;
    $Keywords{$KeywordID}{Long}           = $LongDescription;
    $Keywords{$KeywordID}{TimeStamp}      = $TimeStamp;
    $Keywords{$KeywordID}{Full}           = $KeywordGroups{$KeywordGroupID}{Short}.":".$ShortDescription;

    $FullKeywords{$KeywordID} = $Keywords{$keywordID}{Full};
    return $Keywords{$KeywordID}{Short};
  } else {
    return "";
  }
}

sub FetchKeywordGroup { # Fetches a KeywordGroup by ID, adds to $KeywordGroups{$KeywordGroupID}{}
  my ($keywordGroupID) = @_;

  my ($KeywordGroupID,$ShortDescription,$LongDescription,$TimeStamp);
  my $keygroup_fetch   = $dbh -> prepare(
    "select KeywordGroupID,ShortDescription,LongDescription,TimeStamp ".
    "from KeywordGroup ".
    "where KeywordGroupID=?");
  if ($KeywordGroups{$keywordGroupID}{TimeStamp}) { # We already have this one
    return $keywordGroupID;
  }

  $keygroup_fetch -> execute($keywordGroupID);
  ($KeywordGroupID,$ShortDescription,$LongDescription,$TimeStamp) = $keygroup_fetch -> fetchrow_array;
  if ($KeywordGroupID) {
    $KeywordGroups{$KeywordGroupID}{KeywordGroupID} = $KeywordGroupID; # FIXME: Remove
    $KeywordGroups{$KeywordGroupID}{Short}          = $ShortDescription;
    $KeywordGroups{$KeywordGroupID}{Long}           = $LongDescription;
    $KeywordGroups{$KeywordGroupID}{TimeStamp}      = $TimeStamp;
  } 
  
  return $KeywordGroupID;
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
