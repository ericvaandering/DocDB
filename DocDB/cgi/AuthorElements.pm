#
# Description: Various routines which supply input forms related to authors and
#              institutions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2004 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License 
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


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
