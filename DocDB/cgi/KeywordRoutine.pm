#
# Description: These are routines that are specific to your installation and 
#              should be customized for your needs. This file is a template
#              only. Make a copy of this file as ProjectRoutines.pm (no
#              "template") and make your changes there. 
#
# Author Lynn Garren (garren@fnal.gov)
#    Modified: 
#
# This file should be integrated with ProjectRoutines.pm.template


sub KeywordShortText {

# This is the information printed at the start of the keyword list. 
# It should at least contain pointers to the various listing options.

print "Please use the following keywords to facilitate searches.  
Note that spaces are NOT allowed in keywords. 
To suggest additional keywords, send mail to  
<a href=\"mailto:beams-docdb\@fnal.gov\">beams-docdb</a>.
The links on the 
<a href=\"$KeywordLongListing\">detailed listing</a> 
page will do a search of the database for all instances of a single keyword.
Use the <a href=\"$SearchForm\" target=\"_blank\">search form</a> 
to do a more complicated search.
<br>\n";

print "<p>\n";
print "The old <a href=\"/doc/tevatron-keywords.html\">tevatron keyword</a> 
list and the <a href=/doc/>original DocDB keyword list</a> 
are provided for comparison.
<br>\n";

}

sub KeywordLongText {

# This is the information printed at the start of the detailed keyword list. 
# It should at least contain pointers to the various listing options.

print "Please use the following keywords to facilitate searches.  
Note that spaces are NOT allowed in keywords. 
To suggest additional keywords, send mail to  
<a href=\"mailto:beams-docdb\@fnal.gov\">beams-docdb</a>.
The links below will do a search of the database for all instances of a single keyword.
Use the <a href=\"$SearchForm\" target=\"_blank\">search form</a> 
to do a more complicated search.
<br>\n";

print "<p>\n";
print "The old <a href=\"/doc/tevatron-keywords.html\">tevatron keyword</a> 
list and the <a href=/doc/>original DocDB keyword list</a> 
are provided for comparison.
<br>\n";

}

  
1;
