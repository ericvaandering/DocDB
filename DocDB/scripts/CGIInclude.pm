# Locate the .pm files in the CGI directory and allow their use

if (-e "/var/www/cgi-bin/BTeV/DocDB/cgi/DocDBGlobals.pm") {
  use lib "/var/www/cgi-bin/BTeV/DocDB/cgi/";
}

if (-e "/www/cgi-bin/DocDB/DocDBGlobals.pm") {
  use lib "/www/cgi-bin/DocDB/";
}

1;
  
