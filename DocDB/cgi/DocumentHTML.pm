# Description: Subroutines to provide various parts of HTML about documents
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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

sub DocumentTable (%) {
  require "DocumentSQL.pm";
  require "Security.pm";
  require "Sorts.pm";
  
  my %Params = @_;
  
  my $SortBy       =   $Params{-sortby}; 
  my $Reverse      =   $Params{-reverse}; 
  my @DocumentIDs  = @{$Params{-docids}};
  my @Fields       = @{$Params{-fields}}; 
  my %FieldOptions = %{$Params{-fieldoptions}}; 
  
  my %FieldTitles = (Docid => "$ShortProject-doc-#", Updated => "Last Updated");  
  
### Write out the beginning and header of table

  print "<center><table cellpadding=3>\n";

  print "<tr>\n";
  foreach my $Field (@Fields) {
    print "<th>";
    if ($FieldTitles{$Field}) {
      print $FieldTitles{$Field};
    } else {
      print $Field;
    }
    print "</th>\n";
  }  
  print "</tr>\n";

### Sort document IDs, reverse from convention if needed

  if ($SortBy eq "docid") { 
    @DocumentIDs = sort numerically @DocumentIDs;
  } elsif ($SortBy eq "date") {
    @DocumentIDs = sort DocumentByRevisionDate @DocumentIDs; 
  }
       
  if ($Reverse) {
    @DocumentIDs = reverse @DocumentIDs;
  }

  foreach my $DocumentID (@DocumentIDs) {
    &FetchDocument($DocumentID);
    my $Version = $Documents{$DocumentID}{NVersions};
    unless (&CanAccess($DocumentID,$Version)) {next;}
    my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    
    print "<tr>\n";
    foreach my $Field (@Fields) {
      print "<td>";
      if      ($Field eq "Docid") {
        print &NewerDocumentLink(-docid => $DocumentID, -version => $Version, 
                                 -numwithversion => true); 
      } elsif ($Field eq "Title") {
        print &NewerDocumentLink(-docid => $DocumentID, -version => $Version, 
                                 -titlelink => true); 
      } elsif ($Field eq "Author") {
        print &FirstAuthor($DocRevID);
      } elsif ($Field eq "Updated") {
        print &EuroDate($DocRevisions{$DocRevID}{DATE});
      } else {
        print "Unknown field"
      }  
      print "</td>\n";
    }  
    print "</tr>\n";
  }  


  print "</table>\n";
}

sub NewerDocumentLink (%) { # FIXME: Make this the default
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  
  my %Params = @_;
  
  my $DocumentID = $Params{-docid};
  my $DocIDOnly  = $Params{-docidonly} || 0;
  my $NumWithVersion  = $Params{-numwithversion} || 0;
  my $TitleLink  = $Params{-titlelink} || 0;

  &FetchDocument($DocumentID);
  my $Version      = $Documents{$DocumentID}{NVersions};

  my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
  unless ($DocRevID) {
    return "";
  }
    
  my $Link = "<a href=\"$ShowDocument\?docid=$DocumentID";
  $Link .= "\">"; 
  if ($DocIDOnly) {
    $Link .= $DocumentID;
  } elsif ($NumWithVersion) {
    $Link .= $DocumentID."-v".$Version;
  } elsif ($TitleLink) {
    $Link .= $DocRevisions{$DocRevID}{Title};
  } else {
    $Link .= &FullDocumentID($DocumentID,$Version);  
  }
  $Link .=  "</a>";
  return $Link;
}         


1;
