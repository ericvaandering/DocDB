sub GetDocTypes { # Creates/fills a hash $DocumentTypes{$DocTypeID}{} 
  my $doctype_list  = $dbh -> prepare(
     "select DocTypeID,ShortType,LongType from DocumentType");
  %DocumentTypes = ();
  $doctype_list -> execute;
  $doctype_list -> bind_columns(undef, \($DocTypeID,$ShortType,$LongType));
  while ($doctype_list -> fetch) {
    $DocumentTypes{$DocTypeID}{DOCTYPEID} = $DocTypeID;
    $DocumentTypes{$DocTypeID}{SHORT}     = $ShortType;
    $DocumentTypes{$DocTypeID}{LONG}      = $LongType;
  }
};

sub FetchDocType { # Fetches an DocumentType by ID, adds to $DocumentTypes{$DocTypeID}{}
  my ($docTypeID) = @_;
  my ($DocTypeID,$ShortType,$LongType);

  my $type_fetch  = $dbh -> prepare(
     "select DocTypeID,ShortType,LongType ". 
     "from DocumentType ". 
     "where DocTypeID=?");
  if ($DocumentTypes{$docTypeID}{DOCTYPEID}) { # We already have this one
    return $DocumentTypes{$docTypeID}{SHORT};
  }
  
  $type_fetch -> execute($docTypeID);
  ($DocTypeID,$ShortType,$LongType) = $type_fetch -> fetchrow_array;
  $DocumentTypes{$docTypeID}{DOCTYPEID} = $DocTypeID;
  $DocumentTypes{$docTypeID}{SHORT}     = $ShortType;
  $DocumentTypes{$docTypeID}{LONG}      = $LongType;
  
  return $DocumentTypes{$DocTypeID}{SHORT};
}

sub FetchDocFiles {
  # Creates two hashes:
  # $Files{DocRevID}           holds the list of file IDs for a given DocRevID
  # $DocFiles{DocFileID}{FIELD} holds the Fields or references too them

  my ($docRevID) = @_;
  my ($DocFileID,$FileName,$Date,$RootFile,$TimeStamp,$Description,$DocRevID);
  my $file_list = $dbh->prepare(
    "select DocFileID,FileName,Date,RootFile,TimeStamp,Description,DocRevID ".
    "from DocumentFile where DocRevID=?");
  if ($Files{$docRevID}) {
    return $Files{$docRevID};
  }
  $file_list -> execute($docRevID);
  $file_list -> bind_columns(undef, \($DocFileID,$FileName,$Date,$RootFile,$TimeStamp,$Description,$DocRevID));
  while ($file_list -> fetch) {
    push @{ $Files{$DocRevID} },$DocFileID;
    $DocFiles{$DocFileID}{NAME}        = $FileName;
    $DocFiles{$DocFileID}{ROOT}        = $RootFile;
    $DocFiles{$DocFileID}{DESCRIPTION} = $Description;
    $DocFiles{$DocFileID}{TIMESTAMP}   = $TimeStamp;
    $DocFiles{$DocFileID}{DOCREVID}    = $DocRevID;
  }
  return $Files{$DocRevID};
}

sub VersionNumbersByDocID {
  my ($DocumentID) = @_;
  my @DocRevList = &FetchRevisionsByDocument($DocumentID);
  foreach my $DocRevID (@DocRevList) {
    push @VersionList,$DocRevisions{$DocRevID}{VERSION};
  }
  return @VersionList;
} 

sub ExistsUpload($$) {
  require "FSUtilities.pm";
  
  my ($DocRevID,$short_file) = @_;

  if (grep /\\/,$short_file) {
    $short_file = &WindowsBaseFile($short_file);
  }  
  if (grep /\//,$short_file) {
    $short_file = &UnixBaseFile($short_file);
  }  

  my $status = &ExistsFile($DocRevID,$short_file);
  return $status;
}

sub ExistsURL($$) {
  my ($DocRevID,$url) = @_;
  
  my @url_parts = split /\//,$url;
  my $short_file = pop @url_parts;

  my $status = &ExistsFile($DocRevID,$short_file);
  return $status;
}

sub ExistsFile($$) {
  my ($DocRevID,$File) = @_;

  $File =~ s/^\s+//;
  $File =~ s/\s+$//;

  my $file_select = $dbh -> prepare(
   "select DocFileID from DocumentFile where DocRevID=? and FileName=?");

  $file_select -> execute($DocRevID,$File);
  ($DocFileID) = $file_select -> fetchrow_array;

  if ($DocFileID) {
    return 1;
  } else {
    return 0;
  }    
}

1;
