sub GetAuthors { # Creates/fills a hash $Authors{$AuthorID}{} with all authors
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active);
  my $people_list  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active from Author"); 
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active));
  %Authors = ();
  while ($people_list -> fetch) {
    $Authors{$AuthorID}{AUTHORID} =  $AuthorID;
    $Authors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
    $Authors{$AuthorID}{LASTNAME} =  $LastName;
    $Authors{$AuthorID}{ACTIVE}   =  $Active;
    if ($Active) {
      $ActiveAuthors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
      $names{$AuthorID}                   = "$FirstName $MiddleInitials $LastName"; # FIXME
    }
  }
};

sub GetInstitutions { # Creates/fills a hash $Institutions{$InstitutionID}{} with all Institutions
  my ($InstitutionID,$ShortName,$LongName);
  my $inst_list  = $dbh -> prepare(
     "select InstitutionID,ShortName,LongName from Institution"); 
  $inst_list -> execute;
  $inst_list -> bind_columns(undef, \($InstitutionID,$ShortName,$LongName));
  %Institutions = ();
  while ($inst_list -> fetch) {
    $Institutions{$InstitutionID}{INSTID} =  $InstitutionID;
    $Institutions{$InstitutionID}{SHORT} = $ShortName;
    $Institutions{$InstitutionID}{LONG} =  $LongName;
  }
};

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

sub FetchAuthor { # Fetches an Author by ID, adds to $Authors{$AuthorID}{}
  my ($authorID) = @_;
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active);

  my $author_fetch  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active ". 
     "from Author ". 
     "where AuthorID=?");
  if ($Authors{$authorID}{AUTHORID}) { # We already have this one
    return $Authors{$authorID}{AUTHORID};
  }
  
  $author_fetch -> execute($authorID);
  ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active) = $author_fetch -> fetchrow_array;
  $Authors{$AuthorID}{AUTHORID} =  $AuthorID;
  $Authors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
  $Authors{$AuthorID}{LASTNAME} =  $LastName;
  $Authors{$AuthorID}{ACTIVE}   =  $Active;
  
  return $Authors{$AuthorID}{AUTHORID};
}

sub GetTopics {
  my $minor_list   = $dbh->prepare("select MinorTopicID,MajorTopicID,ShortDescription,LongDescription from MinorTopic");
  my $major_list   = $dbh->prepare("select MajorTopicID,ShortDescription,LongDescription from MajorTopic");

  %MinorTopics = ();
  %MajorTopics = ();
  %FullTopics  = ();

  $major_list -> execute;
  $major_list -> bind_columns(undef, \($MajorTopicID,$ShortDescription,$LongDescription));
  while ($major_list -> fetch) {
    $MajorTopics{$MajorTopicID}{MAJOR} = $MajorTopicID;
    $MajorTopics{$MajorTopicID}{SHORT} = $ShortDescription;
    $MajorTopics{$MajorTopicID}{LONG}  = $LongDescription;
  }

  my ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription);
  $minor_list -> execute;
  $minor_list -> bind_columns(undef, \($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription));
  while ($minor_list -> fetch) {
    $MinorTopics{$MinorTopicID}{MINOR} = $MinorTopicID;
    $MinorTopics{$MinorTopicID}{MAJOR} = $MajorTopicID;
    $MinorTopics{$MinorTopicID}{SHORT} = $ShortDescription;
    $MinorTopics{$MinorTopicID}{LONG}  = $LongDescription;
    $MinorTopics{$MinorTopicID}{FULL}  = $MajorTopics{$MajorTopicID}{SHORT}.":".$ShortDescription;
  }
  foreach $key (keys %MinorTopics) {
    $FullTopics{$key} =  $MinorTopics{$key}{FULL};
  }
};

sub FetchMinorTopic { # Fetches an MinorTopic by ID, adds to $Topics{$TopicID}{}
  my ($minorTopicID) = @_;
  my ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription);
  my $minor_fetch   = $dbh -> prepare(
    "select MinorTopicID,MajorTopicID,ShortDescription,LongDescription ".
    "from MinorTopic ".
    "where MinorTopicID=?");
  if ($MinorTopics{$minorTopicID}{MINOR}) { # We already have this one
    return $MinorTopics{$minorTopicID}{MINOR};
  }
  
  $minor_fetch -> execute($minorTopicID);
  ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription) = $minor_fetch -> fetchrow_array;
  &FetchMajorTopic($MajorTopicID);
  $MinorTopics{$MinorTopicID}{MINOR} = $MinorTopicID;
  $MinorTopics{$MinorTopicID}{MAJOR} = $MajorTopicID;
  $MinorTopics{$MinorTopicID}{SHORT} = $ShortDescription;
  $MinorTopics{$MinorTopicID}{LONG}  = $LongDescription;
  $MinorTopics{$MinorTopicID}{FULL}  = $MajorTopics{$MajorTopicID}{SHORT}.":".$ShortDescription;

  $FullTopics{$MinorTopicID} = $MinorTopics{$MinorTopicID}{FULL};

  return $MinorTopics{$MinorTopicID}{MINOR};
}

sub FetchMajorTopic { # Fetches an MajorTopic by ID, adds to $Topics{$TopicID}{}
  my ($majorTopicID) = @_;
  my ($MajorTopicID,$ShortDescription,$LongDescription);
  my $major_fetch   = $dbh -> prepare(
    "select MajorTopicID,ShortDescription,LongDescription ".
    "from MajorTopic ".
    "where MajorTopicID=?");
  if ($MajorTopics{$majorTopicID}{MAJOR}) { # We already have this one
    return $MajorTopics{$majorTopicID}{MAJOR};
  }

  $major_fetch -> execute($majorTopicID);
  ($MajorTopicID,$ShortDescription,$LongDescription) = $major_fetch -> fetchrow_array;
  $MajorTopics{$MajorTopicID}{MAJOR} = $MajorTopicID;
  $MajorTopics{$MajorTopicID}{SHORT} = $ShortDescription;
  $MajorTopics{$MajorTopicID}{LONG}  = $LongDescription;

  return $MajorTopics{$MajorTopicID}{MAJOR};
}

sub GetSecurities {
  my ($field,$type);
  my $security_list = $dbh->prepare("describe DocumentRevision Security");
  $security_list -> execute;
  $security_list -> bind_columns(undef, \($field,$type,$Null,$Key,$Default,$Extra));
  $security_list -> fetch;
  my $set_values = $type;

  $set_values =~ s/set\(//g; # Parse out everything but the types
  $set_values =~ s/\)//g;
  $set_values =~ s/\'//g;
  $set_values =~ s/\s+//g;
  
  (@available_securities) = ("Public",split /\,/,$set_values);
};

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

sub FetchDocRevision {
  # Creates two hashes:
  # $DocRevIDs{DocumentID}{Version} holds the DocumentRevision ID
  # $DocRevisions{DocRevID}{FIELD} holds the Fields or references too them

  my ($documentID,$versionNumber) = @_;
  &FetchDocument($documentID);
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,Security,TimeStamp,DocumentID ".
    "from DocumentRevision ".
    "where DocumentID=? and VersionNumber=?");
  if ($DocRevIDs{$documentID}{$versionNumber}) {
    return $DocRevIDs{$documentID}{$versionNumber};
  }
  $revision_list -> execute($documentID,$versionNumber);
  my ($DocRevID,$SubmitterID,$DocumentTitle,$PublicationInfo,
      $VersionNumber,$Abstract,$RevisionDate,$Security,
      $TimeStamp,$DocumentID) = $revision_list -> fetchrow_array;

  $DocRevIDs{$documentID}{$versionNumber} = $DocRevID;
  $DocRevisions{$DocRevID}{SUBMITTER}    = $SubmitterID;
  $DocRevisions{$DocRevID}{TITLE}    = $DocumentTitle;
  $DocRevisions{$DocRevID}{PUBINFO}     = $PublicationInfo;
  $DocRevisions{$DocRevID}{ABSTRACT} = $Abstract;
  $DocRevisions{$DocRevID}{DATE}     = $RevisionDate;
  $DocRevisions{$DocRevID}{TIMESTAMP}     = $TimeStamp;
  $DocRevisions{$DocRevID}{VERSION}     = $VersionNumber;
  $DocRevisions{$DocRevID}{DOCID}     = $DocumentID;
  @{$DocRevisions{$DocRevID}{SECURITY}} = split /\,/,$Security;

  return $DocRevID;
}

sub FetchRevisionsByDocument {
  my ($DocumentID) = @_;
  &FetchDocument($DocumentID);
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,Security,TimeStamp,DocumentID ".
    "from DocumentRevision ".
    "where DocumentID=?");
  $revision_list -> execute($DocumentID);
  
  $revision_list -> bind_columns(undef, \($DocRevID,$SubmitterID,$DocumentTitle,
                                          $PublicationInfo,$VersionNumber,$Abstract,
                                          $RevisionDate,$Security,$TimeStamp,$DocumentID));
  my @DocRevList = ();
  while ($revision_list -> fetch) {
    if ($DocRevisions{$DocRevID}{DOCID}) {
      push @DocRevList,$DocRevID;
      next; # We did this one already
    } 

    $DocRevIDs{$DocumentID}{$VersionNumber} = $DocRevID;
    $DocRevisions{$DocRevID}{SUBMITTER}    = $SubmitterID;
    $DocRevisions{$DocRevID}{TITLE}    = $DocumentTitle;
    $DocRevisions{$DocRevID}{PUBINFO}     = $PublicationInfo;
    $DocRevisions{$DocRevID}{ABSTRACT} = $Abstract;
    $DocRevisions{$DocRevID}{DATE}     = $RevisionDate;
    $DocRevisions{$DocRevID}{TIMESTAMP}     = $TimeStamp;
    $DocRevisions{$DocRevID}{VERSION}     = $VersionNumber;
    $DocRevisions{$DocRevID}{DOCID}     = $DocumentID;
    @{$DocRevisions{$DocRevID}{SECURITY}} = split /\,/,$Security;
    push @DocRevList,$DocRevID;
  }
  
  return @DocRevList;

}

sub FetchDocFiles {
  # Creates two hashes:
  # $Files{DocRevID}           holds the list of file IDs for a given DocRevID
  # $DocFiles{DocFileID}{FIELD} holds the Fields or references too them

  my ($DocRevID) = @_;
  my $file_list = $dbh->prepare(
    "select DocFileID,FileName,Date,RootFile,TimeStamp ".
    "from DocumentFile where DocRevID=?");
  if ($Files{$DocRevID}) {
    return $Files{$DocRevID};
  }
  $file_list -> execute($DocRevID);
  $file_list -> bind_columns(undef, \($DocFileID,$FileName,$Date,$RootFile,$TimeStamp));
  while ($file_list -> fetch) {
    push @{ $Files{$DocRevID} },$DocFileID;
    $DocFiles{$DocFileID}{NAME} = $FileName;
    $DocFiles{$DocFileID}{ROOT} = $RootFile;
  }
  return $Files{$DocRevID};
}

sub GetRevisionAuthors {
  my ($DocRevID) = @_;
  my @authors = ();
  my $author_list = $dbh->prepare(
    "select RevAuthorID,AuthorID from RevisionAuthor where DocRevID=?");
  $author_list -> execute($DocRevID);
  $author_list -> bind_columns(undef, \($RevAuthorID,$AuthorID));
  while ($author_list -> fetch) {
    push @authors,$AuthorID;
  }
  return \@authors;  
}

sub GetRevisionTopics {
  my ($DocRevID) = @_;
  my @topics = ();
  my $topic_list = $dbh->prepare(
    "select RevTopicID,MinorTopicID from RevisionTopic where DocRevID=?");
  $topic_list -> execute($DocRevID);
  $topic_list -> bind_columns(undef, \($RevTopicID,$MinorTopicID));
  while ($topic_list -> fetch) {
    push @topics,$MinorTopicID;
  }
  return \@topics;
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
