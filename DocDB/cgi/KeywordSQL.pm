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
    $KeywordGroups{$KeywordGroupID}{KEYGRP} = $KeywordGroupID;
    $KeywordGroups{$KeywordGroupID}{SHORT} = $ShortDescription;
    $KeywordGroups{$KeywordGroupID}{LONG}  = $LongDescription;
    $KeywordGroups{$KeywordGroupID}{Full}  = $ShortDescription." [".$LongDescription."]";
  }

  $keyword_list -> execute;
  $keyword_list -> bind_columns(undef, \($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription));
  while ($keyword_list -> fetch) {
    $KeywordListEntries{$KeywordID}{KEYELEM} = $KeywordID;
    $KeywordListEntries{$KeywordID}{KEYGRP} = $KeywordGroupID;
    $KeywordListEntries{$KeywordID}{SHORT} = $ShortDescription;
    $KeywordListEntries{$KeywordID}{LONG}  = $LongDescription;
    $KeywordListEntries{$KeywordID}{FULL}  = $KeywordGroups{$KeywordGroupID}{SHORT}.":".$ShortDescription;
  }
  foreach $key (keys %KeywordListEntries) {
    $FullKeywords{$key} =  $KeywordListEntries{$key}{FULL};
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
  my ($KeyListID) = @_;
  my ($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription);
  my $keyword_fetch   = $dbh -> prepare(
    "select KeywordID,KeywordGroupID,ShortDescription,LongDescription ".
    "from Keyword ".
    "where KeywordID=?");
  if ($KeywordListEntries{$KeyListID}{KEYELEM}) { # We already have this one
    return $KeywordListEntries{$KeyListID}{SHORT};
  }
  
  $keyword_fetch -> execute($KeyListID);
  ($KeywordID,$KeywordGroupID,$ShortDescription,$LongDescription) = $keyword_fetch -> fetchrow_array;
  &FetchKeywordGroup($KeywordGroupID);
  $KeywordListEntries{$KeyListID}{KEYELEM} = $KeywordID;
  $KeywordListEntries{$KeyListID}{KEYGRP} = $KeywordGroupID;
  $KeywordListEntries{$KeyListID}{SHORT} = $ShortDescription;
  $KeywordListEntries{$KeyListID}{LONG}  = $LongDescription;
  $KeywordListEntries{$KeyListID}{FULL}  = $KeywordGroups{$KeywordGroupID}{SHORT}.":".$ShortDescription;

  $FullKeywords{$KeyListID} = $KeywordListEntries{$KeyListID}{FULL};

  return $KeywordListEntries{$KeyListID}{SHORT};
}

sub FetchKeywordGroup { # Fetches a KeywordGroup by ID, adds to $KeywordListEntries{$KeywordID}{}
  my ($KeywordGroupID) = @_;
  my ($KeywordGroupID,$ShortDescription,$LongDescription);
  my $keygroup_fetch   = $dbh -> prepare(
    "select KeywordGroupID,ShortDescription,LongDescription ".
    "from KeywordGroup ".
    "where KeywordGroupID=?");
  if ($KeywordGroups{$KeywordGroupID}{KEYGRP}) { # We already have this one
    return $KeywordGroups{$KeywordGroupID}{KEYGRP};
  }

  $keygroup_fetch -> execute($KeywordGroupID);
  ($KeywordGroupID,$ShortDescription,$LongDescription) = $keygroup_fetch -> fetchrow_array;
  $KeywordGroups{$KeywordGroupID}{KEYGRP} = $KeywordGroupID;
  $KeywordGroups{$KeywordGroupID}{SHORT} = $ShortDescription;
  $KeywordGroups{$KeywordGroupID}{LONG}  = $LongDescription;

  return $KeywordGroups{$KeywordGroupID}{KEYGRP};
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
