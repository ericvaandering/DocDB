#
# Description: Miscellaneous routines related to cross-referencing documents
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub SetXRefDefault ($) {
  require "XRefSQL.pm"; 
  
  my ($DocRevID) = @_;
  my @DocXRefIDs = &FetchXRefs(-docrevid => $DocRevID);
  my $Text = "";
  foreach my $DocXRefID (@DocXRefIDs) {
    my $DocumentID = $DocXRefs{$DocXRefID}{DocumentID};
    my $Version    = $DocXRefs{$DocXRefID}{Version};
    my $ExtProject = $DocXRefs{$DocXRefID}{Project};
    if ($ExtProject && $ExtProject ne $ShortProject) {
      $Text .= "$ExtProject-";
    }    
    $Text .= $DocumentID;
    if ($Version) {
      $Text .= "-v$Version";
    }    
    $Text .= " ";
  }

  return $Text;
}  

1;
