#
# Description: Routines to output headers, footers, navigation bars, etc. 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

require "ProjectRoutines.pm";

sub DocDBHeader { 
  my ($Title,$PageTitle,%Params) = @_;
  
  my $Search = $Params{-search};
  my $NoBody = $Params{-nobody};
  
  print "<html>\n";
  print "<head>\n";
  print "<title>$title</title>\n";
  
  print "<link rel=\"stylesheet\" href=\"$CSSDirectory/DocDB.css\" type=\"text/css\">\n";

  &ProjectHeader($Title,$PageTitle,$Search); 
  
  if (-e "$CSSDirectory/$Project"."DocDB.css") {
    print "<link rel=\"stylesheet\" href=\"$CSSDirectory/$Project"."DocDB.css\" type=\"text/css\">\n";
  }
  print "</head>\n";

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
