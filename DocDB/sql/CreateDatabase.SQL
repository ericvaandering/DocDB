-- This file creates the database structure for a Version 6.x installation of 
-- DocDB.

--
-- Table structure for table `Author`
--

CREATE TABLE Author (
  AuthorID int(11) NOT NULL auto_increment,
  FirstName varchar(32) NOT NULL default '',
  MiddleInitials varchar(16) default NULL,
  LastName varchar(32) NOT NULL default '',
  InstitutionID int(11) NOT NULL default '0',
  Active int(11) default '1',
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (AuthorID),
  KEY Name (LastName)
) TYPE=MyISAM;

--
-- Dumping data for table `Author`
--



--
-- Table structure for table `AuthorHint`
--

CREATE TABLE AuthorHint (
  AuthorHintID int(11) NOT NULL auto_increment,
  SessionTalkID int(11) default NULL,
  AuthorID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (AuthorHintID),
  KEY SessionTalkID (SessionTalkID)
) TYPE=MyISAM;

--
-- Dumping data for table `AuthorHint`
--



--
-- Table structure for table `Conference`
--

CREATE TABLE Conference (
  ConferenceID int(11) NOT NULL auto_increment,
  MinorTopicID int(11) NOT NULL default '0',
  Location varchar(64) NOT NULL default '',
  URL varchar(240) default NULL,
  StartDate date default NULL,
  EndDate date default NULL,
  TimeStamp timestamp(14) NOT NULL,
  Preamble text,
  Title varchar(128) default NULL,
  Epilogue text,
  ShowAllTalks int(11) default NULL,
  SingleSession int(11) NOT NULL default '0',
  PRIMARY KEY  (ConferenceID)
) TYPE=MyISAM;

--
-- Dumping data for table `Conference`
--



--
-- Table structure for table `DocXRef`
--

CREATE TABLE DocXRef (
  DocXRefID int(11) NOT NULL auto_increment,
  DocRevID int(11) default NULL,
  DocumentID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (DocXRefID),
  KEY DocRevID (DocRevID),
  KEY DocumentID (DocumentID)
) TYPE=MyISAM;

--
-- Dumping data for table `DocXRef`
--



--
-- Table structure for table `Document`
--

CREATE TABLE Document (
  DocumentID int(11) NOT NULL auto_increment,
  RequesterID int(11) NOT NULL default '0',
  RequestDate datetime default NULL,
  DocumentType int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (DocumentID),
  KEY Requester (RequesterID)
) TYPE=MyISAM;

--
-- Dumping data for table `Document`
--



--
-- Table structure for table `DocumentFile`
--

CREATE TABLE DocumentFile (
  DocFileID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL default '0',
  FileName varchar(255) NOT NULL default '',
  Date datetime default NULL,
  RootFile tinyint(4) default '1',
  TimeStamp timestamp(14) NOT NULL,
  Description varchar(128) default NULL,
  PRIMARY KEY  (DocFileID),
  KEY DocRevID (DocRevID)
) TYPE=MyISAM;

--
-- Dumping data for table `DocumentFile`
--



--
-- Table structure for table `DocumentRevision`
--

CREATE TABLE DocumentRevision (
  DocRevID int(11) NOT NULL auto_increment,
  DocumentID int(11) NOT NULL default '0',
  SubmitterID int(11) NOT NULL default '0',
  DocumentTitle varchar(255) NOT NULL default '',
  PublicationInfo text,
  VersionNumber int(11) NOT NULL default '0',
  Abstract text,
  RevisionDate datetime default NULL,
  TimeStamp timestamp(14) NOT NULL,
  Obsolete tinyint(4) default '0',
  Keywords varchar(240) default NULL,
  Note text,
  Demanaged int(11) default NULL,
  PRIMARY KEY  (DocRevID),
  KEY DocumentID (DocumentID),
  KEY DocumentTitle (DocumentTitle),
  KEY VersionNumber (VersionNumber)
) TYPE=MyISAM;

--
-- Dumping data for table `DocumentRevision`
--



--
-- Table structure for table `DocumentType`
--

CREATE TABLE DocumentType (
  DocTypeID int(11) NOT NULL auto_increment,
  ShortType varchar(32) default NULL,
  LongType varchar(255) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  Hide int(11) NOT NULL default '0',
  PRIMARY KEY  (DocTypeID)
) TYPE=MyISAM;

--
-- Dumping data for table `DocumentType`
--



--
-- Table structure for table `EmailAuthorDaily`
--

CREATE TABLE EmailAuthorDaily (
  AuthorDailyID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  AuthorID int(11) NOT NULL default '0',
  PRIMARY KEY  (AuthorDailyID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailAuthorDaily`
--



--
-- Table structure for table `EmailAuthorImmediate`
--

CREATE TABLE EmailAuthorImmediate (
  AuthorImmediateID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  AuthorID int(11) NOT NULL default '0',
  PRIMARY KEY  (AuthorImmediateID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailAuthorImmediate`
--



--
-- Table structure for table `EmailAuthorWeekly`
--

CREATE TABLE EmailAuthorWeekly (
  AuthorWeeklyID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  AuthorID int(11) NOT NULL default '0',
  PRIMARY KEY  (AuthorWeeklyID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailAuthorWeekly`
--



--
-- Table structure for table `EmailDocumentImmediate`
--

CREATE TABLE EmailDocumentImmediate (
  EmailDocumentImmediateID int(11) NOT NULL auto_increment,
  EmailUserID int(11) default NULL,
  DocumentID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (EmailDocumentImmediateID),
  KEY EmailUserID (EmailUserID),
  KEY DocumentID (DocumentID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailDocumentImmediate`
--



--
-- Table structure for table `EmailKeywordDaily`
--

CREATE TABLE EmailKeywordDaily (
  KeywordDailyID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  Keyword varchar(32) default NULL,
  PRIMARY KEY  (KeywordDailyID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailKeywordDaily`
--



--
-- Table structure for table `EmailKeywordImmediate`
--

CREATE TABLE EmailKeywordImmediate (
  KeywordImmediateID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  Keyword varchar(32) default NULL,
  PRIMARY KEY  (KeywordImmediateID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailKeywordImmediate`
--



--
-- Table structure for table `EmailKeywordWeekly`
--

CREATE TABLE EmailKeywordWeekly (
  KeywordWeeklyID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  Keyword varchar(32) default NULL,
  PRIMARY KEY  (KeywordWeeklyID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailKeywordWeekly`
--



--
-- Table structure for table `EmailTopicDaily`
--

CREATE TABLE EmailTopicDaily (
  DailyEmailID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  MajorTopicID int(11) NOT NULL default '0',
  MinorTopicID int(11) NOT NULL default '0',
  PRIMARY KEY  (DailyEmailID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailTopicDaily`
--



--
-- Table structure for table `EmailTopicImmediate`
--

CREATE TABLE EmailTopicImmediate (
  ImmediateEmailID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  MajorTopicID int(11) NOT NULL default '0',
  MinorTopicID int(11) NOT NULL default '0',
  PRIMARY KEY  (ImmediateEmailID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailTopicImmediate`
--



--
-- Table structure for table `EmailTopicWeekly`
--

CREATE TABLE EmailTopicWeekly (
  WeeklyEmailID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL default '0',
  MajorTopicID int(11) NOT NULL default '0',
  MinorTopicID int(11) NOT NULL default '0',
  PRIMARY KEY  (WeeklyEmailID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailTopicWeekly`
--



--
-- Table structure for table `EmailUser`
--

CREATE TABLE EmailUser (
  EmailUserID int(11) NOT NULL auto_increment,
  Username char(32) NOT NULL default '',
  Password char(32) NOT NULL default '',
  Name char(128) NOT NULL default '',
  EmailAddress char(64) NOT NULL default '',
  PreferHTML int(11) NOT NULL default '0',
  TimeStamp timestamp(14) NOT NULL,
  CanSign int(11) default NULL,
  Verified int(11) default NULL,
  AuthorID int(11) default NULL,
  PRIMARY KEY  (EmailUserID)
) TYPE=MyISAM;

--
-- Dumping data for table `EmailUser`
--



--
-- Table structure for table `GroupHierarchy`
--

CREATE TABLE GroupHierarchy (
  HierarchyID int(11) NOT NULL auto_increment,
  ChildID int(11) NOT NULL default '0',
  ParentID int(11) NOT NULL default '0',
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (HierarchyID)
) TYPE=MyISAM;

--
-- Dumping data for table `GroupHierarchy`
--



--
-- Table structure for table `GroupTopic`
--

CREATE TABLE GroupTopic (
  GroupTopicID int(11) NOT NULL auto_increment,
  GroupID int(11) NOT NULL default '0',
  MajorTopicID int(11) NOT NULL default '0',
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (GroupTopicID)
) TYPE=MyISAM;

--
-- Dumping data for table `GroupTopic`
--



--
-- Table structure for table `Institution`
--

CREATE TABLE Institution (
  InstitutionID int(11) NOT NULL auto_increment,
  ShortName varchar(40) NOT NULL default '',
  LongName varchar(80) NOT NULL default '',
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (InstitutionID)
) TYPE=MyISAM;

--
-- Dumping data for table `Institution`
--



--
-- Table structure for table `Journal`
--

CREATE TABLE Journal (
  JournalID int(11) NOT NULL auto_increment,
  Abbreviation varchar(64) NOT NULL default '',
  Name varchar(128) NOT NULL default '',
  Publisher varchar(64) NOT NULL default '',
  URL varchar(240) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  Acronym varchar(8) default NULL,
  PRIMARY KEY  (JournalID)
) TYPE=MyISAM;

--
-- Dumping data for table `Journal`
--



--
-- Table structure for table `Keyword`
--

CREATE TABLE Keyword (
  KeywordID int(11) NOT NULL auto_increment,
  ShortDescription varchar(32) default NULL,
  LongDescription text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (KeywordID)
) TYPE=MyISAM;

--
-- Dumping data for table `Keyword`
--



--
-- Table structure for table `KeywordGroup`
--

CREATE TABLE KeywordGroup (
  KeywordGroupID int(11) NOT NULL auto_increment,
  ShortDescription varchar(32) default NULL,
  LongDescription text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (KeywordGroupID)
) TYPE=MyISAM;

--
-- Dumping data for table `KeywordGroup`
--



--
-- Table structure for table `KeywordGrouping`
--

CREATE TABLE KeywordGrouping (
  KeywordGroupingID int(11) NOT NULL auto_increment,
  KeywordGroupID int(11) default NULL,
  KeywordID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (KeywordGroupingID),
  KEY KeywordID (KeywordID),
  KEY KeywordGroupID (KeywordGroupID)
) TYPE=MyISAM;

--
-- Dumping data for table `KeywordGrouping`
--



--
-- Table structure for table `MajorTopic`
--

CREATE TABLE MajorTopic (
  MajorTopicID int(11) NOT NULL auto_increment,
  ShortDescription varchar(32) NOT NULL default '',
  LongDescription text,
  Restricted int(11) default '0',
  Suppressed int(11) default '0',
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (MajorTopicID)
) TYPE=MyISAM;

--
-- Dumping data for table `MajorTopic`
--



--
-- Table structure for table `MeetingModify`
--

CREATE TABLE MeetingModify (
  MeetingModifyID int(11) NOT NULL auto_increment,
  ConferenceID int(11) default NULL,
  GroupID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (MeetingModifyID),
  KEY ConferenceID (ConferenceID)
) TYPE=MyISAM;

--
-- Dumping data for table `MeetingModify`
--



--
-- Table structure for table `MeetingOrder`
--

CREATE TABLE MeetingOrder (
  MeetingOrderID int(11) NOT NULL auto_increment,
  SessionOrder int(11) default NULL,
  SessionID int(11) default NULL,
  SessionSeparatorID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (MeetingOrderID),
  KEY SessionID (SessionID),
  KEY SessionSeparatorID (SessionSeparatorID)
) TYPE=MyISAM;

--
-- Dumping data for table `MeetingOrder`
--



--
-- Table structure for table `MeetingSecurity`
--

CREATE TABLE MeetingSecurity (
  MeetingSecurityID int(11) NOT NULL auto_increment,
  ConferenceID int(11) default NULL,
  GroupID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (MeetingSecurityID),
  KEY ConferenceID (ConferenceID)
) TYPE=MyISAM;

--
-- Dumping data for table `MeetingSecurity`
--



--
-- Table structure for table `MinorTopic`
--

CREATE TABLE MinorTopic (
  MinorTopicID int(11) NOT NULL auto_increment,
  MajorTopicID int(11) NOT NULL default '0',
  ShortDescription varchar(32) NOT NULL default '',
  LongDescription text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (MinorTopicID),
  KEY Major (MajorTopicID)
) TYPE=MyISAM;

--
-- Dumping data for table `MinorTopic`
--



--
-- Table structure for table `RevisionAuthor`
--

CREATE TABLE RevisionAuthor (
  RevAuthorID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL default '0',
  AuthorID int(11) NOT NULL default '0',
  PRIMARY KEY  (RevAuthorID),
  KEY DocRevID (DocRevID),
  KEY AuthorID (AuthorID)
) TYPE=MyISAM;

--
-- Dumping data for table `RevisionAuthor`
--



--
-- Table structure for table `RevisionModify`
--

CREATE TABLE RevisionModify (
  RevModifyID int(11) NOT NULL auto_increment,
  GroupID int(11) default NULL,
  DocRevID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (RevModifyID),
  KEY GroupID (GroupID),
  KEY DocRevID (DocRevID)
) TYPE=MyISAM;

--
-- Dumping data for table `RevisionModify`
--



--
-- Table structure for table `RevisionReference`
--

CREATE TABLE RevisionReference (
  ReferenceID int(11) NOT NULL auto_increment,
  DocRevID int(11) default NULL,
  JournalID int(11) default NULL,
  Volume char(32) default NULL,
  Page char(32) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (ReferenceID),
  KEY JournalID (JournalID),
  KEY DocRevID (DocRevID)
) TYPE=MyISAM;

--
-- Dumping data for table `RevisionReference`
--



--
-- Table structure for table `RevisionSecurity`
--

CREATE TABLE RevisionSecurity (
  RevSecurityID int(11) NOT NULL auto_increment,
  GroupID int(11) NOT NULL default '0',
  DocRevID int(11) NOT NULL default '0',
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (RevSecurityID),
  KEY Grp (GroupID),
  KEY Revision (DocRevID)
) TYPE=MyISAM;

--
-- Dumping data for table `RevisionSecurity`
--



--
-- Table structure for table `RevisionTopic`
--

CREATE TABLE RevisionTopic (
  RevTopicID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL default '0',
  MinorTopicID int(11) NOT NULL default '0',
  PRIMARY KEY  (RevTopicID),
  KEY MinorTopicID (MinorTopicID),
  KEY DocRevID (DocRevID)
) TYPE=MyISAM;

--
-- Dumping data for table `RevisionTopic`
--



--
-- Table structure for table `SecurityGroup`
--

CREATE TABLE SecurityGroup (
  GroupID int(11) NOT NULL auto_increment,
  Name char(16) NOT NULL default '',
  Description char(64) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  CanCreate int(11) default '0',
  CanAdminister int(11) default '0',
  PRIMARY KEY  (GroupID)
) TYPE=MyISAM;

--
-- Dumping data for table `SecurityGroup`
--



--
-- Table structure for table `Session`
--

CREATE TABLE Session (
  SessionID int(11) NOT NULL auto_increment,
  ConferenceID int(11) default NULL,
  StartTime datetime default NULL,
  Location varchar(128) default NULL,
  Title varchar(128) default NULL,
  Description text,
  TimeStamp timestamp(14) NOT NULL,
  ShowAllTalks int(11) default NULL,
  PRIMARY KEY  (SessionID),
  KEY ConferenceID (ConferenceID)
) TYPE=MyISAM;

--
-- Dumping data for table `Session`
--



--
-- Table structure for table `SessionOrder`
--

CREATE TABLE SessionOrder (
  SessionOrderID int(11) NOT NULL auto_increment,
  TalkOrder int(11) default NULL,
  SessionTalkID int(11) default NULL,
  TalkSeparatorID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (SessionOrderID),
  KEY SessionTalkID (SessionTalkID),
  KEY TalkSeparatorID (TalkSeparatorID)
) TYPE=MyISAM;

--
-- Dumping data for table `SessionOrder`
--



--
-- Table structure for table `SessionSeparator`
--

CREATE TABLE SessionSeparator (
  SessionSeparatorID int(11) NOT NULL auto_increment,
  ConferenceID int(11) default NULL,
  StartTime datetime default NULL,
  Location varchar(128) default NULL,
  Title varchar(128) default NULL,
  Description text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (SessionSeparatorID),
  KEY ConferenceID (ConferenceID)
) TYPE=MyISAM;

--
-- Dumping data for table `SessionSeparator`
--



--
-- Table structure for table `SessionTalk`
--

CREATE TABLE SessionTalk (
  SessionTalkID int(11) NOT NULL auto_increment,
  SessionID int(11) default NULL,
  DocumentID int(11) default NULL,
  Confirmed int(11) default NULL,
  Time time default NULL,
  HintTitle varchar(128) default NULL,
  Note text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (SessionTalkID),
  KEY SessionID (SessionID),
  KEY DocumentID (DocumentID)
) TYPE=MyISAM;

--
-- Dumping data for table `SessionTalk`
--



--
-- Table structure for table `Signature`
--

CREATE TABLE Signature (
  SignatureID int(11) NOT NULL auto_increment,
  EmailUserID int(11) default NULL,
  SignoffID int(11) default NULL,
  Note text,
  Signed int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (SignatureID),
  KEY EmailUserID (EmailUserID),
  KEY SignoffID (SignoffID)
) TYPE=MyISAM;

--
-- Dumping data for table `Signature`
--



--
-- Table structure for table `Signoff`
--

CREATE TABLE Signoff (
  SignoffID int(11) NOT NULL auto_increment,
  DocRevID int(11) default NULL,
  Note text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (SignoffID),
  KEY DocRevID (DocRevID)
) TYPE=MyISAM;

--
-- Dumping data for table `Signoff`
--



--
-- Table structure for table `SignoffDependency`
--

CREATE TABLE SignoffDependency (
  SignoffDependencyID int(11) NOT NULL auto_increment,
  SignoffID int(11) default NULL,
  PreSignoffID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (SignoffDependencyID),
  KEY SignoffID (SignoffID),
  KEY PreSignoffID (PreSignoffID)
) TYPE=MyISAM;

--
-- Dumping data for table `SignoffDependency`
--



--
-- Table structure for table `TalkSeparator`
--

CREATE TABLE TalkSeparator (
  TalkSeparatorID int(11) NOT NULL auto_increment,
  SessionID int(11) default NULL,
  Time time default NULL,
  Title varchar(128) default NULL,
  Note text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (TalkSeparatorID),
  KEY SessionID (SessionID)
) TYPE=MyISAM;

--
-- Dumping data for table `TalkSeparator`
--



--
-- Table structure for table `TopicHint`
--

CREATE TABLE TopicHint (
  TopicHintID int(11) NOT NULL auto_increment,
  SessionTalkID int(11) default NULL,
  MinorTopicID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (TopicHintID),
  KEY SessionTalkID (SessionTalkID)
) TYPE=MyISAM;

--
-- Dumping data for table `TopicHint`
--



--
-- Table structure for table `UsersGroup`
--

CREATE TABLE UsersGroup (
  UsersGroupID int(11) NOT NULL auto_increment,
  EmailUserID int(11) default NULL,
  GroupID int(11) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (UsersGroupID),
  KEY EmailUserID (EmailUserID)
) TYPE=MyISAM;

--
-- Dumping data for table `UsersGroup`
--

-- This file made by "mysqldump -c -u docdbadm -p BTeVDocDB | grep -v "INSERT INTO" " and then adding the last 4 lines
-- Set up the DocDB adminstrator account. Everything else can be done in the admin interface

INSERT INTO SecurityGroup (GroupID, Name, Description, CanCreate, CanAdminister) VALUES 
                          (0,'DocDBAdm','Document Database Administrators',1,1);
