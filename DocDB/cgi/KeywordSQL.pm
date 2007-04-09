#
#        Name: KeywordSQL.pm
# Description: Routines to extract keyword related information from SQL database 
#
#      Author: Lynn Garren (garren@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2007 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License 
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

sub ClearKeywords {
  %Keywords         = ();
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

sub LookupKeywordGroup { # Keep for Lynn? Returns KeywordGroupID from Keyword Group Name
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
