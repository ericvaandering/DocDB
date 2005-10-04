#
# Description: Configuration file for the DocDB. Sets default
#              values and script names. Do not change this file,
#              specific local settings are in ProjectGlobals.pm. 
#              Nearly any variable here can be changed there.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#
# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Constants

use constant TRUE  => 1; #Doesn't span other files.
use constant FALSE => 0;

$TRUE  = 1;
$FALSE = 0;

# Advertising link for DocDB

$DocDBHome = "http://docdb.fnal.gov/doc/";

# Optional components

$MailInstalled = 1; # Is the Mailer::Mail module installed?

# Shell Commands, FS details

$Wget   = "/usr/bin/wget";
$Tar    = "";
$GTar   = "/bin/tar ";
$GZip   = "/bin/gzip ";
$GUnzip = "/bin/gunzip ";
$Unzip  = "/usr/bin/unzip -q ";
$Zip    = "/usr/bin/zip -q -r ";  # Set to "" in ProjectGlobals if not installed
$FileMagic = "/usr/bin/file";

$TmpDir = "/tmp/";

# Useful stuff

%ReverseFullMonth = (January => 1,  February => 2,  March     => 3,
                     April   => 4,  May      => 5,  June      => 6,
                     July    => 7,  August   => 8,  September => 9,
                     October => 10, November => 11, December  => 12);

%ReverseAbrvMonth = (Jan => 1,  Feb => 2,  Mar => 3,
                     Apr => 4,  May => 5,  Jun => 6,
                     Jul => 7,  Aug => 8,  Sep => 9,
                     Oct => 10, Nov => 11, Dec => 12);

@AbrvMonths = ("Jan","Feb","Mar","Apr","May","Jun",
               "Jul","Aug","Sep","Oct","Nov","Dec");

@FullMonths = ("January",  "February","March",   "April",
               "May",      "June",    "July",    "August",
               "September","October", "November","December");

# Reports 

@WarnStack   = ();
@ErrorStack  = ();
@DebugStack  = ();
@ActionStack = ();

# Other Globals

$RemoteUsername       = $ENV{REMOTE_USER};
$remote_user          = $ENV{REMOTE_USER};
$remote_user          =~ tr/[A-Z]/[a-z]/;

# Preferences

$Preferences{Security}{Certificates}{UseCNOnly}        = $FALSE; # Use CN instead of E (E-mail) to distinguish
$Preferences{Security}{Certificates}{PopupLimitCookie} = $FALSE; # Unused, encourage users to limit which groups they belong to with cookies

$Preferences{Options}{DynamicFullList}{Private} = $FALSE; # Generate Full document list by dynamically for private db
$Preferences{Options}{DynamicFullList}{Public}  = $FALSE; # Generate Full document list by dynamically for public db

$Preferences{Options}{AlwaysRetrieveFile}       = $FALSE; # Always use RetrieveFile instead of File Links

$htaccess             = ".htaccess";

$LastDays             = 20;    # Number of days for default in LastModified
$HomeLastDays         = 7;     # Number of days for last modified on home page
$HomeMaxDocs          = 50;    # Maximum number of documents on home page
$MeetingWindow        = 7;     # Days before and after meeting to preselect
$TalkHintWindow       = 7;     # Days before and after to guess on documents
$MeetingFiles         = 3;     # Number of upload boxes on meeting short form
$InitialSessions      = 5;     # Number of initial sessions when making meeting

$FirstYear            = 2000;  # Earliest year that documents can be created

$TalkMatchThreshold    = 999;    # Threshold for matching talks in meetings with topics

@MatchIgnoreWords     = ("from","with","then","than","that","what"); # Don't match on these

$RequiredMark = "&nbsp;*&nbsp;";
  
# Which things are publicly viewable?

$PublicAccess{MeetingList} = 0;  
  
# Options

$CaseInsensitiveUsers = 0;
$EnhancedSecurity     = 0;     # Separate lists for view, modify
$SuperiorsCanModify   = 1;     # In enhanced model, a superior group can modify
                               # a subordinate groups documents without explicit
                               # permission
$UserValidation = "";          # || "basic-user" || "certificate"
                               # Do we do group authorization like V5 and before
			       # or do we allow .htaccess/.htpasswd users to map to groups (basic)
			       # or require SSL certificates of users which map to groups (certificate)			       
$ReadOnly       = 0;           # Can be used in conjunction with individual
                               # authorization methods to set up a group-like
                               # area with group passwords which can view
                               # but not change any info
$ReadOnlyAdmin  = 0;           # Allows administration from the read-only 
                               # area. Only suggested for boot-strapping until
                               # you have an individual selected as admin                               
			       
$UseSignoffs          = 0;     # Optional sign-off system for document approval
$ContentSearch        = "";    # Scripts and engine installed for searching files

$DefaultPublicAccess  = 0;     # New documents are public by default

# Include project specific settings

require "ProjectGlobals.pm";

# Special files (here because they use values from above)

# CGI Scripts

$MainPage              = $cgi_root."DocumentDatabase";
$ModifyHome            = $cgi_root."ModifyHome";

$DocumentAddForm       = $cgi_root."DocumentAddForm";
$ProcessDocumentAdd    = $cgi_root."ProcessDocumentAdd";
$DeleteConfirm         = $cgi_root."DeleteConfirm";
$DeleteDocument        = $cgi_root."DeleteDocument";

$ShowDocument          = $cgi_root."ShowDocument";
$RetrieveFile          = $cgi_root."RetrieveFile";
$RetrieveArchive       = $cgi_root."RetrieveArchive";

$Search                = $cgi_root."Search";
$SearchForm            = $cgi_root."SearchForm";

$TopicAddForm          = $cgi_root."TopicAddForm";
$TopicAdd              = $cgi_root."TopicAdd";
$AuthorAddForm         = $cgi_root."AuthorAddForm";
$AuthorAdd             = $cgi_root."AuthorAdd";

$ListManagedDocuments  = $cgi_root."ListManagedDocuments";

$ListAuthors           = $cgi_root."ListAuthors";
$ListTopics            = $cgi_root."ListTopics";
$ListTypes             = $cgi_root."ListTypes";
$ListKeywords          = $cgi_root."ListKeywords";
$ListBy                = $cgi_root."ListBy";

$AddFiles              = $cgi_root."AddFiles";
$AddFilesForm          = $cgi_root."AddFilesForm";

$DisplayMeeting        = $cgi_root."DisplayMeeting";
$MeetingModify         = $cgi_root."MeetingModify";
$SessionModify         = $cgi_root."SessionModify";
$ListAllMeetings       = $cgi_root."ListAllMeetings"; 
$ConfirmTalkHint       = $cgi_root."ConfirmTalkHint";
$ShowCalendar          = $cgi_root."ShowCalendar";

$SignoffChooser        = $cgi_root."SignoffChooser";
$SignRevision          = $cgi_root."SignRevision";
$SignatureReport       = $cgi_root."SignatureReport";

$AdministerForm        = $cgi_root."AdministerForm";
$AuthorAdminister      = $cgi_root."AuthorAdminister";
$InstitutionAdminister = $cgi_root."InstitutionAdminister";
$TopicAdminister       = $cgi_root."TopicAdminister";
$MajorTopicAdminister  = $cgi_root."MajorTopicAdminister";
$DocTypeAdminister     = $cgi_root."DocTypeAdminister";
$JournalAdminister     = $cgi_root."JournalAdminister";
$ConferenceAdminister  = $cgi_root."ConferenceAdminister";

$KeywordAdministerForm  = $cgi_root."KeywordAdministerForm";
$KeywordListAdminister  = $cgi_root."KeywordListAdminister";
$KeywordGroupAdminister = $cgi_root."KeywordGroupAdminister";

$GroupAdministerForm   = $cgi_root."GroupAdministerForm";
$GroupAdminister       = $cgi_root."GroupAdminister";

$EmailAdministerForm   = $cgi_root."EmailAdministerForm";
$EmailAdminister       = $cgi_root."EmailAdminister";

$EventAdministerForm         = $cgi_root."EventAdministerForm";
$ExternalDocDBAdministerForm = $cgi_root."ExternalDocDBAdministerForm";

$Statistics            = $cgi_root."Statistics";

$SelectPrefs           = $cgi_root."SelectPrefs";
$SetPrefs              = $cgi_root."SetPrefs";

$SelectGroups          = $cgi_root."SelectGroups";
$SetGroups             = $cgi_root."SetGroups";

$EmailLogin            = $cgi_root."EmailLogin";
$SelectEmailPrefs      = $cgi_root."SelectEmailPrefs";
$WatchDocument         = $cgi_root."WatchDocument";

$CertificateApplyForm  = $cgi_root."CertificateApplyForm";
$UserAccessApply       = $cgi_root."UserAccessApply";

$DocDBHelp             = $cgi_root."DocDBHelp";
$DocDBInstructions     = $cgi_root."DocDBInstructions";
$ShowTalkNote          = $cgi_root."ShowTalkNote";

unless ($CSSDirectory && $CSSURLPath) {
  $CSSDirectory = $file_root."/Static/css";
  $CSSURLPath   = $web_root."/Static/css";
}  

unless ($JSDirectory && $JSURLPath) {
  $JSDirectory = $file_root."/Static/js";
  $JSURLPath   = $web_root."/Static/js";
}  

if (!$Tar && $GTar) {
  $Tar = $GTar;
} 

1;
