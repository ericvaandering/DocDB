#
# Description: Configuration file for the DocDB. Sets default
#              values and script names. Specific local settings are
#              in ProjectGlobals.pm
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

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

$RemoteUsername   = $ENV{REMOTE_USER};
$remote_user      = $ENV{REMOTE_USER};
$remote_user      =~ tr/[A-Z]/[a-z]/;

$RobotsMeta       = "none";
$htaccess         = ".htaccess";

$LastDays         = 20;        # Number of days for default in LastModified
$HomeLastDays     = 7;         # Number of days for last modified on home page
$HomeMaxDocs      = 50;        # Maximum number of documents on home page
$MeetingWindow    = 7;         # Days before and after meeting to preselect
$MeetingFiles     = 3;         # Number of upload boxes on meeting short form

# Include project specific settings

require "ProjectGlobals.pm";

# Special files (here because they use values from above)

$help_file          = $script_root."docdb.hlp";

# CGI Scripts

$MainPage           = $cgi_root."DocumentDatabase";
$ModifyHome         = $cgi_root."ModifyHome";

$DocumentAddForm    = $cgi_root."DocumentAddForm";
$ProcessDocumentAdd = $cgi_root."ProcessDocumentAdd";
$DeleteConfirm      = $cgi_root."DeleteConfirm";
$DeleteDocument     = $cgi_root."DeleteDocument";

$ShowDocument       = $cgi_root."ShowDocument";
$RetrieveFile       = $cgi_root."RetrieveFile";
$RetrieveArchive    = $cgi_root."RetrieveArchive";

$Search             = $cgi_root."Search";
$SearchForm         = $cgi_root."SearchForm";

$TopicAddForm       = $cgi_root."TopicAddForm";
$AuthorAddForm      = $cgi_root."AuthorAddForm";

$ListDocuments      = $cgi_root."ListDocuments";
$ListByAuthor       = $cgi_root."ListByAuthor";
$ListByTopic        = $cgi_root."ListByTopic";
$ListByType         = $cgi_root."ListByType";
$LastModified       = $cgi_root."LastModified";

$ListAuthors        = $cgi_root."ListAuthors";
$ListTopics         = $cgi_root."ListTopics";
$ListTypes          = $cgi_root."ListTypes";
$ListMeetings       = $cgi_root."ListMeetings";

$AddFiles           = $cgi_root."AddFiles";
$AddFilesForm       = $cgi_root."AddFilesForm";

$ConferenceAddForm  = $cgi_root."ConferenceAddForm";
$ConferenceAdd      = $cgi_root."ConferenceAdd";

$Statistics         = $cgi_root."Statistics";

$HelpFile           = $web_root."Static/Restricted/DocDB_Help.shtml";

$SelectPrefs        = $cgi_root."SelectPrefs";
$SetPrefs           = $cgi_root."SetPrefs";

$EmailLogin         = $cgi_root."EmailLogin";
$SelectEmailPrefs   = $cgi_root."SelectEmailPrefs";

1;
