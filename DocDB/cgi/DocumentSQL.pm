
# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

sub GetAllDocuments {
  my ($DocumentID);
  my $DocumentList    = $dbh->prepare(
     "select DocumentID,RequesterID,RequestDate,TimeStamp ".
     "from Document");
  my $MaxVersionQuery = $dbh->prepare("select DocumentID,max(VersionNumber) ".
                                     "from DocumentRevision ".
                                     "group by DocumentID;");

  my ($DocumentID,$RequesterID,$RequestDate,$TimeStamp);
  my ($MaxVersion);
  
  $DocumentList -> execute;
  $DocumentList -> bind_columns(undef, \($DocumentID,$RequesterID,$RequestDate,$TimeStamp));
  %Documents = ();
  @DocumentIDs = ();
  while ($DocumentList -> fetch) {
    $Documents{$DocumentID}{DocID}     = $DocumentID;
    $Documents{$DocumentID}{Requester} = $RequesterID;
    $Documents{$DocumentID}{Date}      = $RequestDate;
    $Documents{$DocumentID}{TimeStamp} = $TimeStamp;
    push @DocumentIDs,$DocumentID;
  }
  
### Number of versions for each document
  
  $MaxVersionQuery -> execute;
  $MaxVersionQuery -> bind_columns(undef, \($DocumentID,$MaxVersion));
  while ($MaxVersionQuery -> fetch) {
    $Documents{$DocumentID}{NVersions} = $MaxVersion;
  }
};

sub FetchDocument {
  my ($DocumentID) = @_;

  if ($Documents{$DocumentID}{DocID} && defined $Documents{$DocumentID}{NVersions}) { 
    return $DocumentID;  # Already fetched
  }  

  my $DocumentList    = $dbh -> prepare("select DocumentID,RequesterID,RequestDate,TimeStamp ".
                                        "from Document where DocumentID=?");
  my $MaxVersionQuery = $dbh -> prepare("select MAX(VersionNumber) from ".
                                        "DocumentRevision where DocumentID=?");
  $DocumentList -> execute($DocumentID);
  my ($DocumentID,$RequesterID,$RequestDate,$TimeStamp) = $DocumentList -> fetchrow_array;
  push @DebugStack,"From Database DocID: $DocumentID";

  if ($DocumentID) {
    $Documents{$DocumentID}{DocID}     = $DocumentID;
    $Documents{$DocumentID}{Requester} = $RequesterID;
    $Documents{$DocumentID}{Date}      = $RequestDate;
    $Documents{$DocumentID}{TimeStamp} = $TimeStamp;
    push @DocumentIDs,$DocumentID;

    $MaxVersionQuery -> execute($DocumentID);
    ($Documents{$DocumentID}{NVersions}) = $MaxVersionQuery -> fetchrow_array;
    return $DocumentID;
  } else {
    return 0;
  }  
}

sub InsertDocument (%) {
  my %Params = @_;

  my $DocumentID    = $Params{-docid}         || 0;
#  my $TypeID        = $Params{-typeid}        || 0;
  my $RequesterID   = $Params{-requesterid}   || 0;
  my $DateTime      = $Params{-datetime};

  unless ($DateTime) {
    my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
    $Year += 1900;
    ++$Mon;
    $DateTime = "$Year-$Mon-$Day $Hour:$Min:$Sec";
  } 

  my $Insert = $dbh -> prepare( "insert into Document (DocumentID, RequesterID, RequestDate) values (?,?,?)");
  
  $Insert -> execute($DocumentID,$RequesterID,$DateTime);
  $DocumentID = $Insert -> {mysql_insertid}; # Works with MySQL only
  
  return $DocumentID;        
}            

1;
