#
# Drop old version, if it's there
#

DROP TABLE IF EXISTS maxindex
\p\g

#
# Table structure for table 'maxindex'
#

CREATE TABLE maxindex (
	tablename	CHAR(40) NOT NULL PRIMARY KEY,
	maxindex	CHAR(5)
) 
\p\g

