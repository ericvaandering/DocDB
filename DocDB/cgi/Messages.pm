#
# Description: Central location for many of the error messages for the DocDB since many 
#              programs return the same errors. 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

$Msg_AdminNoConnect  = "Unable to connect to the database. Make sure you use the correct password.";
$Msg_AdminNoLogin    = "You must be logged in as the adminstrator to perform this action.";
$Msg_DelInstWAuthors = "You can't delete institutions with authors. ".
                       "Delete the authors first if you want to delete the institution.";
$Msg_ModInstEmpty    = "You must select an institution to modify.";

# FIXME: Add more messages from other programs
# FIXME: Add a localizable error message inclusion

1;
