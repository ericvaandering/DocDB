#
# Description: Input and output routines related to cross-referencing documents
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub PrintXRefInfo ($) {
  require "XRefSQL.pm"; 
  require "DocumentHTML.pm";
  require "RevisionSQL.pm";
  
  my ($DocRevID) = @_;
  
### Find and print documents this revision links to  
  
  my @DocXRefIDs = &FetchXRefs(-docrevid => $DocRevID);
  if (@DocXRefIDs) {
    print "<div id=\"XRefs\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Related Documents:</span></dt>\n";
    print "</dl>\n";
    print "<ul>\n";
    foreach my $DocXRefID (@DocXRefIDs) {
      my $DocumentLink = "";
      my $DocumentID = $DocXRefs{$DocXRefID}{DocumentID};
      my $Version    = $DocXRefs{$DocXRefID}{Version};
      my $ExtProject = $DocXRefs{$DocXRefID}{Project};
      if ($ExtProject && $ExtProject ne $ShortProject) {
        my $ExternalDocDBID = FetchExternalDocDBByName($ExtProject);
        $DocumentLink = "External link to $ExtProject DocDB $ExternalDocDBID ";
      } else {
        if ($Version) {
          $DocumentLink =  &FullDocumentID($DocumentID,$Version).": ";
          $DocumentLink .= &NewerDocumentLink(-docid => $DocumentID, -version => $Version, -titlelink => $TRUE);
        } else { 
          $DocumentLink =  &FullDocumentID($DocumentID).": ";
          $DocumentLink .= &NewerDocumentLink(-docid => $DocumentID, -titlelink => $TRUE);
        }
      }    
      print "<li>$DocumentLink</li>\n";
    }
    print "</ul>\n";
    print "</div>\n";
  }

### Find and print documents which link to this one

  my @RawDocXRefIDs = &FetchXRefs(-docid => $DocRevisions{$DocRevID}{DOCID});
  
  my @DocXRefIDs = ();
  
  foreach my  $DocXRefID (@RawDocXRefIDs) { # Remove links to other projects, versions
    my $ExtProject = $DocXRefs{$DocXRefID}{Project};
    my $Version    = $DocXRefs{$DocXRefID}{Version};
    if ($ExtProject eq $ShortProject || !$ExtProject) {
      if ($Version) {
        if ($Version == $DocRevisions{$DocRevID}{Version}) {
          push @DocXRefIDs,$DocXRefID;
        } 
      } else {
        push @DocXRefIDs,$DocXRefID;
      }  
    }
  }    
    
  if (@DocXRefIDs) {
    print "<div id=\"XReffedBy\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Referenced by:</span></dt>\n";
    print "</dl>\n";
    print "<ul>\n";
    my %SeenDocument = ();
    foreach my $DocXRefID (@DocXRefIDs) {
      my $DocRevID = $DocXRefs{$DocXRefID}{DocRevID};
      &FetchDocRevisionByID($DocRevID);
      if ($DocRevisions{$DocRevID}{Obsolete}) {
        next;
      }
      my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
      if ($DocumentID && !$SeenDocument{$DocumentID}) {
        my $DocumentLink  = &FullDocumentID($DocumentID).": ";
           $DocumentLink .= &NewerDocumentLink(-docid => $DocumentID, -titlelink => TRUE);
        print "<li>$DocumentLink</li>\n";
        $SeenDocument{$DocumentID} = TRUE;
      }
    }
    print "</ul>\n";
    print "</div>\n";
  }
}

sub ExternalDocDBSelect (;%) {
  require "FormElements.pm";
  require "XRefSQL.pm";
  require "Sorts.pm";
 
  my (%Params) = @_;

  my $Disabled = $Params{-disabled} || "0";
  my $Multiple = $Params{-multiple} || "0";
  my $Required = $Params{-required} || "0";
  my $Format   = $Params{-format}   || "short";
  my @Defaults = @{$Params{-default}};
  my $OnChange = $Params{-onchange} || undef;

  my %Options = ();
 
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }  
  if ($OnChange) {
    $Options{-onchange} = $OnChange;
  }  

  &GetAllExternalDocDBs; 
  my @ExternalDocDBIDs = keys %ExternalDocDBs;
  my %Labels        = ();
  foreach my $ExternalDocDBID (@ExternalDocDBIDs) {
    if ($Format eq "full") {
      $Labels{$ExternalDocDBID} = $ExternalDocDBs{$ExternalDocDBID}{Project}.
      ":".$ExternalDocDBs{$ExternalDocDBID}{Description}; 
    } else {  
      $Labels{$ExternalDocDBID} = $ExternalDocDBs{$ExternalDocDBID}{Project}; 
    }
  }      
  
  my $ElementTitle = &FormElementTitle(-helplink => "extdocdb", -helptext => "Project", 
                                       -required => $Required);

  print $ElementTitle;
  print $query -> scrolling_list(-name     => "externaldocdbs",  -values  => \@ExternalDocDBIDs, 
                                 -labels   => \%Labels,       -size    => 10, 
                                 -multiple => $Multiple,      -default => \@Defaults,
                                 %Options);
}

1;
