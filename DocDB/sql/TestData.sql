-- This is a very minimal set of test data so that you can see some
-- parts of DocDB in action. You can install this on a test database.
-- It is not recommended that if you adopt DocDB, you begin again with 
-- CreateDatabase.sql
-- To use this test data, do:
--     mysql -u docdbadm -p SomeDocDB 
-- where "docdbadm" is the name of your admin account and SomeDocDB is the
-- name of your document database.

INSERT INTO Author (AuthorID, FirstName, MiddleInitials, LastName, InstitutionID, Active, TimeStamp) VALUES (1,'Eric','','Vaandering',1,1,20040323143637);
INSERT INTO Author (AuthorID, FirstName, MiddleInitials, LastName, InstitutionID, Active, TimeStamp) VALUES (2,'Lynn','','Garren',2,1,20040323143650);
INSERT INTO Author (AuthorID, FirstName, MiddleInitials, LastName, InstitutionID, Active, TimeStamp) VALUES (3,'Adam','D.','Bryant',1,1,20040323143706);
INSERT INTO Conference (ConferenceID, MinorTopicID, Location, URL, StartDate, EndDate, TimeStamp, Preamble, Title, Epilogue, ShowAllTalks) VALUES (1,3,'Nowhere','http://www.bogus.org','2004-03-23','2004-03-26',20040323150505,NULL,NULL,NULL,NULL);
INSERT INTO Conference (ConferenceID, MinorTopicID, Location, URL, StartDate, EndDate, TimeStamp, Preamble, Title, Epilogue, ShowAllTalks) VALUES (2,4,'Cayman Islands','','2004-05-23','2004-05-23',20040323150832,'This is the preamble. This will be a meeting with two sessions and a lunch break.','May 2004 Collaboration Meeting','This is the epilogue. Have a nice flight back.',NULL);
INSERT INTO Conference (ConferenceID, MinorTopicID, Location, URL, StartDate, EndDate, TimeStamp, Preamble, Title, Epilogue, ShowAllTalks) VALUES (3,5,'San Francisco','','2004-06-23','2004-06-25',20040323151042,'This meeting has no sessions yet. You should create one, though.','June 2004','',1);
INSERT INTO Document (DocumentID, RequesterID, RequestDate, DocumentType, TimeStamp) VALUES (1,1,'2004-03-23 14:45:30',1,20040323144530);
INSERT INTO Document (DocumentID, RequesterID, RequestDate, DocumentType, TimeStamp) VALUES (2,3,'2004-03-23 14:52:16',2,20040323145216);
INSERT INTO DocumentFile (DocFileID, DocRevID, FileName, Date, RootFile, TimeStamp, Description) VALUES (1,2,'dti.html','2004-03-23 14:52:16',1,20040323145216,'HTML');
INSERT INTO DocumentRevision (DocRevID, DocumentID, SubmitterID, DocumentTitle, PublicationInfo, VersionNumber, Abstract, RevisionDate, TimeStamp, Obsolete, Keywords, Note, Demanaged) VALUES (1,1,1,'Reserved document','',0,'This is just a reservation for a future document. No files are allowed to exist for a reservation, just a number and the basic information.','2004-03-23 14:45:30',20040323144530,0,'test reservation',NULL,NULL);
INSERT INTO DocumentRevision (DocRevID, DocumentID, SubmitterID, DocumentTitle, PublicationInfo, VersionNumber, Abstract, RevisionDate, TimeStamp, Obsolete, Keywords, Note, Demanaged) VALUES (2,2,3,'Test document with a \"file\"','Here you can put other information, like a URL http://www.fnal.gov/ which will be turned into a link.',1,'This is a test document with a file (dti.html). Of course the file won\'t actually exist, but the entries for the file in the DB will.','2004-03-23 14:52:16',20040325220556,0,'',NULL,1);
INSERT INTO DocumentType (DocTypeID, ShortType, LongType, TimeStamp) VALUES (1,'Talk','Talk',20040323142849);
INSERT INTO DocumentType (DocTypeID, ShortType, LongType, TimeStamp) VALUES (2,'Publication','Publication',20040323142915);
INSERT INTO GroupHierarchy (HierarchyID, ChildID, ParentID, TimeStamp) VALUES (1,2,1,20040323144032);
INSERT INTO GroupHierarchy (HierarchyID, ChildID, ParentID, TimeStamp) VALUES (2,3,1,20040323144032);
INSERT INTO GroupHierarchy (HierarchyID, ChildID, ParentID, TimeStamp) VALUES (6,2,3,20040326132155);
INSERT INTO Institution (InstitutionID, ShortName, LongName, TimeStamp) VALUES (1,'Vanderbilt','Vanderbilt University',20040323142532);
INSERT INTO Institution (InstitutionID, ShortName, LongName, TimeStamp) VALUES (2,'Fermilab','Fermi National Accelerator Laboratory',20040323142604);
INSERT INTO Keyword (KeywordID, ShortDescription, LongDescription, TimeStamp) VALUES (1,'test','test (member of Physics and Computing)',20040323151257);
INSERT INTO Keyword (KeywordID, ShortDescription, LongDescription, TimeStamp) VALUES (2,'Beauty','B Physics (just a member of Physics)',20040323151330);
INSERT INTO Keyword (KeywordID, ShortDescription, LongDescription, TimeStamp) VALUES (3,'WWW','World Wide Web',20040323151349);
INSERT INTO KeywordGroup (KeywordGroupID, ShortDescription, LongDescription, TimeStamp) VALUES (1,'Computing','Computing',20040323151152);
INSERT INTO KeywordGroup (KeywordGroupID, ShortDescription, LongDescription, TimeStamp) VALUES (2,'Physics','Physics',20040323151219);
INSERT INTO KeywordGrouping (KeywordGroupingID, KeywordGroupID, KeywordID, TimeStamp) VALUES (1,2,1,20040323151257);
INSERT INTO KeywordGrouping (KeywordGroupingID, KeywordGroupID, KeywordID, TimeStamp) VALUES (2,1,1,20040323151257);
INSERT INTO KeywordGrouping (KeywordGroupingID, KeywordGroupID, KeywordID, TimeStamp) VALUES (3,2,2,20040323151330);
INSERT INTO KeywordGrouping (KeywordGroupingID, KeywordGroupID, KeywordID, TimeStamp) VALUES (4,1,3,20040323151349);
INSERT INTO MajorTopic (MajorTopicID, ShortDescription, LongDescription, Restricted, Suppressed, TimeStamp) VALUES (1,'Conferences','Conferences',0,0,20040323142700);
INSERT INTO MajorTopic (MajorTopicID, ShortDescription, LongDescription, Restricted, Suppressed, TimeStamp) VALUES (2,'Collaboration Meetings','Collaboration Meetings',0,0,20040323142736);
INSERT INTO MajorTopic (MajorTopicID, ShortDescription, LongDescription, Restricted, Suppressed, TimeStamp) VALUES (3,'Computing','Computing',0,0,20040323142820);
INSERT INTO MeetingOrder (MeetingOrderID, SessionOrder, SessionID, SessionSeparatorID, TimeStamp) VALUES (1,1,1,0,20040323150832);
INSERT INTO MeetingOrder (MeetingOrderID, SessionOrder, SessionID, SessionSeparatorID, TimeStamp) VALUES (2,2,0,1,20040323150832);
INSERT INTO MeetingOrder (MeetingOrderID, SessionOrder, SessionID, SessionSeparatorID, TimeStamp) VALUES (3,3,2,0,20040323150832);
INSERT INTO MinorTopic (MinorTopicID, MajorTopicID, ShortDescription, LongDescription, TimeStamp) VALUES (1,3,'Web Tools','Web Tools',20040323143811);
INSERT INTO MinorTopic (MinorTopicID, MajorTopicID, ShortDescription, LongDescription, TimeStamp) VALUES (2,3,'Document Database','Document Database',20040323143830);
INSERT INTO MinorTopic (MinorTopicID, MajorTopicID, ShortDescription, LongDescription, TimeStamp) VALUES (3,1,'BOGUS IX','9th Meeting of a Fictional Group',20040323150505);
INSERT INTO MinorTopic (MinorTopicID, MajorTopicID, ShortDescription, LongDescription, TimeStamp) VALUES (4,2,'May 2004','May 2004 Collaboration Meeting',20040323150832);
INSERT INTO MinorTopic (MinorTopicID, MajorTopicID, ShortDescription, LongDescription, TimeStamp) VALUES (5,2,'June 2004','June 2004',20040323151042);
INSERT INTO RevisionAuthor (RevAuthorID, DocRevID, AuthorID) VALUES (1,1,2);
INSERT INTO RevisionAuthor (RevAuthorID, DocRevID, AuthorID) VALUES (2,1,1);
INSERT INTO RevisionAuthor (RevAuthorID, DocRevID, AuthorID) VALUES (3,2,3);
INSERT INTO RevisionModify (RevModifyID, GroupID, DocRevID, TimeStamp) VALUES (1,3,1,20040323144530);
INSERT INTO RevisionModify (RevModifyID, GroupID, DocRevID, TimeStamp) VALUES (2,3,2,20040323145216);
INSERT INTO RevisionSecurity (RevSecurityID, GroupID, DocRevID, TimeStamp) VALUES (1,2,1,20040323144530);
INSERT INTO RevisionSecurity (RevSecurityID, GroupID, DocRevID, TimeStamp) VALUES (2,3,1,20040323144530);
INSERT INTO RevisionSecurity (RevSecurityID, GroupID, DocRevID, TimeStamp) VALUES (3,3,2,20040323145216);
INSERT INTO RevisionTopic (RevTopicID, DocRevID, MinorTopicID) VALUES (1,1,2);
INSERT INTO RevisionTopic (RevTopicID, DocRevID, MinorTopicID) VALUES (2,2,1);
INSERT INTO SecurityGroup (GroupID, Name, Description, TimeStamp, CanCreate, CanAdminister) VALUES (2,'Reader','Read-only group (maybe a reviewer)',20040323143940,NULL,NULL);
INSERT INTO SecurityGroup (GroupID, Name, Description, TimeStamp, CanCreate, CanAdminister) VALUES (3,'Writer','A regular user, may add documents to database',20040323144332,1,NULL);
INSERT INTO Session (SessionID, ConferenceID, StartTime, Location, Title, Description, TimeStamp, ShowAllTalks) VALUES (1,2,'2004-05-23 09:00:00','Room 101','Morning Session','We\'ll discuss mornings in this session',20040323150832,NULL);
INSERT INTO Session (SessionID, ConferenceID, StartTime, Location, Title, Description, TimeStamp, ShowAllTalks) VALUES (2,2,'2004-05-23 14:00:00','Room 102','Afternoon Session',NULL,20040323150832,NULL);
INSERT INTO SessionSeparator (SessionSeparatorID, ConferenceID, StartTime, Location, Title, Description, TimeStamp) VALUES (1,2,'2004-05-23 12:30:00','Restaurant by the beach','Lunch','Don\'t forget to pick up your meal ticket',20040323150832);
