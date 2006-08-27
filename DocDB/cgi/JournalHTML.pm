#
# Description: Routines with form elements and other HTML generating 
#              code pertaining to Journals and References.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

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

  print FormElementTitle(-helplink => "journal", -helptext => "Journal");
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
  print FormElementTitle(-helplink => "journalentry", -helptext => "Full Name");
  print $query -> textfield (-name => 'name', 
                             -size => 40, -maxlength => 128, $Booleans);
  print "</td>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "journalentry", -helptext => "Publisher");
  print $query -> textfield (-name => 'pub', 
                             -size => 40, -maxlength => 64, $Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print FormElementTitle(-helplink => "journalentry", -helptext => "Abbreviation");
  print $query -> textfield (-name => 'abbr', 
                             -size => 40, -maxlength => 64, $Booleans);
  print "</td>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "journalentry", -helptext => "URL");
  print $query -> textfield (-name => 'url', 
                             -size => 40, -maxlength => 240, $Booleans);
  print "</td></tr>\n";
  print "<tr><td>\n";
  print FormElementTitle(-helplink => "journalentry", -helptext => "Acronym");
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

sub ReferenceForm {
  require "MiscSQL.pm";
  
  GetJournals();

  my @JournalIDs = keys %Journals;
  my %JournalLabels = ();
  foreach my $ID (@JournalIDs) {
    $JournalLabels{$ID} = $Journals{$ID}{Acronym};
  }
  @JournalIDs = sort @JournalIDs;  #FIXME Sort by acronym
  unshift @JournalIDs,0; $JournalLabels{0} = "----"; # Null Journal
  my $ElementTitle = FormElementTitle(-helplink  => "reference", 
                                      -helptext  => "Journal References");
  print $ElementTitle,"\n";                                     

  my @ReferenceIDs = (@ReferenceDefaults,0);
  
  print "<table class=\"LowPaddedTable\">\n";
  foreach my $ReferenceID (@ReferenceIDs) { 
    print "<tr>\n";
    my $JournalDefault = $RevisionReferences{$ReferenceID}{JournalID};
    my $VolumeDefault  = $RevisionReferences{$ReferenceID}{Volume}   ;
    my $PageDefault    = $RevisionReferences{$ReferenceID}{Page}     ;
    print "<td><b>Journal: </b>\n";
    print $query -> popup_menu(-name => "journal", -values => \@JournalIDs, 
                                   -labels => \%JournalLabels,
                                   -default => $JournalDefault);
    print "</td>";
    print "<td><b>Volume:</b> \n";
    print $query -> textfield (-name => 'volume', 
                               -size => 8, -maxlength => 8, 
                               -default => $VolumeDefault);
    print "</td>";
    print "<td><b>Page:</b> \n";
    print $query -> textfield (-name => 'page', 
                               -size => 8, -maxlength => 16, 
                               -default => $PageDefault);
    print "</td></tr>\n";                           
  }
  print "</table>\n";
}

1;
