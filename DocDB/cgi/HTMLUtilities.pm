#
# Author: Eric Vaandering (ewv@fnal.gov)
#
# This set of perl subroutines provides a method in CGI scripts to use the
# standard BTeV headers and footers. Since the output of CGI scripts cannot
# use server side includes, we use perl to manually read in the files and
# print them to standard output. 
#
# You must supply the variable $SSIDirectory which is the directory where 
# the includes live.
# 
# This file provides 4 subroutines:
#
# BTeVHeader($Title,$PageTitle)
#    Displays the full BTeV header, with nav bar. $Title is the HTML title,
#    $PageTitle is the title above the nav bar on the page. If you don't supply
#    $PageTitle, $Title is used in both places
#
# BTeVStyle($Title,$PageTitle)
#    Same as BTeVHeader, but no nav bar
#
# BTeVFooter($WebMasterEmail,$WebMasterName)
#    Prints the FNAL version of the footer. The parameters are the e-mail and
#    name of the person responsible for the page. If omitted, they default
#    to the BTeV webmaster
#
# OffsiteBTeVFooter($WebMasterEmail,$WebMasterName)
#    The same, but without the FNAL legal disclaimer
#
# The simplest CGI script would then look like this: 
#
#  require "BTeVHeaders.pm";
#  $SSIDirectory = "/var/www/html/includes/";
#  print "Content-type: text/html \n";
#  print "\n";             #End of HTTP header, now start the page
#                                                                                                                                                    
#  &BTeVHeader("My title");
#  print "Some more HTML here";                                                                                                                                                  
#  &BTeVFooter("me@wherever.edu","My name");
#  exit;

sub BTeVHeader { 

  my ($title,$page_title) = @_;
  unless ($page_title) {
    $page_title = $title;
  }
  my @title_parts = split /\s+/, $page_title;
  $page_title = join '&nbsp;',@title_parts;
   
  print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";

# The header below activates strict mode in Netscape 6 which causes 
# weird reflows in the document. But, the navbar is faster. Choose wisely.
#
#  print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n";
#  print "         \"http://www.w3.org/TR/html4/loose.dtd\">\n";

  print "<html>\n";
  print "<head>\n";
  print "<title>$title</title>\n";
  print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n";
  print "<link rel=\"stylesheet\" href=\"/includes/style.css\" type=\"text/css\">\n";
 
  &SSInclude("navbar_header.html");
  print "</head>\n";

  print "<body bgcolor=\"#FFFFFF\" text=\"#000000\" topmargin=\"6\" leftmargin=\"6\" marginheight=\"6\" marginwidth=\"6\">\n";

  &SSInclude("atwork_menuload.html");
  &SSInclude("begin_atwork_top.html");
  
  print "<div align=\"center\"><font size=\"+2\" color=\"#003399\">$page_title</font></div>\n";
  &SSInclude("end_atwork_top.html");
  &SSInclude("atwork_navbar.html");
  &SSInclude("end_table.html");
  print "<hr>\n";
}

sub BTeVStyle { # Same as above, but no nav-bar

  my ($title,$page_title) = @_;
  unless ($page_title) {
    $page_title = $title;
  }
  my @title_parts = split /\s+/, $page_title;
  $page_title = join '&nbsp;',@title_parts;
   
  print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";

#  print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n";
#  print "         \"http://www.w3.org/TR/html4/loose.dtd\">\n";

  print "<html>\n";
  print "<head>\n";
  print "<title>$title</title>\n";
  print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n";
  print "<link rel=\"stylesheet\" href=\"/includes/style.css\" type=\"text/css\">\n";
 
  print "</head>\n";

  print "<body bgcolor=\"#FFFFFF\" text=\"#000000\" topmargin=\"6\" leftmargin=\"6\" marginheight=\"6\" marginwidth=\"6\">\n";

  &SSInclude("begin_atwork_top.html");
  
  print "<div align=\"center\"><font size=\"+2\" color=\"#003399\">$page_title</font></div>\n";
  &SSInclude("end_atwork_top.html");
  &SSInclude("end_table_nonav.html");
  print "<hr>\n";
}

sub OffsiteBTeVFooter {
  my ($WebMaster) = @_;
  unless ($WebMaster) {
    $WebMaster = "BTeVWebMaster\@fnal.gov";
  }
     
  print "<hr>\n";
  print "<div align=\"center\">\n";
  &SSInclude("atwork_bottomnav.html");
  print "</div>\n";
  print "<div align=\"left\"> <i><font size=\"-1\">\n";
  print "<A HREF=\"mailto:$WebMaster\">$WebMaster</A></font></i></div>\n";
  &SSInclude("offsite_footer.shtml");
  print "</body></html>\n";
}

sub BTeVFooter {
  my ($WebMasterEmail,$WebMasterName) = @_;
  unless ($WebMasterEmail) {
    $WebMasterEmail = "BTeVWebMaster\@fnal.gov";
  }
  unless ($WebMasterName) {
    $WebMasterName  = $WebMasterEmail;
  }
     
  print "<hr>\n";
  print "<div align=\"center\">\n";
  &SSInclude("atwork_bottomnav.html");
  print "</div>\n";
  print "<div align=\"left\"> <i><font size=\"-1\">\n";
  print "<A HREF=\"mailto:$WebMasterEmail\">$WebMasterName</A></font></i></div>\n";
  &SSInclude("full_fermi_footer.shtml");
  print "</body></html>\n";
}

sub SSInclude {
  my ($file) = @_;
  open SSI,"$SSIDirectory$file";
  my @SSI_lines = <SSI>;
  close SSI;
  print @SSI_lines;
}
  
1;
