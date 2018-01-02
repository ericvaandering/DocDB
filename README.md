# About DocDB

DocDB is a powerful and flexible collaborative document server. It was originally developed for use by the BTeV collaboration 
at Fermilab and is now used by twenty or more other experiments, Fermilab divisions, organizations, national laboratories, 
and companies. DocDB is well suited for managing and sharing documents (not just official publications) 
among groups of up to several hundred people.

A DocDB installation consists of three parts: 1) a relational database which stores information about the documents, 
2) a file system hierarchy used for storing the documents themselves, 
and 3) a suite of CGI scripts which provide coherent access to both sets of information.

 * DocDB maintains a versioned list of documents in a MySQL database. Information maintained in the database includes, 
author(s), title, topic(s), events(s), creation on modification dates, revision number, abstract, keywords, document type, 
pointers to the actual document files, and access restriction information.
 * Access to DocDB is controlled by cgi scripts that run on your web server.
 * When a document is submitted to DocDB, the document is copied (from either local disk or an html address) to a directory located on the web server. Documents may be composed of many files.
 * Documents are copied to a central location so that they will not "disappear" when someone rearranges or deletes files. This also enables centralized backup.
 * Changes to a document result in a new version of the document. Old versions remain available, providing historical archiving. Different versions allow different access restrictions, so documents can be developed in private and then released.
 * DocDB contains an event and agenda management system which allows documents to be associated with meetings of all sizes.

Please see [BTeV-doc-140](http://btev-docdb.fnal.gov/cgi-bin/public/DocDB/ShowDocument?docid=140) for a description of the early versions of DocDB.

DocDB is available under the terms of the GNU Public License (GPL), version 2.

To obtain DocDB, please see the [releases section](https://github.com/ericvaandering/DocDB/releases) of the GitHub repository for a zip file. 
[Installation instructions](https://github.com/ericvaandering/DocDB/wiki/Installation) are maintained on the GitHub Wiki. 

Send questions about installing DocDB to docdb-users@fnal.gov 
The docdb-users mailing list is archived at http://listserv.fnal.gov/archives/docdb-users.html.

If you have questions about using a particular DocDB implementation, please send mail to the administrators of that 
implementation. You should find a link labeled Document Database Administrators at the bottom of every DocDB page.


