#! /bin/csh

# Prepare directory for public version of DocumentDatabase

# Copy this file to the location of the public database, run the script, and
# then delete it.

# Set-up few required .pm files
cvs update ProjectGlobals.pm.template
echo "cp ProjectGlobals.pm.template ProjectGlobals.pm and edit the file."

ln -sf ../../DocDB/DocDBGlobals.pm  .

# Set-up only needed scripts

ln -sf ../../DocDB/DocumentDatabase . 
ln -sf ../../DocDB/LastModified  .
ln -sf ../../DocDB/ShowDocument  .

ln -sf ../../DocDB/ListConferences  .
ln -sf ../../DocDB/ListTopics  .
ln -sf ../../DocDB/ListAuthors  .
ln -sf ../../DocDB/ListTypes  . # Optional

ln -sf ../../DocDB/ListByTopic  .
ln -sf ../../DocDB/ListByAuthor  .
ln -sf ../../DocDB/ListByType  .  # Optional

ln -sf ../../DocDB/RetrieveFile  .
ln -sf ../../DocDB/SearchForm  . # Could be optional
ln -sf ../../DocDB/Search  .     # Could be optional

ln -sf ../../DocDB/DocDBHelp .
ln -sf ../../DocDB/DocDBHelp.xml .
ln -sf ../../DocDB/docdb.hlp .   # Soon to be obsolete

#ln -sf ../../DocDB/ProjectHelp.xml . # Project help may be different for public

echo "If no errors were reported, things are safe for public access now."
echo "Don't forget to delete PublicInstall.csh to prevent it runnig via CGI."

