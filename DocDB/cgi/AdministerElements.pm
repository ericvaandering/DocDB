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

sub ParentSelect {
  my @GroupIDs = keys %SecurityGroups;
  my %GroupLabels = ();

  foreach my $ID (@GroupIDs) {
    $GroupLabels{$ID} = $SecurityGroups{$ID}{NAME}." [".
                        $SecurityGroups{$ID}{DESCRIPTION}."]";
  }  
  
  @GroupIDs = sort numerically @GroupIDs;

  print "<b><a ";
  &HelpLink("parent");
  print "Group:</a></b><br> \n";
  print $query -> scrolling_list(-name => 'parent', -values => \@GroupIDs, 
                                 -labels => \%GroupLabels, 
                                 -size => 10, -multiple => 'true', 
                                 -default => \@SecurityDefaults);
};

sub ChildSelect {
  my @GroupIDs = keys %SecurityGroups;
  my %GroupLabels = ();

  foreach my $ID (@GroupIDs) {
    $GroupLabels{$ID} = $SecurityGroups{$ID}{NAME};
  }  
  
  $ID = 0; # Add dummy security code "Remove"
  push @GroupIDs,$ID; 
  $GroupLabels{$ID} = "Remove all";  
  @GroupIDs = sort numerically @GroupIDs;

  print "<b><a ";
  &HelpLink("child");
  print "Subordinates:</a></b><br> \n";
  print $query -> scrolling_list(-name => 'child', -values => \@GroupIDs, 
                                 -labels => \%GroupLabels, 
                                 -size => 10, -multiple => 'true', 
                                 -default => \@SecurityDefaults);
};

sub GroupEntryBox {
  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("groupentry");
  print "Name:</a></b><br> \n";
  print $query -> textfield (-name => 'name', 
                             -size => 16, -maxlength => 16);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("groupentry");
  print "Description:</a></b><br> \n";
  print $query -> textfield (-name => 'description', 
                             -size => 40, -maxlength => 64);
  print "</td></tr>\n";
  print "<tr><td>\n";
  print $query -> checkbox(-name => "create",  
                           -value => 'create', -label => '');
  print "<b>May create documents?</b>\n";
  print "</td></tr>\n";

  print "<tr><td>\n";
  print $query -> checkbox(-name => "create",  
                           -value => 'create', -label => '');
  print "<b>May administer database?</b> (not implemented)\n";
  print "</td></tr>\n";
  print "</table>\n";
}

1;
