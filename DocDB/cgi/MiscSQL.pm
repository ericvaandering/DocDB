sub GetDocTypes { # Creates/fills a hash $DocumentTypes{$DocTypeID}{} 
#  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active);
#  my $people_list  = $dbh -> prepare(
#     "select AuthorID,FirstName,MiddleInitials,LastName,Active from Author"); 
#  $people_list -> execute;
#  $people_list -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active));
#  %Authors = ();
#  while ($people_list -> fetch) {
#    $Authors{$AuthorID}{AUTHORID} =  $AuthorID;
#    $Authors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
#    $Authors{$AuthorID}{LASTNAME} =  $LastName;
#    $Authors{$AuthorID}{ACTIVE}   =  $Active;
#    if ($Active) {
#      $ActiveAuthors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
#      $names{$AuthorID}                   = "$FirstName $MiddleInitials $LastName"; # FIXME
#    }
#  }
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

  my ($DocRevID) = @_;
  my ($DocFileID,$FileName,$Date,$RootFile,$TimeStamp,$Description);
  my $file_list = $dbh->prepare(
    "select DocFileID,FileName,Date,RootFile,TimeStamp,Description ".
    "from DocumentFile where DocRevID=?");
  if ($Files{$DocRevID}) {
    return $Files{$DocRevID};
  }
  $file_list -> execute($DocRevID);
  $file_list -> bind_columns(undef, \($DocFileID,$FileName,$Date,$RootFile,$TimeStamp,$Description));
  while ($file_list -> fetch) {
    push @{ $Files{$DocRevID} },$DocFileID;
    $DocFiles{$DocFileID}{NAME}        = $FileName;
    $DocFiles{$DocFileID}{ROOT}        = $RootFile;
    $DocFiles{$DocFileID}{DESCRIPTION} = $Description;
    $DocFiles{$DocFileID}{TIMESTAMP}   = $TimeStamp;
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

1;
