#
# Description: Configuration file for the DocDB. Sets default
#              values and script names. Do not change this file,
#              specific local settings are in ProjectGlobals.pm. 
#              Nearly any variable here can be changed there.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Advertising link for DocDB

$DocDBHome = "http://cepa.fnal.gov/DocDB/";

# Optional components

$MailInstalled = 1; # Is the Mailer::Mail module installed?

# Shell Commands

$Wget   = "/usr/bin/wget -O - --quiet ";
$Tar    = "/bin/tar ";
$Unzip  = "/usr/bin/unzip -q ";
$Zip    = "/usr/bin/zip -q -r ";  # Set to "" in ProjectGlobals if not installed

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

# Other Globals

$RemoteUsername       = $ENV{REMOTE_USER};
$remote_user          = $ENV{REMOTE_USER};
$remote_user          =~ tr/[A-Z]/[a-z]/;

$htaccess             = ".htaccess";

$LastDays             = 20;    # Number of days for default in LastModified
$HomeLastDays         = 7;     # Number of days for last modified on home page
$HomeMaxDocs          = 50;    # Maximum number of documents on home page
$MeetingWindow        = 7;     # Days before and after meeting to preselect
$TalkHintWindow       = 7;     # Days before and after to guess on documents
$MeetingFiles         = 3;     # Number of upload boxes on meeting short form
$InitialSessions      = 5;     # Number of initial sessions when making meeting

$FirstYear            = 2000;  # Earliest year that documents can be created

$TopicMatchThreshold    = 25;  # Threshold for matching talks in meetings with topics
$NoTopicMatchThreshold  = 6;   # Threshold for matching talks in meetings with topics

@MatchIgnoreWords       = ("from","with","then","than","that","what"); # Don't match on these
  
# Options

$CaseInsensitiveUsers = 0;
$EnhancedSecurity     = 0;     # Separate lists for view, modify
$SuperiorsCanModify   = 1;     # In enhanced model, a superior group can modify
                               # a subordinate groups documents without explicit
                               # permission
$UseSignoffs          = 0;     # Optional sign-off system for document approval

# Major topic names for "meetings" and "conferences". Each can be a list
# The first item in the two lists are accessed by ListMeetings and ListConferences

@MeetingMajorTopics    = ("Collaboration Meetings","Other Meetings");
@ConferenceMajorTopics = ("Conferences");

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

$ListDocuments         = $cgi_root."ListDocuments";
$ListByAuthor          = $cgi_root."ListByAuthor";
$ListByTopic           = $cgi_root."ListByTopic";
$ListByType            = $cgi_root."ListByType";
$LastModified          = $cgi_root."LastModified";

$ListAuthors           = $cgi_root."ListAuthors";
$ListTopics            = $cgi_root."ListTopics";
$ListTypes             = $cgi_root."ListTypes";
$ListMeetings          = $cgi_root."ListMeetings";
$ListKeywords          = $cgi_root."ListKeywords";

$AddFiles              = $cgi_root."AddFiles";
$AddFilesForm          = $cgi_root."AddFilesForm";

$ConferenceAddForm     = $cgi_root."ConferenceAddForm";
$ConferenceAdd         = $cgi_root."ConferenceAdd";

$DisplayMeeting        = $cgi_root."DisplayMeeting";
$MeetingModify         = $cgi_root."MeetingModify";
$SessionModify         = $cgi_root."SessionModify";
$ListAllMeetings       = $cgi_root."ListAllMeetings"; # FIXME: Remove later
$ConfirmTalkHint       = $cgi_root."ConfirmTalkHint";

$SignoffChooser        = $cgi_root."SignoffChooser";
$SignRevision          = $cgi_root."SignRevision";

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

$Statistics            = $cgi_root."Statistics";

$HelpFile              = $web_root."Static/Restricted/DocDB_Help.shtml";

$SelectPrefs           = $cgi_root."SelectPrefs";
$SetPrefs              = $cgi_root."SetPrefs";

$EmailLogin            = $cgi_root."EmailLogin";
$SelectEmailPrefs      = $cgi_root."SelectEmailPrefs";

$DocDBHelp             = $cgi_root."DocDBHelp";
$ShowTalkNote          = $cgi_root."ShowTalkNote";

1;
