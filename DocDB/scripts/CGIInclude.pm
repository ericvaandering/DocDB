# Locate the .pm files in the CGI directory and allow their use
# Modify this file if your own files aren't in one of the "standard" locations

if (-e "/var/www/cgi-bin/DocDB/DocDBGlobals.pm") {
  use lib "/var/www/cgi-bin/DocDB/";
  use lib ".";
} elsif (-e "/www/BTEV/cgi-bin/DocDB/DocDBGlobals.pm") {
  use lib "/www/BTEV/cgi-bin/DocDB/";
  use lib ".";
} elsif (-e "../cgi/DocDBGlobals.pm") {
  use lib "../cgi/";
  use lib ".";
}

1;
  
