sub FetchDocRevisionByID {

  #FIXME Change name to FetchDocumentRevision
  # Creates two hashes:
  # $DocRevIDs{DocumentID}{Version} holds the DocumentRevision ID
  # $DocRevisions{DocRevID}{FIELD} holds the Fields or references too them

  my ($docRevID) = @_;
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,TimeStamp,DocumentID,Obsolete, ".
           "JournalID,Volume,Page,Keywords ".
    "from DocumentRevision ".
    "where DocRevID=? and Obsolete=0");
  if ($DocRevisions{$docRevID}{DOCID} && $DocRevisions{$docRevID}{COMPLETE}) {
    return $DocRevisions{$docRevID}{DOCID};
  }
  $revision_list -> execute($docRevID);
  my ($DocRevID,$SubmitterID,$DocumentTitle,$PublicationInfo,
      $VersionNumber,$Abstract,$RevisionDate,
      $TimeStamp,$DocumentID,$Obsolete,
      $JournalID,$Volume,$Page,$Keywords) = $revision_list -> fetchrow_array;

  #FIXME Make keys mixed-caps
  
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
  $DocRevisions{$DocRevID}{JournalID}     = $JournalID;
  $DocRevisions{$DocRevID}{Volume}        = $Volume;
  $DocRevisions{$DocRevID}{Page}          = $Page;
  $DocRevisions{$DocRevID}{Keywords}      = $Keywords;
  $DocRevisions{$DocRevID}{COMPLETE}      = 1;

  return $DocRevID;
}

sub FetchDocRevision { # Retrieves a revision given the DocumentID and version

  #FIXME: Remove all references to this function, 
  #       use FetchRevisionByDocumentAndVersion

  require "DocumentSQL.pm";

  my ($documentID,$versionNumber) = @_;
  &FetchDocument($documentID);
  my $revision_list = $dbh->prepare(
    "select DocRevID from DocumentRevision ".
    "where DocumentID=? and VersionNumber=? and Obsolete=0");
  if ($DocRevIDs{$documentID}{$versionNumber}) {
    return $DocRevIDs{$documentID}{$versionNumber};
  }
  $revision_list -> execute($documentID,$versionNumber);
  my ($DocRevID) = $revision_list -> fetchrow_array;

  &FetchDocRevisionByID($DocRevID);

  return $DocRevID;
}

sub FetchRevisionByDocumentAndVersion { 
  require "DocumentSQL.pm";

  my ($documentID,$versionNumber) = @_;
  &FetchDocument($documentID);
  my $revision_list = $dbh->prepare(
    "select DocRevID from DocumentRevision ".
    "where DocumentID=? and VersionNumber=? and Obsolete=0");
  if ($DocRevIDs{$documentID}{$versionNumber}) {
    return $DocRevIDs{$documentID}{$versionNumber};
  }
  $revision_list -> execute($documentID,$versionNumber);
  my ($DocRevID) = $revision_list -> fetchrow_array;

  &FetchDocRevisionByID($DocRevID);

  return $DocRevID;
}

sub FetchRevisionsByDocument {
  my ($DocumentID) = @_;
  &FetchDocument($DocumentID);
  my $revision_list = $dbh->prepare(
    "select DocRevID from DocumentRevision where DocumentID=? and Obsolete=0");
  
  my ($DocRevID);
  $revision_list -> execute($DocumentID);
  
  $revision_list -> bind_columns(undef, \($DocRevID));

  my @DocRevList = ();
  while ($revision_list -> fetch) {
    &FetchDocRevisionByID($DocRevID);
    unless ($DocRevisions{$DocRevID}{OBSOLETE}) {
      push @DocRevList,$DocRevID;
    }  
  }
  return @DocRevList;
}

sub GetAllRevisions {
  my ($Mode) = @_;
  unless ($Mode) {$Mode = "brief"};
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,VersionNumber,".
           "RevisionDate,DocumentID,Obsolete ".
    "from DocumentRevision ".
    "where Obsolete=0");
  %DocRevIDs = ();
  %DocRevisions = ();
  $revision_list -> execute;
  $revision_list -> bind_columns(undef, \($DocRevID,$SubmitterID,$DocumentTitle,$VersionNumber,$RevisionDate,$DocumentID,$Obsolete));
  while ($revision_list -> fetch) {
    $DocRevIDs{$DocumentID}{$VersionNumber} = $DocRevID;
    $DocRevisions{$DocRevID}{SUBMITTER}     = $SubmitterID;
    $DocRevisions{$DocRevID}{TITLE}         = $DocumentTitle;
    $DocRevisions{$DocRevID}{DATE}          = $RevisionDate;
    $DocRevisions{$DocRevID}{VERSION}       = $VersionNumber;
    $DocRevisions{$DocRevID}{DOCID}         = $DocumentID;
    $DocRevisions{$DocRevID}{OBSOLETE}      = $Obsolete;
    $DocRevisions{$DocRevID}{COMPLETE}      = 0;
  }
}

1;
