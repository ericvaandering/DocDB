sub FetchDocRevision {
  # Creates two hashes:
  # $DocRevIDs{DocumentID}{Version} holds the DocumentRevision ID
  # $DocRevisions{DocRevID}{FIELD} holds the Fields or references too them

  my ($documentID,$versionNumber) = @_;
  &FetchDocument($documentID);
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,TimeStamp,DocumentID,Obsolete ".
    "from DocumentRevision ".
    "where DocumentID=? and VersionNumber=? and Obsolete=0");
  if ($DocRevIDs{$documentID}{$versionNumber}) {
    return $DocRevIDs{$documentID}{$versionNumber};
  }
  $revision_list -> execute($documentID,$versionNumber);
  my ($DocRevID,$SubmitterID,$DocumentTitle,$PublicationInfo,
      $VersionNumber,$Abstract,$RevisionDate,
      $TimeStamp,$DocumentID,$Obsolete) = $revision_list -> fetchrow_array;

  $DocRevIDs{$documentID}{$versionNumber} = $DocRevID;
  $DocRevisions{$DocRevID}{SUBMITTER}     = $SubmitterID;
  $DocRevisions{$DocRevID}{TITLE}         = $DocumentTitle;
  $DocRevisions{$DocRevID}{PUBINFO}       = $PublicationInfo;
  $DocRevisions{$DocRevID}{ABSTRACT}      = $Abstract;
  $DocRevisions{$DocRevID}{DATE}          = $RevisionDate;
  $DocRevisions{$DocRevID}{TIMESTAMP}     = $TimeStamp;
  $DocRevisions{$DocRevID}{VERSION}       = $VersionNumber;
  $DocRevisions{$DocRevID}{DOCID}         = $DocumentID;
  $DocRevisions{$DocRevID}{OBSOLETE}      = $Obsolete;

  return $DocRevID;
}

sub FetchDocRevisionByID {
  # Creates two hashes:
  # $DocRevIDs{DocumentID}{Version} holds the DocumentRevision ID
  # $DocRevisions{DocRevID}{FIELD} holds the Fields or references too them

  my ($docRevID) = @_;
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,TimeStamp,DocumentID,Obsolete ".
    "from DocumentRevision ".
    "where DocRevID=?");
  if ($DocRevisions{$docRevID}{DOCID}) {
    return $DocRevisions{$docRevID}{DOCID};
  }
  $revision_list -> execute($docRevID);
  my ($DocRevID,$SubmitterID,$DocumentTitle,$PublicationInfo,
      $VersionNumber,$Abstract,$RevisionDate,
      $TimeStamp,$DocumentID,$Obsolete) = $revision_list -> fetchrow_array;

  $DocRevIDs{$DocumentID}{$VersionNumber} = $DocRevID;
  $DocRevisions{$DocRevID}{SUBMITTER}     = $SubmitterID;
  $DocRevisions{$DocRevID}{TITLE}         = $DocumentTitle;
  $DocRevisions{$DocRevID}{PUBINFO}       = $PublicationInfo;
  $DocRevisions{$DocRevID}{ABSTRACT}      = $Abstract;
  $DocRevisions{$DocRevID}{DATE}          = $RevisionDate;
  $DocRevisions{$DocRevID}{TIMESTAMP}     = $TimeStamp;
  $DocRevisions{$DocRevID}{VERSION}       = $VersionNumber;
  $DocRevisions{$DocRevID}{DOCID}         = $DocumentID;
  $DocRevisions{$DocRevID}{OBSOLETE}      = $Obsolete;

  return $DocRevID;
}

sub FetchRevisionsByDocument {
  my ($DocumentID) = @_;
  &FetchDocument($DocumentID);
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,TimeStamp,DocumentID,Obsolete ".
    "from DocumentRevision ".
    "where DocumentID=?");
  $revision_list -> execute($DocumentID);
  
  $revision_list -> bind_columns(undef, \($DocRevID,$SubmitterID,$DocumentTitle,
                                          $PublicationInfo,$VersionNumber,$Abstract,
                                          $RevisionDate,$TimeStamp,
                                          $DocumentID,$Obsolete));
  my @DocRevList = ();
  while ($revision_list -> fetch) {
    if ($DocRevisions{$DocRevID}{DOCID}) {
      push @DocRevList,$DocRevID;
      next; # We did this one already
    } 

    $DocRevIDs{$DocumentID}{$VersionNumber} = $DocRevID;
    $DocRevisions{$DocRevID}{SUBMITTER}     = $SubmitterID;
    $DocRevisions{$DocRevID}{TITLE}         = $DocumentTitle;
    $DocRevisions{$DocRevID}{PUBINFO}       = $PublicationInfo;
    $DocRevisions{$DocRevID}{ABSTRACT}      = $Abstract;
    $DocRevisions{$DocRevID}{DATE}          = $RevisionDate;
    $DocRevisions{$DocRevID}{TIMESTAMP}     = $TimeStamp;
    $DocRevisions{$DocRevID}{VERSION}       = $VersionNumber;
    $DocRevisions{$DocRevID}{DOCID}         = $DocumentID;
    $DocRevisions{$DocRevID}{OBSOLETE}      = $Obsolete;
    unless ($Obsolete) {
      push @DocRevList,$DocRevID;
    }  
  }
  
  return @DocRevList;

}

1;
