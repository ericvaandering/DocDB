sub GetAllDocuments {
  my ($DocumentID);
  my $document_list  = $dbh->prepare(
     "select DocumentID,RequesterID,RequestDate,DocumentType,TimeStamp ".
     "from Document");
  my $max_version    = $dbh->prepare("select DocumentID,max(VersionNumber) ".
                                     "from DocumentRevision ".
                                     "group by DocumentID;");

  my ($DocumentID,$RequesterID,$RequestDate,$DocumentType,$TimeStamp);
  my ($MaxVersion);
  
  $document_list -> execute;
  $document_list -> bind_columns(undef, \($DocumentID,$RequesterID,$RequestDate,$DocumentType,$TimeStamp));
  %Documents = ();
  @DocumentIDs = ();
  while ($document_list -> fetch) {
    $Documents{$DocumentID}{DOCID} = $DocumentID;
    $Documents{$DocumentID}{REQUESTER} = $RequesterID;
    $Documents{$DocumentID}{DATE} = $RequestDate;
    $Documents{$DocumentID}{TYPE} = $DocumentType;
    $Documents{$DocumentID}{TIMESTAMP} = $TimeStamp;
    push @DocumentIDs,$DocumentID;
  }
  
### Number of versions for each document
  
  $max_version -> execute;
  $max_version -> bind_columns(undef, \($DocumentID,$MaxVersion));
  while ($max_version -> fetch) {
    $Documents{$DocumentID}{NVER} = $MaxVersion;
  }
};

sub FetchDocument {
  my ($DocumentID) =@_;
  my $document_list  = $dbh->prepare(
     "select DocumentID,RequesterID,RequestDate,DocumentType,TimeStamp ".
     "from Document where DocumentID=?");
  my $max_version    = $dbh->prepare("select MAX(VersionNumber) from ".
                                     "DocumentRevision where DocumentID=?");
  if ($Documents{$DocumentID}{DOCID}) { # Already fetched
    return $Documents{$DocumentID}{DOCID};
  }  
  $document_list -> execute($DocumentID);
  ($DocumentID,$RequesterID,$RequestDate,$DocumentType,$TimeStamp) = $document_list -> fetchrow_array;

# FIXME handle non-existent documents

  $Documents{$DocumentID}{DOCID} = $DocumentID;
  $Documents{$DocumentID}{REQUESTER} = $RequesterID;
  $Documents{$DocumentID}{DATE} = $RequestDate;
  $Documents{$DocumentID}{TYPE} = $DocumentType;
  $Documents{$DocumentID}{TIMESTAMP} = $TimeStamp;
  push @DocumentIDs,$DocumentID;
  
  $max_version -> execute($DocumentID);
  ($Documents{$DocumentID}{NVER}) = $max_version -> fetchrow_array;
  return $Documents{$DocumentID}{DOCID};
}


1;
