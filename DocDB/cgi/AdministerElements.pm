#        Name: AdministerElements.pm
# Description: Various routines which supply input forms for administrative
#              functions
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2018 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub AdministerActions (%) {
  require "FormElements.pm";

  my (%Params) = @_;

  my $Form = $Params{-form}  || "";
  my $AddTransfer = $Params{-addTransfer}  || $FALSE;

  my @Action = ('New', 'Delete', 'Modify');

  if ($AddTransfer) {
    $Action{Transfer}    = "Transfer";
  }
  print FormElementTitle(-helplink => "admaction", -helptext => "Action");
  print $query -> radio_group(-name => "admaction",
                              -values => \@Action, -default => "-",
                              -onclick => "disabler_$Form();");
};

sub AdministratorPassword {
  my ($ArgRef) = @_;
  my $Layout = exists $ArgRef->{-layout} ? $ArgRef->{-layout} : "horizontal";

  require "FormElements.pm";
  require "DBColumnSizes.pm";

  my ($HTML,$NoColon,$NoBreak);

  if ($Layout eq "horizontal") {
    $NoBreak = $TRUE;
    $NoColon = $TRUE;
  }

  $HTML .= FormElementTitle(-helplink => "adminlogin",    -nobreak => $NoBreak,
                            -helptext => "Administrator", -nocolon => $NoColon,);
  $HTML .= "<strong> Username: </strong>";
  $HTML .= $query -> textfield(-name => "admuser", -size => 12,
                               -maxlength => $DBColumnSize{MySQLUser}{User},
                               -default => $remote_user);
  if ($Layout eq "vertical") {$HTML .= '<br/>';}
  $HTML .= "<strong> Password: </strong>";
  $HTML .= $query -> password_field(-name      => "password", -size => 12,
                                    -maxlength => $DBColumnSize{MySQLUser}{Password});
  print $HTML;
};

sub AdminRegardless {
  require "FormElements.pm";

  print FormElementTitle(-helplink => "admforce", -helptext => "Force Delete");
  print $query -> checkbox(-name => "admforce", -value => 1, -label => 'Yes');
}

sub GroupEntryBox (%) {
  require "Scripts.pm";
  require "FormElements.pm";

  my (%Params) = @_;

  my $Disabled = $Params{-disabled}  || $FALSE;

  my %Options = ();
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }

  print "<td>\n";
  print FormElementTitle(-helplink => "groupentry", -helptext => "Name");
  print $query -> textfield (-name => 'name',
                             -size => 16, -maxlength => 16, %Options);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print FormElementTitle(-helplink => "groupentry", -helptext => "Description");
  print $query -> textfield (-name => 'description',
                             -size => 40, -maxlength => 64, %Options);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print FormElementTitle(-helplink => "groupperm", -helptext => "Permissions");
  print $query -> checkbox(-name  => "view",   -value => 'view',
                           -label => '', %Options);
  print "May view documents<br/>\n";

  print $query -> checkbox(-name  => "create", -value => 'create',
                           -label => '', %Options);
  print "May create documents<br/>\n";

  print $query -> checkbox(-name  => "admin",  -value => 'admin',
                           -label => '', %Options);
  print "May administer database<br/>\n";

  print $query -> checkbox(-name  => "remove", -value => 'remove',
                           -label => '', %Options);
  print "Remove existing permissions\n";

  print "</td></tr>\n";
}

1;
