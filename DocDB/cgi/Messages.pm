#
# Description: Central location for many of the error messages for the DocDB since many 
#              programs return the same errors. 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

$Msg_NoConnect        = "Unable to connect to the database. Please alert an administrator.";

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

$Msg_ModJournalEmpty  = "You must select a journal to modify or delete.";
$Msg_ModDocTypeEmpty  = "You must select a document type to modify or delete.";
$Msg_ModEUserEmpty    = "You must select a user to modify or delete.";

$Msg_ModTopicEmpty    = "You must select a topic to modify or delete.";
$Msg_ModConfEmpty     = "You must select a conference to modify or delete.";

# Messages for author creation, modification, display

$Msg_AuthorInvalid    = "You did not select a valid author.";

# Messages for topic creation, modification, display

$Msg_TopicNoShort      = "You must supply a short description for your topic or meeting.";
$Msg_TopicNoLong       = "You must supply a long description for your topic or meeting.";
$Msg_TopicShortIgnored = "Your short description of this meeting has been ".
                         "ignored. The long description will be used instead ".
                         "(because you didn't create a topic). ";

# Messages for meeting/session creation/modification

$Msg_MeetNoSessions     = "This meeting was created with no sessions. You will have to add at least one session before adding talks.";
$Msg_SessionBlankDelete = "Setting session titles to blank will not delete them.";

# FIXME: Add more messages from other programs
# FIXME: Add a localizable error message inclusion

1;
