#
# Description: Configuration file for the DocDB. Set variables 
#              for server names, accounts, and command paths here.
#              This file is included in every DocDB program.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#
# A global variable $Public is used to (when set) remove elements from the
# nav-bars that the public has no interest in.
# 

require "BTeVHTML.pm";

sub DocDBHeader { 
  my ($Title,$PageTitle,$Search) = @_;
  &BTeVHeader($Title,$PageTitle,$Search);
  return;

# This routine is reponsible for whatever you want to put as a header on the
# page.
# 
# $Title is for the <title> element while $PageTitle is the title of the page
# you may put in the text of the page.
#
# The simplest possible routine should look something like this:

  print "<html>\n";
  print "<head>\n";
  print "<title>$Title</title>\n";
  print "</head>\n";
  if ($Search) {
    print "<body onload=\"selectProduct(document.forms[\'queryform\']);\">\n";
  } else {  
    print "<body>\n";
  }  
}

sub DocDBFooter {
  my ($WebMasterEmail,$WebMasterName) = @_;
  &BTeVFooter($WebMasterEmail,$WebMasterName);
  return;

# This routine is reponsible for whatever you want to put as a footer on the
# page. 
#
# Paramters are supplied for the name and e-mail address of the person
# responsible for the pages
#
# The simplest possible routine should look something like this:
  
  print "</body></html>\n";
}

1;
