sub BTeVHeader { 

  my ($title,$page_title) = @_;
  unless ($page_title) {
    $page_title = $title;
  }
  my @title_parts = split /\s+/, $page_title;
  $page_title = join '&nbsp;',@title_parts;
   
  print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";
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
  print "<html>\n";
  print "<head>\n";
  print "<title>$title</title>\n";
  print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n";
  print "<link rel=\"stylesheet\" href=\"/includes/style.css\" type=\"text/css\">\n";
 
  print "</head>\n";

  print "<body bgcolor=\"#FFFFFF\" text=\"#000000\" topmargin=\"6\" leftmargin=\"6\" marginheight=\"6\" marginwidth=\"6\">\n";

  print "<center>\n";
  &SSInclude("begin_atwork_top.html");
  
  print "<div align=\"center\"><font size=\"+2\" color=\"#003399\">$page_title</font></div>\n";
  &SSInclude("end_atwork_top.html");
  &SSInclude("end_table.html");
  print "</center>\n";
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
  my $directory = "/var/www/html/includes/";
  open SSI,"$directory$file";
  my @SSI_lines = <SSI>;
  close SSI;
  print @SSI_lines;
}
  
1;
