$db_name   = "BTeVDocTest";
$db_host   = "vchipp.phy.vanderbilt.edu";
$db_rwuser = "docadmin";
$db_rwpass = "docadmin";
$db_rouser = "docadmin";
$db_ropass = "docadmin";

$file_root = "/var/www/html/BTeV/DocDB/";
$web_root  = "http://vuhepv.phy.vanderbilt.edu/BTeV/DocDB/";
$cgi_root  = "http://vuhepv.phy.vanderbilt.edu/cgi-bin/BTeV/DocDB/cgi/";

$ProcessDocumentAdd         = $cgi_root."ProcessDocumentAdd";
$ProcessDocumentReservation = $cgi_root."ProcessDocumentReservation";
$DocumentAddForm            = $cgi_root."ProcessDocumentAddForm";
$DocumentReservationForm    = $cgi_root."ProcessDocumentReservationForm";

1;
