sub GetAllDocuments {
  my ($DocumentID);
  my $document_list  = $dbh->prepare(
     "select DocumentID,RequesterID,RequestDate,DocumentType,TimeStamp ".
     "from Document");
  my $max_version    = $dbh->prepare("select MAX(VersionNumber) from ".
                                     "DocumentRevision where DocumentID=?");
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
  my $document;
  foreach $document (@DocumentIDs) {
    $max_version -> execute($document);
    ($Documents{$document}{NVER}) = $max_version -> fetchrow_array;
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
