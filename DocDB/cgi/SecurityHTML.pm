#
#        Name: SecurityHTML.pm
# Description: Routines which supply HTML and form elements related to security
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#


sub ViewList {
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

#    &SecurityList(-addpublic => 'true',
#                  -name      => 'meetingviewgroups', 
#                  -helplink  => 'meetingviewgroups',
#                  -helptext  => 'Viewable by',
#                  -default   => \@Default);

sub SecurityList (%) {
  require "SecuritySQL.pm";
  
  my (%Params) = @_;
  
  my $AddPublic =   $Params{-addpublic} || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Groups";
  my $Multiple  =   $Params{-multiple}  || "true";
  my $Name      =   $Params{-name}      || "groups";
  my $Size      =   $Params{-size}      || 10;
  my @Default   = @{$Params{-default}};

  &GetSecurityGroups;
  
  my @GroupIDs = keys %SecurityGroups;
  my %GroupLabels = ();

  foreach my $GroupID (@GroupIDs) {
    $GroupLabels{$GroupID} = $SecurityGroups{$GroupID}{NAME};
  }  
  
  if ($AddPublic) { # Add dummy security code for "Public"
    my $ID = 0; 
    push @GroupIDs,$ID; 
    $GroupLabels{$ID} = "Public";
  }
      
  @GroupIDs = sort numerically @GroupIDs;

  if ($HelpLink) {
    print "<b><a ";
    &HelpLink($HelpLink);
    print "$HelpText:</a></b><br> \n";
  }
  
  print $query -> scrolling_list(-name => $Name, -values => \@GroupIDs, 
                                 -labels => \%GroupLabels, 
                                 -size => $Size, -multiple => $Multiple, 
                                 -default => \@Default);
};

1;
