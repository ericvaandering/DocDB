sub GetJournals { # Creates/fills a hash $Journals{$JournalID}{} 
  my ($JournalID,$Acronym,$Abbreviation,$Name,$Publisher,$URL,$TimeStamp);                
  my $JournalQuery  = $dbh -> prepare(
     "select JournalID,Acronym,Abbreviation,Name,Publisher,URL,TimeStamp "
    ."from Journal");
  %Journals = ();
  $JournalQuery -> execute;
  $JournalQuery -> bind_columns(undef, \($JournalID,$Acronym,$Abbreviation,$Name,$Publisher,$URL,$TimeStamp));
  while ($JournalQuery -> fetch) {
    $Journals{$JournalID}{JournalID}     = $JournalID;
    $Journals{$JournalID}{Acronym}       = $Acronym;
    $Journals{$JournalID}{Abbreviation}  = $Abbreviation;
    $Journals{$JournalID}{Name}          = $Name;
    $Journals{$JournalID}{Publisher}     = $Publisher;
    $Journals{$JournalID}{URL}           = $URL;
    $Journals{$JournalID}{TimeStamp}     = $TimeStamp;
  }
};

sub FetchReferencesByRevision ($) {
  my ($DocRevID) = @_;
  
  my ($ReferenceID,$JournalID,$Volume,$Page,$TimeStamp);
  my @ReferenceIDs = ();
  
  my $ReferenceList = $dbh -> prepare(
   "select ReferenceID,JournalID,Volume,Page,TimeStamp ".
   "from RevisionReference where DocRevID=?");
  $ReferenceList -> execute($DocRevID);
  $ReferenceList -> bind_columns(undef,\($ReferenceID,$JournalID,$Volume,$Page,$TimeStamp));
  while ($ReferenceList -> fetch) {
    $RevisionReferences{$ReferenceID}{JournalID} = $JournalID;
    $RevisionReferences{$ReferenceID}{Volume}    = $Volume;
    $RevisionReferences{$ReferenceID}{Page}      = $Page;
    $RevisionReferences{$ReferenceID}{TimeStamp} = $TimeStamp;
    push @ReferenceIDs,$ReferenceID;
  }
  return @ReferenceIDs;
};

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
    return @{$Files{$docRevID}};  # Caching not working for some reason
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
  return @{$Files{$DocRevID}};
}

sub GetConferences {
  my ($MinorTopicID);
  my ($MajorID) = @ConferenceMajorIDs;
  my $minor_list   = $dbh -> prepare(
    "select MinorTopicID from MinorTopic where MajorTopicID=$MajorID");
  $minor_list -> execute();
  $minor_list -> bind_columns(undef, \($MinorTopicID));
  while ($minor_list -> fetch) {
    &FetchConferenceByTopicID($MinorTopicID);
  }
}

sub FetchConferenceByTopicID { # Fetches a conference by MinorTopicID
  my ($minorTopicID) = @_;
  my ($ConferenceID,$MinorTopicID,$Location,$URL,$StartDate,$EndDate,$TimeStamp);
  my $conference_fetch   = $dbh -> prepare(
    "select ConferenceID,MinorTopicID,Location,URL,StartDate,EndDate,TimeStamp ".
    "from Conference ".
    "where MinorTopicID=?");
  if ($Conference{$minorTopicID}{MINOR}) { # We already have this one
    return $Conference{$minorTopicID}{MINOR};
  }
  
  &FetchMinorTopic($minorTopicID);
  $conference_fetch -> execute($minorTopicID);
  ($ConferenceID,$MinorTopicID,$Location,$URL,$StartDate,$EndDate,$TimeStamp) 
    = $conference_fetch -> fetchrow_array;
  $Conferences{$MinorTopicID}{MINOR}      = $MinorTopicID;
  $Conferences{$MinorTopicID}{LOCATION}   = $Location;
  $Conferences{$MinorTopicID}{URL}        = $URL;
  $Conferences{$MinorTopicID}{STARTDATE}  = $StartDate;
  $Conferences{$MinorTopicID}{ENDDATE}    = $EndDate;
  $Conferences{$MinorTopicID}{TIMESTAMP}  = $TimeStamp;

  return $Conferences{$MinorTopicID}{MINOR};
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
