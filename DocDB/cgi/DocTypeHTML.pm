#     
#        Name: DocTypeHTML.pm
# Description: Routines with form elements and other HTML generating 
#              code pertaining to DocumentTypes.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub DocTypeSelect (;%) { # Scrolling selectable list for doc type search
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  my %DocTypeLabels = ();
  foreach my $DocTypeID (keys %DocumentTypes) {
    $DocTypeLabels{$DocTypeID} = "$DocumentTypes{$DocTypeID}{SHORT} [$DocumentTypes{$DocTypeID}{LONG}]";
  }  
  print "<b><a ";
  &HelpLink("doctype");
  print "Document type:</a></b><br> \n";
  print $query -> scrolling_list(-size => 10, -name => "doctype", 
                              -values => \%DocTypeLabels, $Booleans);
};


sub DocTypeEntryBox (;%) {
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("doctypeentry");
  print "Short Description:</a></b><br> \n";
  print $query -> textfield (-name => 'name', 
                             -size => 20, -maxlength => 32, $Booleans);
  print "</td>\n";
  print "</tr><tr>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("doctypeentry");
  print "Long Description:</a></b><br> \n";
  print $query -> textfield (-name => 'longdesc', 
                             -size => 40, -maxlength => 255, $Booleans);
  print "</td></tr>\n";

  print "</table>\n";

}

1;
