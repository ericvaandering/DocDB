#
#        Name: SecurityHTML.pm
# Description: Routines which supply HTML and form elements related to security
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#


sub SecurityList {
  my @GroupIDs = keys %SecurityGroups;
  my %GroupLabels = ();

  foreach my $ID (@GroupIDs) {
    $GroupLabels{$ID} = $SecurityGroups{$ID}{NAME};
  }  
  
  $ID = 0; # Add dummy security code "Public"
  push @GroupIDs,$ID; 
  $GroupLabels{$ID} = "Public";  
  @GroupIDs = sort numerically @GroupIDs;

  if ($EnhancedSecurity) {
    print "<b><a ";
    &HelpLink("viewgroups");
    print "View:</a></b><br> \n";
  } else {
    print "<b><a ";
    &HelpLink("security");
    print "Security:</a></b><br> \n";
  }
  print $query -> scrolling_list(-name => 'security', -values => \@GroupIDs, 
                                 -labels => \%GroupLabels, 
                                 -size => 10, -multiple => 'true', 
                                 -default => \@SecurityDefaults);
};

sub ModifyList {
  my @GroupIDs = keys %SecurityGroups;
  my %GroupLabels = ();

  foreach my $ID (@GroupIDs) {
    $GroupLabels{$ID} = $SecurityGroups{$ID}{NAME};
  }  
  
  @GroupIDs = sort numerically @GroupIDs;
  if ($AllCanModifyPublic) {
    @ModifyDefaults = @GroupIDs;
  }
  print "<b><a ";
  &HelpLink("modifygroups");
  print "Modify:</a></b><br> \n";
  print $query -> scrolling_list(-name => 'modify', -values => \@GroupIDs, 
                                 -labels => \%GroupLabels, 
                                 -size => 10, -multiple => 'true', 
                                 -default => \@ModifyDefaults);
};

1;
