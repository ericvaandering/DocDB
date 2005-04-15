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

  my @ScriptParts = split /\//,$ENV{SCRIPT_NAME};
  my $ScriptName  = pop @ScriptParts;

  unless ($PageTitle) { 
    $PageTitle = $Title;
  }  
  
#  if ($ScriptName eq "ModifyHome") {
#    print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
#    print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"DTD/xhtml1-transitional.dtd\">\n";
#  } else {
    print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"
          \"http://www.w3.org/TR/html4/loose.dtd\">";
#  }
  print "<html>\n";
  print "<head>\n";
  print "<title>$Title</title>\n";
  
  # Include DocDB style sheets
  
  print "<link rel=\"stylesheet\" href=\"$CSSURLPath/DocDB.css\" type=\"text/css\" />\n";
  if (-e "$CSSDirectory/DocDB_IE.css") {
    print "<!--[if IE]>\n";
    print "<link rel=\"stylesheet\" href=\"$CSSURLPath/DocDB_IE.css\" type=\"text/css\" />\n";
    print "<![endif]-->\n"; 
  }
  if (-e "$CSSDirectory/DocDB$ScriptName.css") {
    print "<link rel=\"stylesheet\" href=\"$CSSURLPath/DocDB$ScriptName.css\" type=\"text/css\" />\n";
  }
  if (-e "$CSSDirectory/DocDB$ScriptName"."_IE.css") {
    print "<link rel=\"stylesheet\" href=\"$CSSURLPath/DocDB$ScriptName\_IE.css\" type=\"text/css\" />\n";
  }
   
  # Include projects DocDB style sheets 
   
  if (-e "$CSSDirectory/$ShortProject"."DocDB.css") {
    print "<link rel=\"stylesheet\" href=\"$CSSURLPath/$ShortProject"."DocDB.css\" type=\"text/css\" />\n";
  }
  if (-e "$CSSDirectory/$ShortProject"."DocDB_IE.css") {
    print "<!--[if IE]>\n";
    print "<link rel=\"stylesheet\" href=\"$CSSURLPath/$ShortProject"."DocDB_IE.css\" type=\"text/css\" />\n";
    print "<![endif]-->\n"; 
  }
  if (-e "$CSSDirectory/$ShortProject"."DocDB".$ScriptName.".css") {
    print "<link rel=\"stylesheet\" href=\"$CSSURLPath/$ShortProject"."DocDB".$ScriptName.".css\" type=\"text/css\" />\n";
  }

  if (defined &ProjectHeader) {
    &ProjectHeader($Title,$PageTitle); 
  }

  print "</head>\n";

  if ($Search) {
    print "<body onload=\"selectProduct(document.forms[\'queryform\']);\">\n";
  } else {
    print "<body>\n";
  }  
  
  if (defined &ProjectBodyStart && !$NoBody) {
    &ProjectBodyStart($Title,$PageTitle); 
  }
}

sub DocDBFooter {
  require "ResponseElements.pm";
  
  &DebugPage("At DocDBFooter");
  
  my ($WebMasterEmail,$WebMasterName) = @_;
  
  
  if (defined &ProjectFooter) {
    &ProjectFooter($WebMasterEmail,$WebMasterName); 
  }
  print "</body></html>\n";
}

1;
