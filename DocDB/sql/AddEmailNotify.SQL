CREATE TABLE EmailUser (
  EmailUserID int(11) NOT NULL auto_increment,
  Username char(32) NOT NULL default '',
  Password char(32) NOT NULL default '',
  Name char(128) NOT NULL default '',
  EmailAddress char(64) NOT NULL default '',
  PreferHTML int(11) NOT NULL,
  PRIMARY KEY (EmailUserID)
) TYPE=MyISAM;

CREATE TABLE EmailTopicImmediate (
  ImmediateEmailID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  MajorTopicID int(11) NOT NULL ,
  MinorTopicID int(11) NOT NULL ,
  PRIMARY KEY (ImmediateEmailID)
) TYPE=MyISAM;

CREATE TABLE EmailTopicDaily (
  DailyEmailID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  MajorTopicID int(11) NOT NULL ,
  MinorTopicID int(11) NOT NULL ,
  PRIMARY KEY (DailyEmailID)
) TYPE=MyISAM;

CREATE TABLE EmailTopicWeekly (
  WeeklyEmailID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  MajorTopicID int(11) NOT NULL ,
  MinorTopicID int(11) NOT NULL ,
  PRIMARY KEY (WeeklyEmailID)
) TYPE=MyISAM;

