sub GetAuthors {
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName);
  my $people_list  = $dbh->prepare("select AuthorID,FirstName,MiddleInitials,LastName,Active from Author order by LastName");
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active));
  while ($people_list -> fetch) {
    if ($Active) {
      $names{$AuthorID} = "$FirstName $MiddleInitials $LastName";
    }
  }
};

sub GetTopics {
  my $minor_list   = $dbh->prepare("select MinorTopicID,MajorTopicID,ShortDescription,LongDescription from MinorTopic");
  my $major_list   = $dbh->prepare("select MajorTopicID,ShortDescription,LongDescription from MajorTopic");
  $major_list -> execute;
  $major_list -> bind_columns(undef, \($MajorTopicID,$ShortDescription,$LongDescription));
  while ($major_list -> fetch) {
    $major_topics{$MajorTopicID}{SHORT} = $ShortDescription;
    $major_topics{$MajorTopicID}{LONG}  = $LongDescription;
  }

  my ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription);
  $minor_list -> execute;
  $minor_list -> bind_columns(undef, \($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription));
  while ($minor_list -> fetch) {
    $minor_topics{$MinorTopicID}{MAJOR} = $MajorTopicID;
    $minor_topics{$MinorTopicID}{SHORT} = $ShortDescription;
    $minor_topics{$MinorTopicID}{LONG}  = $LongDescription;
    $minor_topics{$MinorTopicID}{FULL}  = $major_topics{$MajorTopicID}{SHORT}.":".$ShortDescription;
  }
  foreach $key (keys %minor_topics) {
    $full_topics{$key} =  $minor_topics{$key}{FULL};
  }
};

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
}

sub FetchDocRevision {
  # Creates two hashes:
  # $DocRevIDs{DocumentID}{Version} holds the DocumentRevision ID
  # $DocRevisions{DocRevID}{FIELD} holds the Fields or references too them

  my ($documentID,$versionNumber) = @_;
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,Security,TimeStamp ".
    "from DocumentRevision ".
    "where DocumentID=? and VersionNumber=?");
  if ($DocRevIDs{$documentID}{$versionNumber}) {
    return $DocRevIDs{$documentID}{$versionNumber};
  }
  $revision_list -> execute($documentID,$versionNumber);
  my ($DocRevID,$SubmitterID,$DocumentTitle,$PublicationInfo,$VersionNumber,
      $Abstract,$RevisionDate,$Security) = $revision_list -> fetchrow_array;

  $DocRevIDs{$documentID}{$versionNumber} = $DocRevID;
  $DocRevisions{$DocRevID}{SUBMITTER}    = $SubmitterID;
  $DocRevisions{$DocRevID}{TITLE}    = $DocumentTitle;
  $DocRevisions{$DocRevID}{PUBINFO}     = $PublicationInfo;
  $DocRevisions{$DocRevID}{ABSTRACT} = $Abstract;
  $DocRevisions{$DocRevID}{DATE}     = $RevisionDate;
  @{$DocRevisions{$DocRevID}{SECURITY}} = split /\,/,$Security;

  return $DocRevID;
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
1;
