$db_name   = "BTeVDocTest";
$db_host   = "vchipp.phy.vanderbilt.edu";
$db_rwuser = "docadmin";
$db_rwpass = "docadmin";
$db_rouser = "docadmin";
$db_ropass = "docadmin";

$file_root   = "/var/www/html/BTeV/DocDB/";
$script_root = "/var/www/cgi-bin/BTeV/DocDB/cgi/";
$web_root    = "http://vuhepv.phy.vanderbilt.edu/BTeV/DocDB/";
$cgi_root    = "http://vuhepv.phy.vanderbilt.edu/cgi-bin/BTeV/DocDB/cgi/";

$htaccess    = ".htaccess";
$help_file   = $script_root."docdb.hlp";

$ProcessDocumentAdd = $cgi_root."ProcessDocumentAdd";
$DocumentAddForm    = $cgi_root."ProcessDocumentAddForm";
$AuthUserFile       = $script_root."htpasswd";
1;
