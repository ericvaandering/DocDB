sub FetchDocRevisionByID {

  # FIXME Change name to FetchDocumentRevision
  # FIXME Doesn't fetch obsolete revisions. Can't see why this would hurt. Investigate
  # Creates two hashes:
  # $DocRevIDs{DocumentID}{Version} holds the DocumentRevision ID
  # $DocRevisions{DocRevID}{FIELD} holds the Fields or references too them

  my ($docRevID) = @_;
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,TimeStamp,DocumentID,Obsolete, ".
           "Keywords ".
    "from DocumentRevision ".
    "where DocRevID=? and Obsolete=0");
  if ($DocRevisions{$docRevID}{DOCID} && $DocRevisions{$docRevID}{COMPLETE}) {
    return $DocRevisions{$docRevID}{DOCID};
  }
  $revision_list -> execute($docRevID);
  my ($DocRevID,$SubmitterID,$DocumentTitle,$PublicationInfo,
      $VersionNumber,$Abstract,$RevisionDate,
      $TimeStamp,$DocumentID,$Obsolete,
      $Keywords) = $revision_list -> fetchrow_array;


  #FIXME Make keys mixed-caps
  
  $DocRevIDs{$DocumentID}{$VersionNumber} = $DocRevID;
  $DocRevisions{$DocRevID}{SUBMITTER}     = $SubmitterID;
  $DocRevisions{$DocRevID}{TITLE}         = $DocumentTitle;
  $DocRevisions{$DocRevID}{PUBINFO}       = $PublicationInfo;
  $DocRevisions{$DocRevID}{ABSTRACT}      = $Abstract;
  $DocRevisions{$DocRevID}{DATE}          = $RevisionDate;
  $DocRevisions{$DocRevID}{TimeStamp}     = $TimeStamp;
  $DocRevisions{$DocRevID}{VERSION}       = $VersionNumber; # FIXME: BWC
  $DocRevisions{$DocRevID}{Version}       = $VersionNumber;
  $DocRevisions{$DocRevID}{DOCID}         = $DocumentID;
  $DocRevisions{$DocRevID}{OBSOLETE}      = $Obsolete;
  $DocRevisions{$DocRevID}{Keywords}      = $Keywords;
  $DocRevisions{$DocRevID}{COMPLETE}      = 1;

### Find earliest instance this document for content modification date

  my $EarliestVersionQuery = $dbh->prepare(
    "select DocRevID,RevisionDate ".
    "from DocumentRevision ".
    "where DocumentID=? and VersionNumber=? order by DocRevID");
  $EarliestVersionQuery -> execute($DocumentID,$VersionNumber);
  
### Pull off first one  
  
  my (undef,$VersionDate) = $EarliestVersionQuery -> fetchrow_array;
  $DocRevisions{$DocRevID}{VersionDate}   = $VersionDate;

  return $DocRevID;
}

sub FetchRevisionByDocumentAndVersion ($$) { 
  require "DocumentSQL.pm";

  my ($DocumentID,$VersionNumber) = @_;
  &FetchDocument($DocumentID);
  my $RevisionQuery = $dbh->prepare(
    "select DocRevID from DocumentRevision ".
    "where DocumentID=? and VersionNumber=? and Obsolete=0");
  if ($DocRevIDs{$DocumentID}{$VersionNumber}) {
    return $DocRevIDs{$DocumentID}{$VersionNumber};
  }
  $RevisionQuery -> execute($DocumentID,$VersionNumber);
  my ($DocRevID) = $RevisionQuery -> fetchrow_array;

  &FetchDocRevisionByID($DocRevID);

  return $DocRevID;
}

sub FetchRevisionByDocumentAndDate ($$) { 
  require "DocumentSQL.pm";

  my ($DocumentID,$Date) = @_;
  &FetchDocument($DocumentID);
  my $RevisionQuery = $dbh -> prepare(
    "select MAX(VersionNumber) from DocumentRevision ".
    "where DocumentID=? and RevisionDate<=?");

  $Date .= " 23:59:59";
  $RevisionQuery -> execute($DocumentID,$Date);
  my ($Version) = $RevisionQuery -> fetchrow_array;

  my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);

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
  unless ($Mode) {$Mode = "brief"}; # Other modes not implemented yet
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
    $DocRevisions{$DocRevID}{VERSION}       = $VersionNumber; # FIXME: BWC
    $DocRevisions{$DocRevID}{Version}       = $VersionNumber;
    $DocRevisions{$DocRevID}{DOCID}         = $DocumentID;
    $DocRevisions{$DocRevID}{OBSOLETE}      = $Obsolete;
    $DocRevisions{$DocRevID}{COMPLETE}      = 0;
  }
}

1;
