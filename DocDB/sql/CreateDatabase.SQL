# MySQL dump 8.12
#
# Host: vchipp.phy.vanderbilt.edu    Database: BTeVDocTest
#--------------------------------------------------------
# Server version	3.23.32

#
# Table structure for table 'Author'
#

CREATE TABLE Author (
  AuthorID int(11) NOT NULL auto_increment,
  FirstName varchar(32) default NULL,
  MiddleInitials varchar(16) default NULL,
  LastName varchar(32) default NULL,
  InstitutionID int(11) default NULL,
  Active int(11) default '1',
  PRIMARY KEY (AuthorID)
) TYPE=MyISAM;

#
# Table structure for table 'Document'
#

CREATE TABLE Document (
  DocumentID int(11) NOT NULL auto_increment,
  RequesterID int(11) default NULL,
  RequestDate datetime default NULL,
  DocumentType varchar(16) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY (DocumentID)
) TYPE=MyISAM;

#
# Table structure for table 'DocumentFile'
#

CREATE TABLE DocumentFile (
  DocFileID int(11) NOT NULL auto_increment,
  DocRevID int(11) default NULL,
  FileName varchar(255) default NULL,
  Date datetime default NULL,
  RootFile tinyint(4) default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY (DocFileID),
  KEY DocRevID(DocRevID)
) TYPE=MyISAM;

#
# Table structure for table 'DocumentRevision'
#

CREATE TABLE DocumentRevision (
  DocRevID int(11) NOT NULL auto_increment,
  DocumentID int(11) default NULL,
  SubmitterID int(11) default NULL,
  DocumentTitle varchar(255) default NULL,
  PublicationInfo text,
  VersionNumber int(11) default NULL,
  Abstract text,
  RevisionDate datetime default NULL,
  Security set('BTeV','Executive','RTES') default NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY (DocRevID),
  KEY DocumentID(DocumentID),
  KEY DocumentTitle(DocumentTitle),
  KEY VersionNumber(VersionNumber)
) TYPE=MyISAM;

#
# Table structure for table 'DocumentType'
#

CREATE TABLE DocumentType (
  DocTypeID int(11) NOT NULL auto_increment,
  ShortType varchar(32) default NULL,
  LongType varchar(255) default NULL,
  PRIMARY KEY (DocTypeID)
) TYPE=MyISAM;

#
# Table structure for table 'MajorTopic'
#

CREATE TABLE MajorTopic (
  MajorTopicID int(11) NOT NULL auto_increment,
  ShortDescription varchar(32) default NULL,
  LongDescription text,
  PRIMARY KEY (MajorTopicID)
) TYPE=MyISAM;

#
# Table structure for table 'MinorTopic'
#

CREATE TABLE MinorTopic (
  MinorTopicID int(11) NOT NULL auto_increment,
  MajorTopicID int(11) default NULL,
  ShortDescription varchar(32) default NULL,
  LongDescription text,
  PRIMARY KEY (MinorTopicID)
) TYPE=MyISAM;

#
# Table structure for table 'RevisionAuthor'
#

CREATE TABLE RevisionAuthor (
  RevAuthorID int(11) NOT NULL auto_increment,
  DocRevID int(11) default NULL,
  AuthorID int(11) default NULL,
  PRIMARY KEY (RevAuthorID),
  KEY DocRevID(DocRevID),
  KEY AuthorID(AuthorID)
) TYPE=MyISAM;

#
# Table structure for table 'RevisionTopic'
#

CREATE TABLE RevisionTopic (
  RevTopicID int(11) NOT NULL auto_increment,
  DocRevID int(11) default NULL,
  MinorTopicID int(11) default NULL,
  PRIMARY KEY (RevTopicID),
  KEY MinorTopicID(MinorTopicID),
  KEY DocRevID(DocRevID)
) TYPE=MyISAM;

