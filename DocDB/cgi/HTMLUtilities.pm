#
# Description: Routines to output headers, footers, navigation bars, etc. 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

require "ProjectRoutines.pm";

sub DocDBHeader { 
  my ($Title,$PageTitle,%Params) = @_;
  
  my $Search = $Params{-search}; # Fix search page!
  my $NoBody = $Params{-nobody};
  
  print "<html>\n";
  print "<head>\n";
  print "<title>$title</title>\n";
  
  print "<link rel=\"stylesheet\" href=\"$CSSURLPath/DocDB.css\" type=\"text/css\">\n";

  &ProjectHeader($Title,$PageTitle,$Search); 
  
  if (-e "$CSSDirectory/$ShortProject"."DocDB.css") {
    print "<link rel=\"stylesheet\" href=\"$CSSURLPath/$ShortProject"."DocDB.css\" type=\"text/css\">\n";
  }
  print "</head class=$CSSDirectory>\n";

  if ($Search) {
    print "<body onload=\"selectProduct(document.forms[\'queryform\']);\">\n";
  } else {
    print "<body>\n";
  }  
  
  unless ($NoBody) {
    &ProjectBodyStart($Title,$PageTitle,$Search); 
  }
}

sub DocDBFooter {
  my ($WebMasterEmail,$WebMasterName) = @_;
  print "</body></html>\n";
}

1;
