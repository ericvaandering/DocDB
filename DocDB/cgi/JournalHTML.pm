#
# Description: Routines with form elements and other HTML generating 
#              code pertaining to Journals and References.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub JournalSelect (;%) {
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled} || "0";
  my $Mode     = $Params{-format}   || "0";
 
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  my @JournalIDs = keys %Journals;
  my %JournalLabels = ();
  foreach my $ID (@JournalIDs) {
    $JournalLabels{$ID} = $Journals{$ID}{Abbreviation};
  }
  @JournalIDs = sort @JournalIDs;  #FIXME Sort by abbreviation

  print "<b><a ";
  &HelpLink("journal");
  print "Journal:</a></b><br> \n";
  print $query -> scrolling_list(-name => "journal", -values => \@JournalIDs, 
                                 -labels => \%JournalLabels, -size => 10, 
                                 -default => $JournalDefault, $Booleans);

}

sub JournalEntryBox (;%) {
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled} || "0";
  my $Mode     = $Params{-format}   || "0";
 
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  

  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("journalentry");
  print "Full Name:</a></b><br> \n";
  print $query -> textfield (-name => 'name', 
                             -size => 40, -maxlength => 128, $Booleans);
  print "</td>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("journalentry");
  print "Publisher:</a></b><br> \n";
  print $query -> textfield (-name => 'pub', 
                             -size => 40, -maxlength => 64, $Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("journalentry");
  print "Abbreviation:</a></b><br> \n";
  print $query -> textfield (-name => 'abbr', 
                             -size => 40, -maxlength => 64, $Booleans);
  print "</td>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("journalentry");
  print "URL:</a></b><br> \n";
  print $query -> textfield (-name => 'url', 
                             -size => 40, -maxlength => 240, $Booleans);
  print "</td></tr>\n";
  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("journalentry");
  print "Acronym:</a></b><br> \n";
  print $query -> textfield (-name => 'acronym', 
                             -size => 8, -maxlength => 8, $Booleans);
  print "</td></tr>\n";
  print "</table>\n";

}

sub JournalTable (;$) {
  my ($Mode) = @_;
  print "<table cellpadding=3>\n";
  print "<tr>\n";
  print "<th colspan=5>Existing Journals</td>\n";
  print "</tr>\n";
  print "<tr>\n";
  print "<th>Full Name</td>\n";
  print "<th>Abbreviation</td>\n";
  print "<th>Acronym</td>\n";
  print "<th>Publisher</td>\n";
  print "<th>Website URL</td>\n";
  print "</tr>\n";
  my @JournalIDs = sort keys %Journals; #FIXME Sort by abbreviation
  foreach my $ID (@JournalIDs) {
    print "<tr>\n";
    print "<td>$Journals{$ID}{Name}</td>\n";
    print "<td>$Journals{$ID}{Abbreviation}</td>\n";
    print "<td>$Journals{$ID}{Acronym}</td>\n";
    print "<td>$Journals{$ID}{Publisher}</td>\n";
    print "<td>$Journals{$ID}{URL}</td>\n";
    print "</tr>\n";
  }
  print "</table>\n";
}


1;
