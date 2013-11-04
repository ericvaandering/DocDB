#        Name: $RCSfile$
# Description: HTML for document notifications
#
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

sub DocNotifySignup (%) {
  my %Params     = @_;
  my $DocumentID = $Params{-docid};

  my $NeedUserFields = ($UserValidation ne "certificate" && $UserValidation ne "shibboleth");

  print "<div id=\"DocNotifySignup\">\n";
  print $query -> start_multipart_form('POST',$WatchDocument);
  print "<div class=\"InputWrapper\">\n";
  if ($NeedUserFields) {
    print "<hr/>\n";
  }
  print $query -> hidden(-name => 'docid', -default => $DocumentID, -override => 1);

  if ($NeedUserFields) {
    print "<dl>\n";
    print "<dt>Username:</dt><dd>\n";
    print $query -> textfield(-name => 'username', -size => 12, -maxlength => 32);
    print "</dd>\n";
    print "<dt>Password:</dt><dd>\n";
    print $query -> password_field(-name => 'password', -size => 12, -maxlength => 32);
    print "</dd>\n";
    print "</dl>\n";
  }
  print "<div class=\"SubmitCell\">\n";
  print $query -> submit (-value => "Watch Document");
  print "</div>\n";
  print "</div>\n";
  print $query -> end_multipart_form;
  print "</div>\n";
}



1;
