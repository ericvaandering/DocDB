sub GetAllDocuments {
  my ($DocumentID);
  my $DocumentList    = $dbh->prepare(
     "select DocumentID,RequesterID,RequestDate,DocumentType,TimeStamp ".
     "from Document");
  my $MaxVersionQuery = $dbh->prepare("select DocumentID,max(VersionNumber) ".
                                     "from DocumentRevision ".
                                     "group by DocumentID;");

  my ($DocumentID,$RequesterID,$RequestDate,$DocumentType,$TimeStamp);
  my ($MaxVersion);
  
  $DocumentList -> execute;
  $DocumentList -> bind_columns(undef, \($DocumentID,$RequesterID,$RequestDate,$DocumentType,$TimeStamp));
  %Documents = ();
  @DocumentIDs = ();
  while ($DocumentList -> fetch) {
    $Documents{$DocumentID}{DOCID}     = $DocumentID;
    $Documents{$DocumentID}{REQUESTER} = $RequesterID;
    $Documents{$DocumentID}{DATE}      = $RequestDate;
    $Documents{$DocumentID}{TYPE}      = $DocumentType;
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
  my $DocumentList  = $dbh->prepare(
     "select DocumentID,RequesterID,RequestDate,DocumentType,TimeStamp ".
     "from Document where DocumentID=?");
  my $MaxVersionQuery    = $dbh->prepare("select MAX(VersionNumber) from ".
                                     "DocumentRevision where DocumentID=?");
  if ($Documents{$DocumentID}{DOCID}) { # Already fetched
    return $Documents{$DocumentID}{DOCID};
  }  
  $DocumentList -> execute($DocumentID);
  my ($DocumentID,$RequesterID,$RequestDate,$DocumentType,$TimeStamp) = $DocumentList -> fetchrow_array;

  if ($DocumentID) {
    $Documents{$DocumentID}{DOCID}     = $DocumentID;
    $Documents{$DocumentID}{REQUESTER} = $RequesterID;
    $Documents{$DocumentID}{DATE}      = $RequestDate;
    $Documents{$DocumentID}{TYPE}      = $DocumentType;
    $Documents{$DocumentID}{TimeStamp} = $TimeStamp;
    push @DocumentIDs,$DocumentID;

    $MaxVersionQuery -> execute($DocumentID);
    ($Documents{$DocumentID}{NVersions}) = $MaxVersionQuery -> fetchrow_array;
    return $Documents{$DocumentID}{DOCID};
  } else {
    return 0;
  }  
}

sub InsertDocument (%) {
  my %Params = @_;

  my $TypeID        = $Params{-typeid}        || 0;
  my $RequesterID   = $Params{-requesterid}   || 0;
  my $DateTime      = $Params{-datetime};

  unless ($DateTime) {
    my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
    $Year += 1900;
    ++$Mon;
    $DateTime = "$Year-$Mon-$Day $Hour:$Min:$Sec";
  } 

  my $Insert = $dbh -> prepare( "insert into Document (DocumentID, RequesterID, RequestDate, DocumentType) values (0,?,?,?)");
  
  $Insert -> execute($RequesterID,$DateTime,$TypeID);
  my $DocumentID = $Insert -> {mysql_insertid}; # Works with MySQL only
  
  return $DocumentID;        
}            

1;
