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

sub SignoffBox {
  print "<b><a ";
  &HelpLink("signoffs");
  print "Signoffs:</a></b> (one/line)\n";
  print " - <a href=\"Javascript:signoffchooserwindow(\'$SignoffChooser\');\">".
        "<b>Signoff Chooser</b></a><br> \n";
  print $query -> textarea (-name => 'signofflist', -default => $SignoffDefault,
                            -columns => 30, -rows => 6);
};

1;
