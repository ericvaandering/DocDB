# Description: Central location for many of the error messages for the DocDB
#              since many programs return the same errors.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: Lynn Garren (garren@fnal.gov)
#

# Copyright 2001-2018 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

$Msg_NoConnect        = "Unable to connect to the database. Please alert an administrator.";

$Msg_AdminNoConnect   = "Unable to connect to the database. Make sure you use the correct DocDB administrator username and password.";
$Msg_AdminNoLogin     = "You must be logged in as the administrator to perform this action.";
$Msg_AdminNoPass      = "You must supply a username and password to perform administration actions.";

$Msg_ModInstEmpty     = "You must select an institution to modify or delete.";
$Msg_DelInstWAuthors  = "You can't delete institutions with authors. ".
                        "Delete the authors first if you want to delete the institution.";

$Msg_ModGroupEmpty    = "You must select a group to modify or delete.";
$Msg_ModGroupNone     = "The group you selected to modify does not exist.";

$Msg_ModJournalEmpty  = "You must select a journal to modify or delete.";
$Msg_ModDocTypeEmpty  = "You must select a document type to modify or delete.";
$Msg_ModEUserEmpty    = "You must select a user to modify or delete.";

$Msg_ModTopicEmpty    = "You must select a topic to modify or delete.";
$Msg_ModConfEmpty     = "You must select an event to modify or delete.";

$Msg_DelFullEvtGroup  = "You can't delete event groups with events. Delete the events first before deleting the group.";
$Msg_DelFullEvent     = "This event has associated documents. Not deleted.";

# Messages for document creation, modification, display

$Msg_DocNoAccess      = "Either you are not authorized to view this document
                         (with the username and password you supplied)
                         or the document does not exist.";


# Messages for author creation, modification, display

$Msg_AuthorInvalid    = "You did not select a valid author.";

# Messages for topic creation, modification, display

$Msg_TopicNoShort      = "You must supply a short description for your topic or meeting.";
$Msg_TopicNoLong       = "You must supply a long description for your topic or meeting.";
$Msg_TopicShortIgnored = "Your short description of this meeting has been ".
                         "ignored. The long description will be used instead ".
                         "(because you didn't create a topic). ";

# Messages for event/session creation/modification/access

$Msg_MeetNoSessions     = "This event was created with no sessions. You will have to add at least one session before adding talks.";
$Msg_MeetOnlyOne        = "This page can only be used to modify short events (just one session)";
$Msg_SessionBlankDelete = "Setting session titles to blank will not delete them.";

$Msg_MeetNoAccess       = "You do not have permission to view this event.";
$Msg_MeetNoCreate       = "You do not have permission to create or modify events.";
$Msg_MeetNoModify       = "You do not have permission to modify this event.";

# Messages for keywords, keyword groups

$Msg_ModKeyGrEmpty = "You must select a keyword group to modify.";
$Msg_DelKeyGrWKey  = "You can't delete keyword groups with keywords. ".
                     "Delete the keywords first if you want to delete the keyword group.";
$Msg_ModKeywdEmpty = "You must select a keyword to modify or delete.";

# Signoff Messages

$Msg_WarnModManaged = "Warning: You are about to modify a managed document. This will clear all the signatures on the document.";
$Msg_WarnModManagedHack = "Warning: You are about to clear all the signatures on the document, ".
                          "unless you check the box (near the bottom of this page) to preserve signatures.";

# FIXME: Add more messages from other programs

if (-e "ProjectMessages.pm") {
  require "ProjectMessages.pm";
  push @DebugStack,"Included Project Messages";
}

1;
