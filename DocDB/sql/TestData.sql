-- This is a very minimal set of test data so that you can see some
-- parts of DocDB in action. You can install this on a test database.
-- It is not recommended that if you adopt DocDB, you begin again with 
-- CreateDatabase.sql
-- To use this test data, do:
--     mysql -u docdbadm -p SomeDocDB 
-- where "docdbadm" is the name of your admin account and SomeDocDB is the
-- name of your document database.

INSERT INTO Author VALUES (1,'Eric','','Vaandering',1,1,20040323143637);
INSERT INTO Author VALUES (2,'Lynn','','Garren',2,1,20040323143650);
INSERT INTO Author VALUES (3,'Adam','D.','Bryant',1,1,20040323143706);
INSERT INTO Conference VALUES (1,3,'Nowhere','http://www.bogus.org','2004-03-23','2004-03-26',20040323150505,NULL,NULL,NULL,NULL);
INSERT INTO Conference VALUES (2,4,'Cayman Islands','','2004-05-23','2004-05-23',20040323150832,'This is the preamble. This will be a meeting with two sessions and a lunch break.','May 2004 Collaboration Meeting','This is the epilogue. Have a nice flight back.',NULL);
INSERT INTO Conference VALUES (3,5,'San Francisco','','2004-06-23','2004-06-25',20040323151042,'This meeting has no sessions yet. You should create one, though.','June 2004','',1);
INSERT INTO Document VALUES (1,1,'2004-03-23 14:45:30',1,20040323144530);
INSERT INTO Document VALUES (2,3,'2004-03-23 14:52:16',2,20040323145216);
INSERT INTO DocumentFile VALUES (1,2,'dti.html','2004-03-23 14:52:16',1,20040323145216,'HTML');
INSERT INTO DocumentRevision VALUES (1,1,1,'Reserved document','',0,'This is just a reservation for a future document. No files are allowed to exist for a reservation, just a number and the basic information.','2004-03-23 14:45:30',20040323144530,0,'test reservation',NULL,NULL);
INSERT INTO DocumentRevision VALUES (2,2,3,'Test document with a \"file\"','Here you can put other information, like a URL http://www.fnal.gov/ which will be turned into a link.',1,'This is a test document with a file (dti.html). Of course the file won\'t actually exist, but the entries for the file in the DB will.','2004-03-23 14:52:16',20040323145216,0,'',NULL,NULL);
INSERT INTO DocumentType VALUES (1,'Talk','Talk',20040323142849);
INSERT INTO DocumentType VALUES (2,'Publication','Publication',20040323142915);
INSERT INTO GroupHierarchy VALUES (1,2,1,20040323144032);
INSERT INTO GroupHierarchy VALUES (2,3,1,20040323144032);
INSERT INTO GroupHierarchy VALUES (3,2,3,20040323144039);
INSERT INTO Institution VALUES (1,'Vanderbilt','Vanderbilt University',20040323142532);
INSERT INTO Institution VALUES (2,'Fermilab','Fermi National Accelerator Laboratory',20040323142604);
INSERT INTO Keyword VALUES (1,'test','test (member of Physics and Computing)',20040323151257);
INSERT INTO Keyword VALUES (2,'Beauty','B Physics (just a member of Physics)',20040323151330);
INSERT INTO Keyword VALUES (3,'WWW','World Wide Web',20040323151349);
INSERT INTO KeywordGroup VALUES (1,'Computing','Computing',20040323151152);
INSERT INTO KeywordGroup VALUES (2,'Physics','Physics',20040323151219);
INSERT INTO KeywordGrouping VALUES (1,2,1,20040323151257);
INSERT INTO KeywordGrouping VALUES (2,1,1,20040323151257);
INSERT INTO KeywordGrouping VALUES (3,2,2,20040323151330);
INSERT INTO KeywordGrouping VALUES (4,1,3,20040323151349);
INSERT INTO MajorTopic VALUES (1,'Conferences','Conferences',0,0,20040323142700);
INSERT INTO MajorTopic VALUES (2,'Collaboration Meetings','Collaboration Meetings',0,0,20040323142736);
INSERT INTO MajorTopic VALUES (3,'Computing','Computing',0,0,20040323142820);
INSERT INTO MeetingOrder VALUES (1,1,1,0,20040323150832);
INSERT INTO MeetingOrder VALUES (2,2,0,1,20040323150832);
INSERT INTO MeetingOrder VALUES (3,3,2,0,20040323150832);
INSERT INTO MinorTopic VALUES (1,3,'Web Tools','Web Tools',20040323143811);
INSERT INTO MinorTopic VALUES (2,3,'Document Database','Document Database',20040323143830);
INSERT INTO MinorTopic VALUES (3,1,'BOGUS IX','9th Meeting of a Fictional Group',20040323150505);
INSERT INTO MinorTopic VALUES (4,2,'May 2004','May 2004 Collaboration Meeting',20040323150832);
INSERT INTO MinorTopic VALUES (5,2,'June 2004','June 2004',20040323151042);
INSERT INTO RevisionAuthor VALUES (1,1,2);
INSERT INTO RevisionAuthor VALUES (2,1,1);
INSERT INTO RevisionAuthor VALUES (3,2,3);
INSERT INTO RevisionModify VALUES (1,3,1,20040323144530);
INSERT INTO RevisionModify VALUES (2,3,2,20040323145216);
INSERT INTO RevisionSecurity VALUES (1,2,1,20040323144530);
INSERT INTO RevisionSecurity VALUES (2,3,1,20040323144530);
INSERT INTO RevisionSecurity VALUES (3,3,2,20040323145216);
INSERT INTO RevisionTopic VALUES (1,1,2);
INSERT INTO RevisionTopic VALUES (2,2,1);
INSERT INTO SecurityGroup VALUES (2,'Reader','Read-only group (maybe a reviewer)',20040323143940,NULL,NULL);
INSERT INTO SecurityGroup VALUES (3,'Writer','A regular user, may add documents to database',20040323144332,1,NULL);
INSERT INTO Session VALUES (1,2,'2004-05-23 09:00:00','Room 101','Morning Session','We\'ll discuss mornings in this session',20040323150832,NULL);
INSERT INTO Session VALUES (2,2,'2004-05-23 14:00:00','Room 102','Afternoon Session',NULL,20040323150832,NULL);
INSERT INTO SessionSeparator VALUES (1,2,'2004-05-23 12:30:00','Restaurant by the beach','Lunch','Don\'t forget to pick up your meal ticket',20040323150832);
