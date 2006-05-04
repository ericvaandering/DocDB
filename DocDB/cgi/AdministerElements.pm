#
# Description: Various routines which supply input forms for adminstrative
#              functions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub AdministerActions (%) {
  require "FormElements.pm";

  my (%Params) = @_;

  my $Form       =   $Params{-form}  || "";

  my %Action    = ();

  $Action{Delete}    = "Delete";
  $Action{New}       = "New";
  $Action{Modify}    = "Modify";
  print FormElementTitle(-helplink => "admaction", -helptext => "Action");
  print $query -> radio_group(-name => "admaction", 
                              -values => \%Action, -default => "-",
                              -onclick => "disabler_$Form();");
};

sub AdministratorPassword {
  print FormElementTitle(-helplink => "adminlogin",    -nobreak => $TRUE,
                         -helptext => "Administrator", -nocolon => $TRUE,);
  print "<strong> Username: </strong>"; 
  print $query -> textfield(-name => "admuser", -size => 12, -maxlength => 12, 
                            -default => $remote_user);
  print "<strong> Password: </strong>"; 
  print $query -> password_field(-name      => "password", -size => 12, 
                                 -maxlength => 12);
};

sub AdminRegardless {
  print FormElementTitle(-helplink => "admforce", -helptext => "Force Action");
  print $query -> checkbox(-name => "admforce", -value => 1, -label => 'Yes');
}  

sub GroupEntryBox (%) {
  require "Scripts.pm";

  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || $FALSE;
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print '<table class="MedPaddedTable"><tr>';
  print "<td>\n";
  print FormElementTitle(-helplink => "groupentry", -helptext => "Name");
  print $query -> textfield (-name => 'name', 
                             -size => 16, -maxlength => 16, $Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print FormElementTitle(-helplink => "groupentry", -helptext => "Description");
  print $query -> textfield (-name => 'description', 
                             -size => 40, -maxlength => 64, $Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print FormElementTitle(-helplink => "groupperm", -helptext => "Permissions");
  print $query -> checkbox(-name => "create",  
                           -value => 'create', -label => '', $Booleans);
  print "<strong>May create documents</strong>\n";
  print "<br/>\n";

  print $query -> checkbox(-name => "admin",  
                           -value => 'admin', -label => '', $Booleans);
  print "<strong>May administer database</strong> \n";
  print "<br/>\n";
  print $query -> checkbox(-name => "remove",  
                           -value => 'remove', -label => '',, $Booleans);
  print "<strong>Remove existing permissions</strong>\n";

  print "</td></tr>\n";
  print "</table>\n";
}

1;
