#
#        Name: KeywordSQL.pm
# Description: Routines to extract keyword related information from SQL database 
#
#      Author: Lynn Garren (garren@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)
#

sub ClearKeywords {
  %Keywords         = ();
  %FullKeywords     = (); # FIXME: Get rid of this
  %KeywordGroups    = ();
  %KeywordGroupings = ();
}

sub GetKeywords {

  my $KeywordList = $dbh -> prepare("select KeywordID from Keyword");
  my ($KeywordID);

  &GetKeywordGroups;

  $KeywordList -> execute;
  $KeywordList -> bind_columns(undef, \($KeywordID));
  while ($KeywordList -> fetch) {
    if ($KeywordID) {
      push @KeywordListIDs,$KeywordID;
      &FetchKeyword($KeywordID);
    }  
  }
  return @KeywordListIDs;
};

sub GetKeywordsByKeywordGroupID {
  my ($KeywordGroupID) = @_;
  my @KeywordListIDs = ();
  my $KeyList = $dbh -> prepare("select Keyword.KeywordID from Keyword,KeywordGrouping ".
                                "where KeywordGrouping.KeywordGroupID=? and Keyword.KeywordID=KeywordGrouping.KeywordID");

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
    "select KeywordID,ShortDescription,LongDescription,TimeStamp ".
    "from Keyword ".
    "where KeywordID=?");
  if ($Keywords{$keywordID}{TimeStamp}) { # We already have this one
    return $Keywords{$keywordID}{Short};
  }
  
  $KeywordFetch -> execute($keywordID);
  ($KeywordID,$ShortDescription,$LongDescription,$TimeStamp) = $KeywordFetch -> fetchrow_array;

  if ($KeywordID) {
    $Keywords{$KeywordID}{Short}          = $ShortDescription;
    $Keywords{$KeywordID}{Long}           = $LongDescription;
    $Keywords{$KeywordID}{TimeStamp}      = $TimeStamp;

    $FullKeywords{$KeywordID} = $Keywords{$KeywordID}{Full}; # FIXME: Remove
    return $Keywords{$KeywordID}{Short};
  } else {
    return "";
  }
}

sub GetKeywordGroups {

  my $KeywordGroupList = $dbh -> prepare("select KeywordGroupID from KeywordGroup");
  my ($KeywordGroupID,@KeywordGroupIDs);

  $KeywordGroupList -> execute;
  $KeywordGroupList -> bind_columns(undef, \($KeywordGroupID));
  while ($KeywordGroupList -> fetch) {
    $KeywordGroupID = &FetchKeywordGroup($KeywordGroupID);
    if ($KeywordGroupID) {
      push @KeywordGroupIDs,$KeywordGroupID;
    }  
  }
  return @KeywordGroupIDs;
};

sub FetchKeywordGroup { # Fetches a KeywordGroup by ID, adds to $KeywordGroups{$KeywordGroupID}{}
  my ($KeywordGroupID) = @_;
  if ($KeywordGroups{$KeywordGroupID}{TimeStamp}) { # We already have this one
    return $KeywordGroupID;
  }

  my ($ShortDescription,$LongDescription,$TimeStamp);
  my $keygroup_fetch   = $dbh -> prepare(
    "select ShortDescription,LongDescription,TimeStamp ".
    "from KeywordGroup ".
    "where KeywordGroupID=?");

  $keygroup_fetch -> execute($KeywordGroupID);
  ($ShortDescription,$LongDescription,$TimeStamp) = $keygroup_fetch -> fetchrow_array;
  if ($TimeStamp) {
    $KeywordGroups{$KeywordGroupID}{KeywordGroupID} = $KeywordGroupID; # FIXME: Remove
    $KeywordGroups{$KeywordGroupID}{Short}          = $ShortDescription;
    $KeywordGroups{$KeywordGroupID}{Long}           = $LongDescription;
    $KeywordGroups{$KeywordGroupID}{TimeStamp}      = $TimeStamp;
  } else {
    undef $KeywordGroupID;
  }
  return $KeywordGroupID;
}

sub GetKeywordGroupingsByKeywordID ($) {
  my ($KeywordID) = @_;
  
  my ($KeywordGroupingID,@KeywordGroupingIDs);
  
  my $KeywordGroupingList = $dbh -> prepare(
    "select KeywordGroupingID from KeywordGrouping where KeywordID=?");
  $KeywordGroupingList -> execute($KeywordID);
  $KeywordGroupingList -> bind_columns(undef, \($KeywordGroupingID));
  while ($KeywordGroupingList -> fetch) {
    push @KeywordGroupingIDs,$KeywordGroupingID;
    &FetchKeywordGrouping($KeywordGroupingID);
  }

  return @KeywordGroupingIDs;
}

sub GetKeywordGroupingsByKeywordGroupID ($) {
  my ($KeywordGroupID) = @_;
  
  my ($KeywordGroupingID,@KeywordGroupingIDs);
  
  my $KeywordGroupingList = $dbh -> prepare(
    "select KeywordGroupingID from KeywordGrouping where KeywordGroupID=?");
  $KeywordGroupingList -> execute($KeywordGroupID);
  $KeywordGroupingList -> bind_columns(undef, \($KeywordGroupingID));
  while ($KeywordGroupingList -> fetch) {
    push @KeywordGroupingIDs,$KeywordGroupingID;
    &FetchKeywordGrouping($KeywordGroupingID);
  }

  return @KeywordGroupingIDs;
}

sub FetchKeywordGrouping { # Fetches a Keyword-KeywordGroup relationship
  my ($KeywordGroupingID) = @_;
  
  if ($KeywordGroupings{$KeywordGroupingID}{TimeStamp}) { # We already have this one
    return $KeywordGroupingID;
  }

  my ($KeywordGroupID,$KeywordID,$TimeStamp);
  my $KeywordGroupingFetch   = $dbh -> prepare(
    "select KeywordGroupID,KeywordID,TimeStamp ".
    "from KeywordGrouping where KeywordGroupingID=?");

  $KeywordGroupingFetch -> execute($KeywordGroupingID);
  ($KeywordGroupID,$KeywordID,$TimeStamp) = $KeywordGroupingFetch -> fetchrow_array;
  if ($TimeStamp) {
    $KeywordGroupings{$KeywordGroupingID}{KeywordGroupID} = $KeywordGroupID;
    $KeywordGroupings{$KeywordGroupingID}{KeywordID}      = $KeywordID;
    $KeywordGroupings{$KeywordGroupingID}{TimeStamp}      = $TimeStamp;
  } else {
    undef $KeywordGroupingID;
  }
  
  return $KeywordGroupingID;
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

sub DeleteKeyword ($) {
  my ($KeywordID) = @_;
  
  if ($KeywordID) {
    my $KeywordDelete = $dbh -> prepare("delete from Keyword where KeywordID=?");
       $KeywordDelete -> execute($KeywordID);
    my $KeywordGroupingDelete = $dbh -> prepare("delete from KeywordGrouping where KeywordID=?");
  }
}

1;
