-- This file creates the database structure for a Version 8.x installation of 
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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (AuthorID),
  KEY Name (LastName)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (AuthorHintID),
  KEY SessionTalkID (SessionTalkID)
) Engine=MyISAM;

--
-- Dumping data for table `AuthorHint`
--



--
-- Table structure for table `Conference`
--

CREATE TABLE Conference (
  ConferenceID int(11) NOT NULL auto_increment,
  Location varchar(64) NOT NULL default '',
  URL varchar(240) default NULL,
  StartDate date default NULL,
  EndDate date default NULL,
  TimeStamp timestamp NOT NULL,
  Title varchar(128) default NULL,
  Preamble text,
  Epilogue text,
  ShowAllTalks int(11) default NULL,
  EventGroupID int(11) default NULL,
  LongDescription text,
  AltLocation varchar(255) default NULL,
  PRIMARY KEY  (ConferenceID),
  KEY StartDate (StartDate),
  KEY EndDate (EndDate)
) Engine=MyISAM;

--
-- Dumping data for table `Conference`
--



--
-- Table structure for table `ConfigSetting`
--

CREATE TABLE ConfigSetting (
  ConfigSettingID int(11) NOT NULL auto_increment,
  Project varchar(32) default NULL,
  ConfigGroup varchar(64) default NULL,
  Sub1Group varchar(64) default NULL,
  Sub2Group varchar(64) default NULL,
  Sub3Group varchar(64) default NULL,
  Sub4Group varchar(64) default NULL,
  ForeignID int(11) default NULL,
  Value varchar(64) default NULL,
  Sub1Value varchar(64) default NULL,
  Sub2Value varchar(64) default NULL,
  Sub3Value varchar(64) default NULL,
  Sub4Value varchar(64) default NULL,
  Sub5Value varchar(64) default NULL,
  Description text,
  Constrained int(11) default NULL,
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (ConfigSettingID),
  KEY ConfigGroup (ConfigGroup),
  KEY Sub1Group (Sub1Group),
  KEY ForeignID (ForeignID)
) Engine=MyISAM;

--
-- Dumping data for table `ConfigSetting`
--



--
-- Table structure for table `ConfigValue`
--

CREATE TABLE ConfigValue (
  ConfigValueID int(11) NOT NULL auto_increment,
  ConfigSettingID int(11) default NULL,
  Value varchar(64) default NULL,
  Description text,
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (ConfigValueID),
  KEY ConfigSettingID (ConfigSettingID)
) Engine=MyISAM;

--
-- Dumping data for table `ConfigValue`
--



--
-- Table structure for table `DocXRef`
--

CREATE TABLE DocXRef (
  DocXRefID int(11) NOT NULL auto_increment,
  DocRevID int(11) default NULL,
  DocumentID int(11) default NULL,
  TimeStamp timestamp NOT NULL,
  Version int(11) default NULL,
  Project varchar(32) default NULL,
  PRIMARY KEY  (DocXRefID),
  KEY DocRevID (DocRevID),
  KEY DocumentID (DocumentID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  DocHash char(32) default NULL,
  Alias varchar(255) default NULL,
  PRIMARY KEY  (DocumentID),
  KEY Requester (RequesterID),
  KEY Alias (Alias)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  Description varchar(128) default NULL,
  PRIMARY KEY  (DocFileID),
  KEY DocRevID (DocRevID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  Obsolete tinyint(4) default '0',
  Keywords varchar(240) default NULL,
  Note text,
  Demanaged int(11) default NULL,
  DocTypeID int(11) default NULL,
  PRIMARY KEY  (DocRevID),
  KEY DocumentID (DocumentID),
  KEY DocumentTitle (DocumentTitle),
  KEY VersionNumber (VersionNumber)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (DocTypeID)
) Engine=MyISAM;

--
-- Dumping data for table `DocumentType`
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
  TimeStamp timestamp NOT NULL,
  CanSign int(11) NOT NULL default '0',
  Verified int(11) NOT NULL default '0',
  AuthorID int(11) NOT NULL default '0',
  PRIMARY KEY  (EmailUserID)
) Engine=MyISAM;

--
-- Dumping data for table `EmailUser`
--



--
-- Table structure for table `EventGroup`
--

CREATE TABLE EventGroup (
  EventGroupID int(11) NOT NULL auto_increment,
  ShortDescription varchar(32) NOT NULL default '',
  LongDescription text,
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (EventGroupID)
) Engine=MyISAM;

--
-- Dumping data for table `EventGroup`
--



--
-- Table structure for table `EventTopic`
--

CREATE TABLE EventTopic (
  EventTopicID int(11) NOT NULL auto_increment,
  TopicID int(11) NOT NULL default '0',
  EventID int(11) NOT NULL default '0',
  SessionID int(11) NOT NULL default '0',
  SessionSeparatorID int(11) NOT NULL default '0',
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (EventTopicID),
  KEY Topic (TopicID),
  KEY Event (EventID),
  KEY Session (SessionID),
  KEY SepKey (SessionSeparatorID)
) Engine=MyISAM;

--
-- Dumping data for table `EventTopic`
--



--
-- Table structure for table `ExternalDocDB`
--

CREATE TABLE ExternalDocDB (
  ExternalDocDBID int(11) NOT NULL auto_increment,
  Project varchar(32) default NULL,
  Description varchar(255) default NULL,
  PublicURL varchar(255) default NULL,
  PrivateURL varchar(255) default NULL,
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (ExternalDocDBID)
) Engine=MyISAM;

--
-- Dumping data for table `ExternalDocDB`
--



--
-- Table structure for table `GroupHierarchy`
--

CREATE TABLE GroupHierarchy (
  HierarchyID int(11) NOT NULL auto_increment,
  ChildID int(11) NOT NULL default '0',
  ParentID int(11) NOT NULL default '0',
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (HierarchyID)
) Engine=MyISAM;

--
-- Dumping data for table `GroupHierarchy`
--



--
-- Table structure for table `Institution`
--

CREATE TABLE Institution (
  InstitutionID int(11) NOT NULL auto_increment,
  ShortName varchar(40) NOT NULL default '',
  LongName varchar(80) NOT NULL default '',
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (InstitutionID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  Acronym varchar(8) default NULL,
  PRIMARY KEY  (JournalID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (KeywordID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (KeywordGroupID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (KeywordGroupingID),
  KEY KeywordID (KeywordID),
  KEY KeywordGroupID (KeywordGroupID)
) Engine=MyISAM;

--
-- Dumping data for table `KeywordGrouping`
--



--
-- Table structure for table `MeetingModify`
--

CREATE TABLE MeetingModify (
  MeetingModifyID int(11) NOT NULL auto_increment,
  ConferenceID int(11) default NULL,
  GroupID int(11) default NULL,
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (MeetingModifyID),
  KEY ConferenceID (ConferenceID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (MeetingOrderID),
  KEY SessionID (SessionID),
  KEY SessionSeparatorID (SessionSeparatorID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (MeetingSecurityID),
  KEY ConferenceID (ConferenceID)
) Engine=MyISAM;

--
-- Dumping data for table `MeetingSecurity`
--



--
-- Table structure for table `Moderator`
--

CREATE TABLE Moderator (
  ModeratorID int(11) NOT NULL auto_increment,
  AuthorID int(11) NOT NULL default '0',
  EventID int(11) NOT NULL default '0',
  SessionID int(11) NOT NULL default '0',
  SessionSeparatorID int(11) NOT NULL default '0',
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (ModeratorID),
  KEY Author (AuthorID),
  KEY Event (EventID),
  KEY Session (SessionID),
  KEY SepKey (SessionSeparatorID)
) Engine=MyISAM;

--
-- Dumping data for table `Moderator`
--



--
-- Table structure for table `Notification`
--

CREATE TABLE Notification (
  NotificationID int(11) NOT NULL auto_increment,
  EmailUserID int(11) default NULL,
  Type varchar(32) default NULL,
  ForeignID int(11) default NULL,
  Period varchar(32) default NULL,
  TimeStamp timestamp NOT NULL,
  TextKey varchar(255) default NULL,
  PRIMARY KEY  (NotificationID),
  KEY EmailUserID (EmailUserID),
  KEY ForeignID (ForeignID)
) Engine=MyISAM;

--
-- Dumping data for table `Notification`
--



--
-- Table structure for table `RevisionAuthor`
--

CREATE TABLE RevisionAuthor (
  RevAuthorID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL default '0',
  AuthorID int(11) NOT NULL default '0',
  AuthorOrder int(11) default '0',
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (RevAuthorID),
  KEY DocRevID (DocRevID),
  KEY AuthorID (AuthorID)
) Engine=MyISAM;

--
-- Dumping data for table `RevisionAuthor`
--



--
-- Table structure for table `RevisionEvent`
--

CREATE TABLE RevisionEvent (
  RevEventID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL default '0',
  ConferenceID int(11) NOT NULL default '0',
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (RevEventID),
  KEY MinorTopicID (ConferenceID),
  KEY DocRevID (DocRevID)
) Engine=MyISAM;

--
-- Dumping data for table `RevisionEvent`
--



--
-- Table structure for table `RevisionModify`
--

CREATE TABLE RevisionModify (
  RevModifyID int(11) NOT NULL auto_increment,
  GroupID int(11) default NULL,
  DocRevID int(11) default NULL,
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (RevModifyID),
  KEY GroupID (GroupID),
  KEY DocRevID (DocRevID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (ReferenceID),
  KEY JournalID (JournalID),
  KEY DocRevID (DocRevID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (RevSecurityID),
  KEY Grp (GroupID),
  KEY Revision (DocRevID)
) Engine=MyISAM;

--
-- Dumping data for table `RevisionSecurity`
--



--
-- Table structure for table `RevisionTopic`
--

CREATE TABLE RevisionTopic (
  RevTopicID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL default '0',
  TimeStamp timestamp NOT NULL,
  TopicID int(11) NOT NULL default '0',
  PRIMARY KEY  (RevTopicID),
  KEY DocRevID (DocRevID),
  KEY TopicID (TopicID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  CanCreate int(11) default '0',
  CanAdminister int(11) default '0',
  CanView int(11) default '1',
  CanConfig int(11) default '0',
  PRIMARY KEY  (GroupID)
) Engine=MyISAM;

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
  Title varchar(128) default NULL,
  Description text,
  TimeStamp timestamp NOT NULL,
  Location varchar(128) default NULL,
  AltLocation varchar(255) default NULL,
  ShowAllTalks int(11) default '0',
  PRIMARY KEY  (SessionID),
  KEY ConferenceID (ConferenceID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (SessionOrderID),
  KEY SessionTalkID (SessionTalkID),
  KEY TalkSeparatorID (TalkSeparatorID)
) Engine=MyISAM;

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
  Title varchar(128) default NULL,
  Description text,
  TimeStamp timestamp NOT NULL,
  Location varchar(128) default NULL,
  PRIMARY KEY  (SessionSeparatorID),
  KEY ConferenceID (ConferenceID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (SessionTalkID),
  KEY SessionID (SessionID),
  KEY DocumentID (DocumentID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (SignatureID),
  KEY EmailUserID (EmailUserID),
  KEY SignoffID (SignoffID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (SignoffID),
  KEY DocRevID (DocRevID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (SignoffDependencyID),
  KEY SignoffID (SignoffID),
  KEY PreSignoffID (PreSignoffID)
) Engine=MyISAM;

--
-- Dumping data for table `SignoffDependency`
--



--
-- Table structure for table `Suppress`
--

CREATE TABLE Suppress (
  SuppressID int(11) NOT NULL auto_increment,
  SecurityGroupID int(11) NOT NULL default '0',
  Type varchar(32) default NULL,
  ForeignID int(11) default NULL,
  TextKey varchar(255) default NULL,
  ViewSetting varchar(32) default NULL,
  ModifySetting varchar(32) default NULL,
  PRIMARY KEY  (SuppressID),
  KEY SecurityGroup (SecurityGroupID),
  KEY Type (Type),
  KEY ForeignID (ForeignID),
  KEY TextKey (TextKey)
) Engine=MyISAM;

--
-- Dumping data for table `Suppress`
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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (TalkSeparatorID),
  KEY SessionID (SessionID)
) Engine=MyISAM;

--
-- Dumping data for table `TalkSeparator`
--



--
-- Table structure for table `Topic`
--

CREATE TABLE Topic (
  TopicID int(11) NOT NULL auto_increment,
  ShortDescription varchar(64) default '',
  LongDescription text,
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (TopicID)
) Engine=MyISAM;

--
-- Dumping data for table `Topic`
--



--
-- Table structure for table `TopicHierarchy`
--

CREATE TABLE TopicHierarchy (
  TopicHierarchyID int(11) NOT NULL auto_increment,
  TopicID int(11) NOT NULL default '0',
  ParentTopicID int(11) NOT NULL default '0',
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (TopicHierarchyID),
  KEY Topic (TopicID),
  KEY Parent (ParentTopicID)
) Engine=MyISAM;

--
-- Dumping data for table `TopicHierarchy`
--



--
-- Table structure for table `TopicHint`
--

CREATE TABLE TopicHint (
  TopicHintID int(11) NOT NULL auto_increment,
  SessionTalkID int(11) default NULL,
  TimeStamp timestamp NOT NULL,
  TopicID int(11) NOT NULL default '0',
  PRIMARY KEY  (TopicHintID),
  KEY SessionTalkID (SessionTalkID)
) Engine=MyISAM;

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
  TimeStamp timestamp NOT NULL,
  PRIMARY KEY  (UsersGroupID),
  KEY EmailUserID (EmailUserID)
) Engine=MyISAM;

--
-- Dumping data for table `UsersGroup`
--


-- This file made by "mysqldump -c -u docdbadm -p BTeVDocDB | grep -v "INSERT INTO" " and then adding the last 4 lines

-- Set up the DocDB adminstrator account. Everything else can be done in the admin interface

INSERT INTO SecurityGroup (GroupID, Name, Description, CanCreate, CanAdminister,CanView,CanConfig) VALUES 
                          (0,'DocDBAdm','Document Database Administrators',1,1,1,1);

