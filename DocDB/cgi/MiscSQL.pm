#
#        Name: MiscSQL.pm 
# Description: Routines to access some of the more uncommon parts of the SQL 
#              database.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

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
  my ($DocTypeID,$ShortType,$LongType);
  my $DocTypeList  = $dbh -> prepare("select DocTypeID,ShortType,LongType from DocumentType");
  %DocumentTypes = ();
  $DocTypeList -> execute;
  $DocTypeList -> bind_columns(undef, \($DocTypeID,$ShortType,$LongType));
  while ($DocTypeList -> fetch) {
    $DocumentTypes{$DocTypeID}{SHORT}     = $ShortType;
    $DocumentTypes{$DocTypeID}{LONG}      = $LongType;
  }
};

sub FetchDocType ($) { # Fetches an DocumentType by ID, adds to $DocumentTypes{$DocTypeID}{}
  my ($DocTypeID) = @_;
  my ($ShortType,$LongType);

  my $DocTypeFetch  = $dbh -> prepare(
     "select ShortType,LongType from DocumentType where DocTypeID=?");
  if ($DocumentTypes{$DocTypeID}{SHORT}) { # We already have this one
    return $DocumentTypes{$DocTypeID}{SHORT};
  }
  
  $DocTypeFetch -> execute($DocTypeID);
  ($ShortType,$LongType) = $DocTypeFetch -> fetchrow_array;
  $DocumentTypes{$DocTypeID}{SHORT}     = $ShortType;
  $DocumentTypes{$DocTypeID}{LONG}      = $LongType;
  
  return $DocumentTypes{$DocTypeID}{SHORT};
}

sub FetchDocTypeByName ($) { # Fetches an DocumentType by ID, adds to $DocumentTypes{$DocTypeID}{}
  my ($Name) = @_;
  
  my $Select = $dbh -> prepare("select DocTypeID from DocumentType where lower(ShortType) like lower(?)");
  $Select -> execute($Name);
  my ($DocTypeID) = $Select -> fetchrow_array;
  
  if ($DocTypeID) {
    &FetchDocType($DocTypeID);
  } else {
    return 0;
  }  
  return $DocTypeID;
}

sub FetchDocFiles ($) {
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
    $DocFiles{$DocFileID}{TimeStamp}   = $TimeStamp;
    $DocFiles{$DocFileID}{DOCREVID}    = $DocRevID;
  }
  return @{$Files{$DocRevID}};
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

sub FetchFile ($) {
  my ($DocFileID) = @_;
  
  my $FileList = $dbh->prepare(
    "select FileName,Date,RootFile,TimeStamp,Description,DocRevID ".
    "from DocumentFile where DocFileID=?");
  if ($DocFiles{$DocFileID}) {
    return $DocFiles{$DocFileID}{NAME}; 
  }
  $FileList -> execute($DocFileID);
  $FileList -> bind_columns(undef, \($FileName,$Date,$RootFile,$TimeStamp,$Description,$DocRevID));
  while ($FileList -> fetch) {
    $DocFiles{$DocFileID}{NAME}        = $FileName;
    $DocFiles{$DocFileID}{ROOT}        = $RootFile;
    $DocFiles{$DocFileID}{DESCRIPTION} = $Description;
    $DocFiles{$DocFileID}{TimeStamp}   = $TimeStamp;
    $DocFiles{$DocFileID}{DOCREVID}    = $DocRevID;
  }
  return $FileName;
}


1;
