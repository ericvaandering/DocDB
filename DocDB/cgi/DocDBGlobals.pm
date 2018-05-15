#
# Description: Configuration file for the DocDB. Sets default
#              values and script names. Do not change this file,
#              specific local settings are in ProjectGlobals.pm.
#              Nearly any variable here can be changed there.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:
#
# Copyright 2001-2017 Eric Vaandering, Lynn Garren, Adam Bryant

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

# Constants

$TRUE  = 1;
$FALSE = 0;

# Advertising link for DocDB

$DocDBHome = "http://docdb-v.sourceforge.net/";

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

$Preferences{Security}{Certificates}{PopupLimitCookie} = $FALSE; # Unused, encourage users to limit which groups they belong to with cookies
$Preferences{Security}{Certificates}{FNALKCA} = $FALSE;      # TRUE or FALSE - show KCA certificate instructions
$Preferences{Security}{Certificates}{DOEGrids} = $FALSE;     # TRUE or FALSE - show DOEgrid certificate instructions
$Preferences{Security}{Certificates}{ShowCertInstructions} = $FALSE;  # TRUE or FALSE - show certificate instructions even on non-cert version

$Preferences{Security}{AuthName} = "";  # Set to override default AuthName of group1 or group2, etc.
$Preferences{Security}{SSOGroupVariables} = ();  # Environmental variables with lists of groups
$Preferences{Security}{TransferCertToSSO} = $FALSE;  # Automatically transfer certificate user information to SSO or automatically make SSO account if it does not exist

# Set these URLs to $cgi_root for the various instances you maintain if you want cross-links between them

$Preferences{Security}{Instances}{Public}      = "";
$Preferences{Security}{Instances}{Basic}       = "";
$Preferences{Security}{Instances}{Certificate} = "";
$Preferences{Security}{Instances}{Shibboleth}  = "";

$Preferences{Options}{DynamicFullList}{Private} = $FALSE; # Generate Full document list by dynamically for private db
$Preferences{Options}{DynamicFullList}{Public}  = $FALSE; # Generate Full document list by dynamically for public db

$Preferences{Options}{AlwaysRetrieveFile}       = $FALSE; # Always use RetrieveFile instead of File Links
$Preferences{Options}{MaxArchiveSize} = 4096;  # Maximum size of input files that will be archived (in MB)
@{$Preferences{Options}{FileEndingsForAttachment}} = ("doc","docx","xls","xlsx","ppt","pptx","pps","ppsx");

$Preferences{Options}{SubmitAgree}              = ""; # "Put text here to make users agree to a privacy statement or some-such. <br/><b>I agree:</b>"

# On updates of documents, require an entry in the note field and/or zero out the submitter and require a new entry
$Preferences{Options}{Update}{RequireNote}      = $FALSE;
$Preferences{Options}{Update}{RequireSubmitter} = $FALSE;

$Preferences{Components}{iCal}             = $TRUE; # Display links to iCal calendars
$Preferences{Components}{AgendaMaker}      = $TRUE; # Sessions for events
$Preferences{Components}{Calendar}         = $TRUE; # Calendar
$Preferences{Components}{LastModifiedHome} = $TRUE; # Last modified on the homepage

$Preferences{Topics}{MinLevel}{Document} = 1;
$Preferences{Topics}{Selector}           = "tree";   # tree, multi, or single
$Preferences{Topics}{NColumns}           = 3;        # number of columns in the topic table
$Preferences{Authors}{Selector}          = "active"; # active, list, or field
$Preferences{Events}{MaxSessionList}     = 5;

$htaccess             = ".htaccess";

$LastDays             = 20;    # Number of days for default in LastModified
$HomeLastDays         = 7;     # Number of days for last modified on home page
$HomeMaxDocs          = 50;    # Maximum number of documents on home page
$MeetingWindow        = 7;     # Days before and after meeting to preselect
$TalkHintWindow       = 7;     # Days before and after to guess on documents
$MeetingFiles         = 3;     # Number of upload boxes on meeting short form
$InitialSessions      = 5;     # Number of initial sessions when making meeting

$FirstYear            = 2000;  # Earliest year that documents can be created

$TalkMatchThreshold   = 100;   # Threshold for matching talks with agenda entries in agendas

@MatchIgnoreWords     = ("from","with","then","than","that","what"); # Don't match on these

# These groups will be allowed to modify document meta-data and add files without
# clearing the signature list. This variable will be replaced in DocDB 9.x with
# a database field.

@HackPreserveSignoffGroups = (); # = ('Writer','Admin')  # Users allowed to modify metadata and add files without clearing signature list
@HackDocsPreserveSignoffGroups = (); # = ('Writer','Admin')  # Users allowed to modify documents without clearing signature list

$RequiredMark = "&nbsp;*&nbsp;";

$HTTP_ENCODING        = 'ISO-8859-1'; # Character set for page encoding, may have to modify
                                      # MySQL text fields accordingly

# Which things are publicly viewable?

$PublicAccess{MeetingList} = 0;

# Options

$CaseInsensitiveUsers = 0;
$EnhancedSecurity     = $TRUE; # Separate lists for view, modify
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

$XSearch               = $cgi_root."XSearch";
$Search                = $cgi_root."Search";
$SearchForm            = $cgi_root."SearchForm";

$AuthorAddForm         = $cgi_root."AuthorAddForm";
$AuthorAdd             = $cgi_root."AuthorAdd";

$ListManagedDocuments  = $cgi_root."ListManagedDocuments";

$ListAuthors           = $cgi_root."ListAuthors";
$ListEventsBy          = $cgi_root."ListEventsBy";
$ListGroups            = $cgi_root."ListGroups";
$ListKeywords          = $cgi_root."ListKeywords";
$ListTopics            = $cgi_root."ListTopics";
$ListTypes             = $cgi_root."ListTypes";
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

$AdministerHome        = $cgi_root."AdministerHome";
$AdministerForm        = $cgi_root."AdministerForm";
$AuthorAdminister      = $cgi_root."AuthorAdminister";
$InstitutionAdminister = $cgi_root."InstitutionAdminister";
$TopicAdminister       = $cgi_root."TopicAdminister";
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
$CustomListForm        = $cgi_root."CustomListForm";

$SelectGroups          = $cgi_root."SelectGroups";
$SetGroups             = $cgi_root."SetGroups";

$EmailLogin            = $cgi_root."EmailLogin";
$SelectEmailPrefs      = $cgi_root."SelectEmailPrefs";
$WatchDocument         = $cgi_root."WatchDocument";

$CertificateApplyForm  = $cgi_root."CertificateApplyForm";
$BulkCertificateInsert = $cgi_root."BulkCertificateInsert";
$UserAccessApply       = $cgi_root."UserAccessApply";
$SSOAccessApply        = $cgi_root."SSOAccessApply";
$ListGroupUsers        = $cgi_root."ListGroupUsers";

$DocDBHelp             = $cgi_root."DocDBHelp";
$DocDBInstructions     = $cgi_root."DocDBInstructions";
$ShowTalkNote          = $cgi_root."ShowTalkNote";
$EditTalkInfo          = $cgi_root."EditTalkInfo";

$XMLUpload             = $cgi_root."XMLUpload";

unless ($CSSDirectory && $CSSURLPath) {
  $CSSDirectory = $file_root."/Static/css";
  $CSSURLPath   = $web_root."/Static/css";
}

unless ($JSDirectory && $JSURLPath) {
  $JSDirectory = $file_root."/Static/js";
  $JSURLPath   = $web_root."/Static/js";
}

unless ($ImgDirectory && $ImgURLPath) {
  $ImgDirectory = $file_root."/Static/img";
  $ImgURLPath   = $web_root."/Static/img";
}

if (!$Tar && $GTar) {
  $Tar = $GTar;
}

1;
