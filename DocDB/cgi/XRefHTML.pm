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
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Cross-References:</span></dt>\n";
    print "</dl>\n";
    print "<ul>\n";
    foreach my $DocXRefID (@DocXRefIDs) {
      my $DocumentID = $DocXRefs{$DocXRefID}{DocumentID};
      my $DocumentLink =  &FullDocumentID($DocumentID).": ";
         $DocumentLink .= &NewerDocumentLink(-docid => $DocumentID, -titlelink => TRUE);
      print "<li>$DocumentLink</li>\n";
    }
    print "</ul>\n";
    print "</div>\n";
  }

### Find and print documents which link to this one

  my @DocXRefIDs = &FetchXRefs(-docid => $DocRevisions{$DocRevID}{DOCID});
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

1;
