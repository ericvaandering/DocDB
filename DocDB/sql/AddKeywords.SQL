CREATE TABLE KeywordGroup (
  KeywordGroupID int(11) NOT NULL auto_increment,
  ShortDescription varchar(32) NOT NULL default '',
  LongDescription text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (KeywordGroupID)
) TYPE=MyISAM;

CREATE TABLE Keyword (
  KeywordID int(11) NOT NULL auto_increment,
  KeywordGroupID int(11) NOT NULL default '0',
  ShortDescription varchar(32) NOT NULL default '',
  LongDescription text,
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (KeywordID),
  KEY Major (KeywordGroupID)
) TYPE=MyISAM;

CREATE TABLE KeywordGrouping (
  KeywordGroupingID int(11) NOT NULL auto_increment,
  KeywordGroupID int(11) NOT NULL default '0',
  KeywordID int(11) NOT NULL default '0',
  TimeStamp timestamp(14) NOT NULL,
  PRIMARY KEY  (KeywordGroupingID)
) TYPE=MyISAM;

