#
# Description: Various routines which supply input forms related to authors and
#              institutions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub InstitutionEntryBox {
  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("instentry");
  print "Short Name:</a></b><br> \n";
  print $query -> textfield (-name => 'short', 
                             -size => 30, -maxlength => 40);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("instentry");
  print "Long Name:</a></b><br> \n";
  print $query -> textfield (-name => 'long', 
                             -size => 40, -maxlength => 80);
  print "</td>\n";
  print "</tr></table>\n";
}

1;
