CREATE TABLE EmailAuthorImmediate (
  AuthorImmediateID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  AuthorID int(11) NOT NULL ,
  PRIMARY KEY (AuthorImmediateID)
) TYPE=MyISAM;

CREATE TABLE EmailAuthorDaily (
  AuthorDailyID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  AuthorID int(11) NOT NULL ,
  PRIMARY KEY (AuthorDailyID)
) TYPE=MyISAM;

CREATE TABLE EmailAuthorWeekly (
  AuthorWeeklyID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  AuthorID int(11) NOT NULL ,
  PRIMARY KEY (AuthorWeeklyID)
) TYPE=MyISAM;

CREATE TABLE EmailKeywordImmediate (
  KeywordImmediateID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  Keyword varchar(32) ,
  PRIMARY KEY (KeywordImmediateID)
) TYPE=MyISAM;

CREATE TABLE EmailKeywordDaily (
  KeywordDailyID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  Keyword varchar(32) ,
  PRIMARY KEY (KeywordDailyID)
) TYPE=MyISAM;

CREATE TABLE EmailKeywordWeekly (
  KeywordWeeklyID int(11) NOT NULL auto_increment,
  EmailUserID int(11) NOT NULL ,
  Keyword varchar(32) ,
  PRIMARY KEY (KeywordWeeklyID)
) TYPE=MyISAM;

grant delete on EmailKeywordDaily     to docdbrw;
grant delete on EmailKeywordImmediate to docdbrw;
grant delete on EmailKeywordWeekly    to docdbrw;
grant delete on EmailAuthorDaily      to docdbrw;
grant delete on EmailAuthorImmediate  to docdbrw;
grant delete on EmailAuthorWeekly     to docdbrw;
