# MySQL dump 8.12
#
# Host: vchipp.phy.vanderbilt.edu    Database: BTeVDocTest
#--------------------------------------------------------
# Server version	3.23.32-log

#
# Table structure for table 'Author'
#

CREATE TABLE Author (
  AuthorID int(11) NOT NULL auto_increment,
  FirstName varchar(32) NOT NULL,
  MiddleInitials varchar(16) default NULL,
  LastName varchar(32) NOT NULL,
  InstitutionID int(11) NOT NULL,
  Active int(11) default '1',
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (AuthorID),
  KEY Name(LastName)
) TYPE=MyISAM;

#
# Table structure for table 'Document'
#

CREATE TABLE Document (
  DocumentID int(11) NOT NULL auto_increment,
  RequesterID int(11) NOT NULL,
  RequestDate datetime default NULL,
  DocumentType int(11) NOT NULL,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY (DocumentID),
  KEY Requester(RequesterID)
) TYPE=MyISAM;

#
# Dumping data for table 'Document'
#


#
# Table structure for table 'DocumentFile'
#

CREATE TABLE DocumentFile (
  DocFileID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL,
  FileName varchar(255) NOT NULL,
  Date datetime default NULL,
  RootFile tinyint(4) default '1',
  TimeStamp timestamp(14) NOT NULL,
  Description varchar(128) default NULL,
  PRIMARY KEY (DocFileID),
  KEY DocRevID(DocRevID)
) TYPE=MyISAM;

#
# Dumping data for table 'DocumentFile'
#


#
# Table structure for table 'DocumentRevision'
#

CREATE TABLE DocumentRevision (
  DocRevID int(11) NOT NULL auto_increment,
  DocumentID int(11) NOT NULL,
  SubmitterID int(11) NOT NULL,
  DocumentTitle varchar(255) NOT NULL,
  PublicationInfo text,
  VersionNumber int(11) NOT NULL,
  Abstract text,
  RevisionDate datetime default NULL,
  TimeStamp timestamp(14) NOT NULL,
  Obsolete tinyint(4) default '0',
  JournalID int(11) default '0',
  Volume int(11) default '0',
  Page int(11) default '0',
  PRIMARY KEY (DocRevID),
  KEY DocumentID(DocumentID),
  KEY DocumentTitle(DocumentTitle),
  KEY VersionNumber(VersionNumber)
) TYPE=MyISAM;

#
# Dumping data for table 'DocumentRevision'
#

#
# Table structure for table 'GroupHierarchy'
#

CREATE TABLE GroupHierarchy (
  HierarchyID int(11) NOT NULL auto_increment,
  ChildID int(11) NOT NULL,
  ParentID int(11) NOT NULL,
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (HierarchyID)
) TYPE=MyISAM;

#
# Dumping data for table 'GroupHierarchy'
#

INSERT INTO GroupHierarchy VALUES (3,2,4,20011206164038);
INSERT INTO GroupHierarchy VALUES (2,1,4,20011206163729);
INSERT INTO GroupHierarchy VALUES (4,3,4,20011206164040);
INSERT INTO GroupHierarchy VALUES (5,1,2,20011206164111);
INSERT INTO GroupHierarchy VALUES (6,3,2,20011206164122);
INSERT INTO GroupHierarchy VALUES (7,3,1,20011206164127);

#
# Table structure for table 'GroupTopic'
#

CREATE TABLE GroupTopic (
  GroupTopicID int(11) NOT NULL auto_increment,
  GroupID int(11) NOT NULL,
  MajorTopicID int(11) NOT NULL,
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (GroupTopicID)
) TYPE=MyISAM;

#
# Dumping data for table 'GroupTopic'
#


#
# Table structure for table 'Institution'
#

CREATE TABLE Institution (
  InstitutionID int(11) NOT NULL auto_increment,
  ShortName varchar(40) NOT NULL,
  LongName varchar(80) NOT NULL,
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (InstitutionID)
) TYPE=MyISAM;

#
# Dumping data for table 'Institution'
#

INSERT INTO Institution VALUES (1,'Fermilab','Fermi National Accelerator Laboratory',20011205173606);
INSERT INTO Institution VALUES (2,'Vanderbilt','Vanderbilt University',20011205173606);
INSERT INTO Institution VALUES (3,'Syracuse','Syracuse University',20011205173606);
INSERT INTO Institution VALUES (4,'Belarussian State','Belarussian State University',20011207114429);
INSERT INTO Institution VALUES (5,'Davis','University of California at Davis',20011207114507);
INSERT INTO Institution VALUES (6,'Colorado','University of Colorado at Boulder',20011207114521);
INSERT INTO Institution VALUES (7,'Florida','University of Florida at Gainesville',20011207114548);
INSERT INTO Institution VALUES (8,'Houston','University of Houston',20011207114600);
INSERT INTO Institution VALUES (9,'IIT','Illinois Institute of Technology',20011207114631);
INSERT INTO Institution VALUES (10,'Illinois','University of Illinois',20011207114659);
INSERT INTO Institution VALUES (11,'Indiana','Indiana University',20011207114718);
INSERT INTO Institution VALUES (12,'INFN-Frascati','INFN - Laboratori Nazionali di Frascati',20011207114755);
INSERT INTO Institution VALUES (13,'INFN-Milano','INFN - Milano',20011207114816);
INSERT INTO Institution VALUES (14,'INFN-Pavia','INFN - Pavia',20011207114824);
INSERT INTO Institution VALUES (15,'INFN-Torino','INFN - Torino',20011207114835);
INSERT INTO Institution VALUES (16,'IHEP-Protvino','Institute of High Energy Physics - Protvino',20011207114917);
INSERT INTO Institution VALUES (17,'Insubria','University of Insubria in Como',20011207114942);
INSERT INTO Institution VALUES (18,'Iowa','University of Iowa',20011207115009);
INSERT INTO Institution VALUES (19,'Minnesota','University of Minnesota',20011207115022);
INSERT INTO Institution VALUES (20,'Nanjing','Nanjing University',20011207115039);
INSERT INTO Institution VALUES (21,'New Mexico State','New Mexico State University',20011207115114);
INSERT INTO Institution VALUES (22,'Ohio State','The Ohio State University',20011207115128);
INSERT INTO Institution VALUES (23,'Pennsylvania','University of Pennsylvania',20011207115147);
INSERT INTO Institution VALUES (24,'Puerto Rico','University of Puerto Rico, Mayaguez',20011207115223);
INSERT INTO Institution VALUES (25,'Science and Technology of China','University of Science and Technology of China',20011207115255);
INSERT INTO Institution VALUES (26,'Shandong','Shandong University, China',20011207115316);
INSERT INTO Institution VALUES (27,'Southern Methodist','Southern Methodist University',20011207115342);
INSERT INTO Institution VALUES (28,'SUNY Albany','SUNY Albany',20011207115401);
INSERT INTO Institution VALUES (29,'Tennessee','University of Tennessee',20011207115424);
INSERT INTO Institution VALUES (30,'Tufts','Tufts University',20011207115439);
INSERT INTO Institution VALUES (31,'Virginia','University of Virginia',20011207115531);
INSERT INTO Institution VALUES (32,'Wayne State','Wayne State University',20011207115546);
INSERT INTO Institution VALUES (33,'Wisconsin','University of Wisconsin',20011207115600);
INSERT INTO Institution VALUES (34,'Yale','Yale University',20011207115611);
INSERT INTO Institution VALUES (35,'York','York University',20011207115617);

#
# Table structure for table 'MajorTopic'
#

CREATE TABLE MajorTopic (
  MajorTopicID int(11) NOT NULL auto_increment,
  ShortDescription varchar(32) NOT NULL,
  LongDescription text,
  Restricted int(11) default '0',
  Suppressed int(11) default '0',
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (MajorTopicID)
) TYPE=MyISAM;

#
# Dumping data for table 'MajorTopic'
#

INSERT INTO MajorTopic VALUES (1,'Detectors','Information on sub-detectors',0,0,20011204141840);
INSERT INTO MajorTopic VALUES (2,'Physics-b','Physics involving b quarks',0,0,20011204175256);
INSERT INTO MajorTopic VALUES (3,'Physics-c','Physics involving charm quarks',0,0,20011204175302);
INSERT INTO MajorTopic VALUES (4,'Physics-Other','Other Physics (not b or c)',0,0,20011204175311);
INSERT INTO MajorTopic VALUES (5,'Computing','Computing and DAQ',0,0,20011204141840);
INSERT INTO MajorTopic VALUES (6,'Software','Software',0,0,20011204141840);
INSERT INTO MajorTopic VALUES (7,'Other Topics','Other Topics',0,0,20011204141840);
INSERT INTO MajorTopic VALUES (8,'Collaboration Meetings','Collaboration Meetings',0,0,20011204141840);
INSERT INTO MajorTopic VALUES (9,'Other Meetings','Other Meetings',0,0,20011204141840);
INSERT INTO MajorTopic VALUES (10,'Conferences','Conferences',0,0,20011231100856);

#
# Table structure for table 'MinorTopic'
#

CREATE TABLE MinorTopic (
  MinorTopicID int(11) NOT NULL auto_increment,
  MajorTopicID int(11) NOT NULL,
  ShortDescription varchar(32) NOT NULL,
  LongDescription text,
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (MinorTopicID),
  KEY Major(MajorTopicID)
) TYPE=MyISAM;

#
# Dumping data for table 'MinorTopic'
#


#
# Table structure for table 'RevisionAuthor'
#

CREATE TABLE RevisionAuthor (
  RevAuthorID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL,
  AuthorID int(11) NOT NULL,
  PRIMARY KEY (RevAuthorID),
  KEY DocRevID(DocRevID),
  KEY AuthorID(AuthorID)
) TYPE=MyISAM;

#
# Dumping data for table 'RevisionAuthor'
#


#
# Table structure for table 'RevisionSecurity'
#

CREATE TABLE RevisionSecurity (
  RevSecurityID int(11) NOT NULL auto_increment,
  GroupID int(11) NOT NULL,
  DocRevID int(11) NOT NULL,
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (RevSecurityID),
  KEY Grp(GroupID),
  KEY Revision(DocRevID)
) TYPE=MyISAM;

#
# Dumping data for table 'RevisionSecurity'
#


#
# Table structure for table 'RevisionTopic'
#

CREATE TABLE RevisionTopic (
  RevTopicID int(11) NOT NULL auto_increment,
  DocRevID int(11) NOT NULL,
  MinorTopicID int(11) NOT NULL,
  PRIMARY KEY (RevTopicID),
  KEY MinorTopicID(MinorTopicID),
  KEY DocRevID(DocRevID)
) TYPE=MyISAM;

#
# Dumping data for table 'RevisionTopic'
#


#
# Table structure for table 'SecurityGroup'
#

CREATE TABLE SecurityGroup (
  GroupID int(11) NOT NULL auto_increment,
  Name char(16) NOT NULL,
  Description char(64) default NULL,
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (GroupID)
) TYPE=MyISAM;

#
# Dumping data for table 'SecurityGroup'
#

INSERT INTO SecurityGroup VALUES (1,'BTeV','BTeV Collaboration',20011204144115);
INSERT INTO SecurityGroup VALUES (2,'Executive','BTeV Executive Council',20011204144130);
INSERT INTO SecurityGroup VALUES (3,'RTES','Real Time Embedded Systems',20011204144148);
INSERT INTO SecurityGroup VALUES (4,'DocDBAdm','Document Database Administrators',20011206160459);

CREATE TABLE DocumentType (
  DocTypeID int(11) NOT NULL auto_increment,
  ShortType varchar(32) default NULL,
  LongType varchar(255) default NULL,
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (DocTypeID)
) TYPE=MyISAM;
 
#
# Dumping data for table 'DocumentType'
#
 
INSERT INTO DocumentType VALUES (1,'Talk','Talk Transparencies',20011205173501);
INSERT INTO DocumentType VALUES (2,'Publication','Published materials (Papers, Proceedings, Preprints, Theses',20011205173501);
INSERT INTO DocumentType VALUES (3,'Proceeding','Conference Proceedings',20011205173501);
INSERT INTO DocumentType VALUES (4,'Figure/Photo','Drawings, Photographs, Plots, Figures',20011205173501);
INSERT INTO DocumentType VALUES (5,'Note','Notes and memos',20011205173501);
INSERT INTO DocumentType VALUES (6,'Minutes','Minutes of meetings',20011205173501);
INSERT INTO DocumentType VALUES (10,'Other','Other Types',20011205173501);
INSERT INTO DocumentType VALUES (8,'Audio','Audio files',20011205173501);
INSERT INTO DocumentType VALUES (9,'Video','Video files',20011205173501);

#
# Table structure for table 'Conference'
#

CREATE TABLE Conference (
  ConferenceID int(11) NOT NULL auto_increment,
  MinorTopicID int(11) NOT NULL default '0',
  Location varchar(64) NOT NULL default '',
  URL varchar(64) NOT NULL default '',
  StartDate date default NULL,
  EndDate date default NULL,
  Timestamp timestamp(14) NOT NULL,
  PRIMARY KEY (ConferenceID)
) TYPE=MyISAM;


#
# Table structure for table 'Journal'
#

CREATE TABLE Journal (
  JournalID int(11) NOT NULL auto_increment,
  Abbreviation char(64) NOT NULL default '',
  Name char(128) NOT NULL default '',
  Publisher char(64) NOT NULL default '',
  URL char(128) NOT NULL default '',
  Timestamp timestamp(14) NOT NULL,
  Acronym char(8) default NULL,
  PRIMARY KEY (JournalID)
) TYPE=MyISAM;

#
# Dumping data for table 'Journal'
#

INSERT INTO Journal VALUES (2,'Nucl. Instr. Meth. A','Nuclear Instruments and Methods in Physics Research Section A','Elsevier Science','http://www.elsevier.nl/',20020102164046,'NIMA');
INSERT INTO Journal VALUES (7,'Eur. Phys. J. C','European Physical Journal C','Springer-Verlag','http://link.springer.de/',20020102164851,'EPJC');
INSERT INTO Journal VALUES (4,'Phys. Lett. B','Physics Letters B','Elsevier Science','http://www.elsevier.nl/',20020102164139,'PLB');
INSERT INTO Journal VALUES (5,'Phys. Rev. D','Physical Review D','American Physical Society','http://publish.aps.org/',20020102164339,'PRD');
INSERT INTO Journal VALUES (6,'Phys. Rev. Lett.','Physical Review Letters','American Physical Society','http://publish.aps.org/',20020102164355,'PRL');

