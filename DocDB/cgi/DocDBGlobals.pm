# DB settings
$db_name   = "BTeVDocTest";
$db_host   = "vchipp.phy.vanderbilt.edu";
$db_rwuser = "docadmin";
$db_rwpass = "docadmin";
$db_rouser = "docadmin";
$db_ropass = "docadmin";

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

# Shell Commands

$Wget   = "/usr/bin/wget -O - --quiet ";
$Tar    = "/bin/tar ";
$Unzip  = "/usr/bin/unzip -q ";

# Other Globals

$remote_user = $ENV{REMOTE_USER};
$DBWebMasterEmail = "ewv\@fnal.gov,garren\@fnal.gov";
$DBWebMasterName  = "Eric Vaandering, Lynn Garren";

1;
