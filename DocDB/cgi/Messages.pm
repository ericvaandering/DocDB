#
# Description: Central location for many of the error messages for the DocDB since many 
#              programs return the same errors. 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

$Msg_AdminNoConnect   = "Unable to connect to the database. Make sure you use the correct password.";
$Msg_AdminNoLogin     = "You must be logged in as the adminstrator to perform this action.";

$Msg_ModInstEmpty     = "You must select an institution to modify or delete.";
$Msg_DelInstWAuthors  = "You can't delete institutions with authors. ".
                        "Delete the authors first if you want to delete the institution.";

$Msg_ModMajEmpty      = "You must select a major topic to modify.";
$Msg_DelMajWTopics    = "You can't delete major topics with subtopics. ".
                        "Delete the subtopics first if you want to delete the major topic.";

$Msg_ModGroupEmpty    = "You must select a group to modify or delete.";
$Msg_ModGroupNone     = "The group you selected to modify does not exist.";

$Msg_ModJournalEmpty = "You must select a journal to modify or delete.";
$Msg_ModDocTypeEmpty = "You must select a document type to modify or delete.";
$Msg_ModEUserEmpty   = "You must select a user to modify or delete.";

# FIXME: Add more messages from other programs
# FIXME: Add a localizable error message inclusion

1;
