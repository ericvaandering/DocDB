#
# Description: Various routines which supply input forms for adminstrative
#              functions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub AdministerActions {
  my %Action = ();

  $Action{Delete} = "Delete";
  $Action{New}    = "New";
  $Action{Modify} = "Modify";
  
  print "<b><a ";
  &HelpLink("admaction");
  print "Action:</a></b><br> \n";
  print $query -> radio_group(-name => "admaction", 
                              -values => \%Action, -default => "-");
};

sub AdministratorPassword {
  print "<b> Administrator password: </b>"; 
  print $query -> password_field(-name => "password", -size => 12, -maxlength => 12);
};

1;
