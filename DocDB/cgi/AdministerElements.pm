#
# Description: Various routines which supply input forms for adminstrative
#              functions
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

sub AdministerActions (%) {
  require "Scripts.pm";

  my (%Params) = @_;

  my $Form       =   $Params{-form}  || "";
  my %Matrix     = %{$Params{-matrix}};

  my %Action    = ();
  my %Positions = ();

  $Action{Delete}    = "Delete";
  $Action{New}       = "New";
  $Action{Modify}    = "Modify";
  
  # Actions are a hash, can't rely on order.
  
  my $Position = 0;
  foreach my $Action (keys %Action) { 
    $Positions{$Action}    = $Position;
    ++$Position;
  }
  
  if ($Form) {
    &AdminDisableScripts(-matrix    => \%Matrix, -form => $Form, 
                         -positions => \%Positions); 
  }  
  print "<b><a ";
  &HelpLink("admaction");
  print "Action:</a></b><br> \n";
  print $query -> radio_group(-name => "admaction", 
                              -values => \%Action, -default => "-",
                              -onClick => "disabler_$Form();");
};

sub AdministratorPassword {
  require "Scripts.pm";
  
  print "<b><a ";
  &HelpLink("adminlogin");
  print "Administrator</a> \n";
  print "Username: </b>"; 
  print $query -> textfield(-name => "admuser", -size => 12, -maxlength => 12, 
                            -default => $remote_user);
  print "<b> Password: </b>"; 
  print $query -> password_field(-name      => "password", -size => 12, 
                                 -maxlength => 12);
};

sub GroupEntryBox (%) {
  require "Scripts.pm";

  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("groupentry");
  print "Name:</a></b><br> \n";
  print $query -> textfield (-name => 'name', 
                             -size => 16, -maxlength => 16, $Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("groupentry");
  print "Description:</a></b><br> \n";
  print $query -> textfield (-name => 'description', 
                             -size => 40, -maxlength => 64, $Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("groupperm");
  print "Permissions:</a></b><br> \n";
  print $query -> checkbox(-name => "remove",  
                           -value => 'remove', -label => '',, $Booleans);
  print "<b>Remove existing permissions</b>\n";
  print "<br>\n";

  print $query -> checkbox(-name => "create",  
                           -value => 'create', -label => '', $Booleans);
  print "<b>May create documents</b>\n";
  print "<br>\n";

  print $query -> checkbox(-name => "admin",  
                           -value => 'admin', -label => '', $Booleans);
  print "<b>May administer database</b> \n";
  print "</td></tr>\n";
  print "</table>\n";
}

1;
