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

sub RevisionIsLatest ($) {
  require "RevisionSQL.pm";
  require "DocumentSQL.pm";

  my ($DocRevID) = @_;
  my $OKDocumentID = 0;
  
  &FetchDocRevisionByID($DocRevID);
  unless ($DocRevisions{$DocRevID}{Obsolete}) {    
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    &FetchDocument($DocumentID);
    if ($DocumentID && $DocRevisions{$DocRevID}{Version} == $Documents{$DocumentID}{NVersions}) {
      $OKDocumentID = $DocumentID;
    }
  }
  
  return $OKDocumentID;
}

1;      
