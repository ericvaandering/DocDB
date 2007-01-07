#
# Description: Utility routines for authors and institutions
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

sub AuthorRevIDsToAuthorIDs {
  my ($ArgRef) = @_;
  my @AuthorRevIDs = exists $ArgRef->{-authorrevids} ? @{$ArgRef->{-authorrevids}} : ();
  
  my @AuthorIDs = ();
  
  foreach my $AuthorRevID (@AuthorRevIDs) {
    push @AuthorIDs,$RevisionAuthors{$AuthorRevID}{AuthorID};
  }
  return @AuthorIDs;
}

sub IsAuthorListOrdered {
  my ($ArgRef) = @_;
  my @AuthorRevIDs = exists $ArgRef->{-authorrevids} ? @{$ArgRef->{-authorrevids}} : ();
  
  my $Ordered = $FALSE;
  
  foreach my $AuthorRevID (@AuthorRevIDs) {
    if ($RevisionAuthors{$AuthorRevID}{AuthorOrder}) {
      $Ordered = $TRUE;
    }
  }
  return $Ordered;
}

sub FirstAuthorID ($) {
  my ($ArgRef) = @_;
  
  my $DocumentID = exists $ArgRef->{-docid}    ? $ArgRef->{-docid}    : 0;
  my $DocRevID   = exists $ArgRef->{-docrevid} ? $ArgRef->{-docrevid} : 0;

  if ($DocumentID) {
    # May have to fetch
    $DocRevID = $DocRevIDs{$DocumentID}{$Documents{$DocumentID}{NVersions}};
  }
  my @AuthorRevIDs = GetRevisionAuthors($DocRevID);
     @AuthorRevIDs = sort AuthorRevIDsByOrder @AuthorRevIDs;
  my @AuthorIDs    = AuthorRevIDsToAuthorIDs({ -authorrevids => \@AuthorRevIDs, });

  unless (@AuthorIDs) {return undef;}
  
  my $FirstID     = $AuthorIDs[0];

  return $FirstID;
}  

1;
