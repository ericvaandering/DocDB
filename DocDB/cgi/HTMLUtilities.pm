#
# Description: Routines to output headers, footers, navigation bars, etc. 
#              Should be customized for each installation
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#
# A global variable $Public is used to (when set) remove elements from the
# nav-bars that the public has no interest in. The variable is global
# and can control the style of your headers and footers too.
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

sub DocDBNavBar {
  
# This routine prints the navigation bar just above the footer on the
# page. You can customize for your installation and include an optional
# extra description and URL (for a related page, for instance). 

  my ($ExtraDesc,$ExtraURL) = @_;

  print "<p><div align=\"center\">\n";
  if ($ExtraDesc && $ExtraURL) {
    print "[&nbsp;<a href=\"$ExtraURL\"l>$ExtraDesc</a>&nbsp;]&nbsp;\n";
  } 
  print "[&nbsp;<a href=\"$MainPage\">DocDB&nbsp;Home</a>&nbsp;]&nbsp;\n";
  unless ($Public) {
    print "[&nbsp;<a href=\"$DocumentAddForm?mode=add\">New</a>&nbsp;]&nbsp;\n";
    print "[&nbsp;<a href=\"$DocumentAddForm\">Reserve</a>&nbsp;]&nbsp;\n";
  }
  print "[&nbsp;<a href=\"$SearchForm\">Search</a>&nbsp;]\n";
  print "[&nbsp;<a href=\"$LastModified?days=$LastDays\">Last&nbsp;$LastDays&nbsp;Days</a>&nbsp;]\n";
  print "[&nbsp;<a href=\"$ListAuthors\">List&nbsp;Authors</a>&nbsp;]\n";
  print "[&nbsp;<a href=\"$ListTopics\">List&nbsp;Topics</a>&nbsp;]\n";
  unless ($Public) {
    print "[&nbsp;<a href=\"$HelpFile\">Help</a>&nbsp;]\n";
  } 
  print "</div>\n";
}

1;
