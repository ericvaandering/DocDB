# DB settings
$db_name   = "BTeVDocTest";
$db_host   = "vchipp.phy.vanderbilt.edu";
$db_rwuser = "docdbrw";
$db_rwpass = "hall1burt0n";
$db_rouser = "docdbro";
$db_ropass = "abg3n1x";
$db_aduser = "docadmin";
$db_adpass = "docadmin";

# Root directories and URLs

$file_root   = "/var/www/html/BTeV/DocDB/";
$script_root = "/var/www/cgi-bin/BTeV/DocDB/cgi/";
$web_root    = "http://vuhepv.phy.vanderbilt.edu/BTeV/DocDB/";
$cgi_root    = "http://vuhepv.phy.vanderbilt.edu/cgi-bin/BTeV/DocDB/cgi/";

# Special files

$htaccess    = ".htaccess";
$help_file   = $script_root."docdb.hlp";
$AuthUserFile       = $script_root."htpasswd";

# CGI Scripts

$ProcessDocumentAdd = $cgi_root."ProcessDocumentAdd";
$DocumentAddForm    = $cgi_root."DocumentAddForm";
$ShowDocument       = $cgi_root."ShowDocument";
$ListDocuments      = $cgi_root."ListDocuments";

$TopicAddForm       = $cgi_root."TopicAddForm";
$AuthorAddForm      = $cgi_root."AuthorAddForm";

# Shell Commands

$Wget   = "/usr/bin/wget -O - --quiet ";
$Tar    = "/bin/tar ";
$Unzip  = "/usr/bin/unzip -q ";

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

# Other Globals

$remote_user = $ENV{REMOTE_USER};
$DBWebMasterEmail = "btev-docdb\@fnal.gov";
$DBWebMasterName  = "BTeV Document Database Administrators";
$Administrator    = "docdbadm";

# Override settings in this file for the test DB 
# and the publicly accessible version

if (-e "PublicGlobals.pm") {
  require "PublicGlobals.pm";
}  

if (-e "TestGlobals.pm") {
  require "TestGlobals.pm";
}  

1;
