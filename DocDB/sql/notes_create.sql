#
# Drop old version, if it's there
#

DROP TABLE IF EXISTS notes
\p\g

#
# Table structure for table 'notes' in DB 'notes'
#

CREATE TABLE notes (
	number		INT NOT NULL PRIMARY KEY,
	title		CHAR(255),
	authors		CHAR(255),
	pub_info	CHAR(255),
	requestor	CHAR(50),
	group_name	SET("STEEL","SCINT","SIM","COMP","ELEC","ANA","GEN","BEAM"),
	class		ENUM("NOTE","CONF","PUB","TRANS","MIN"),
	distribution	ENUM("PUBLIC","RESTRICTED"),
	doc_type	CHAR(10),
	revision	CHAR(10),
	date_req	DATE,
	date_fil	DATE,
	date_rev	DATE,
	upload_type	CHAR(10)
) 
\p\g
