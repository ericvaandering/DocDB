#! /bin/csh

# Prepare directory for public version of DocumentDatabase

cvs update

cp PublicGlobals.pm.safe PublicGlobals.pm # Enforce public setup
rm -f AuthorAdd AuthorAddForm
rm -f DocumentAddForm ProcessDocumentAdd
rm -f MigrateSecurity
rm -f TopicAddForm TopicAdd

echo "If no errors were reported, things are safe for public access now."

