#! /bin/csh

# Prepare directory for public version of DocumentDatabase

# Set-up few required .pm files
cvs update PublicGlobals.pm.safe
cp PublicGlobals.pm.safe PublicGlobals.pm

ln -sf ../../DocDB/DocDBGlobals.pm  .

# Set-up only needed scripts

ln -sf ../../DocDB/DocumentDatabase . 
ln -sf ../../DocDB/LastModified  .
ln -sf ../../DocDB/ShowDocument  .

ln -sf ../../DocDB/ListConferences  .
ln -sf ../../DocDB/ListTopics  .
ln -sf ../../DocDB/ListAuthors  .
ln -sf ../../DocDB/ListTypes  .

ln -sf ../../DocDB/ListByTopic  .
ln -sf ../../DocDB/ListByAuthor  .
ln -sf ../../DocDB/ListByType  .

ln -sf ../../DocDB/ListDocuments .

echo "If no errors were reported, things are safe for public access now."

