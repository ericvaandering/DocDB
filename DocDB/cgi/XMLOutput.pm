#
# Author Eric Vaandering (ewv@fnal.gov)
#

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

use XML::Twig;

sub NewXMLOutput {
  require "DocDBVersion.pm";
  $XMLTwig = XML::Twig -> new();
  $DocDBXML = XML::Twig::Elt -> new(docdb => {version      => $DocDBVersion, 
                                              href         => $web_root,
                                              project      => $Project,
                                              shortproject => $ShortProject,
                                             } );
  return $DocDBXML;
}

sub XMLHeader {
  my $Header;
  $Header .= "Content-Type: text/xml\n";
  $Header .= "\n";
  $Header .= '<?xml version="1.0" encoding="ISO-8859-1"?>'."\n";
  return $Header;
}

sub GetXMLOutput {
  $XMLTwig -> set_pretty_print('indented');
  my $XMLText = $DocDBXML -> sprint();
  return $XMLText;
}

sub DocumentXMLOut {
  my ($ArgRef) = @_;
  my $DocumentID = exists $ArgRef->{-docid}   ? $ArgRef->{-docid}   : 0;
  my $Version    = exists $ArgRef->{-version} ? $ArgRef->{-version} : "lastaccesible";

  unless ($DocumentID) { return undef; }
  
  my %Attributes = ();
  $Attributes{id}           = $DocumentID;
  $Attributes{href}         = $ShowDocument."?docid=$DocumentID";
  
  if ($Documents{$DocumentID}{Relevance}) { 
    $DocAttributes{relevance} = $Documents{$DocumentID}{Relevance};
  }
  
  my $DocumentXML = XML::Twig::Elt -> new(document => \%Attributes );

  if ($Version eq "lastaccesible") {
    require "Security.pm";
    $Version = LastAccess($DocumentID);
    my $DocRevID = FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    my $RevisionXML = RevisionXMLOut( {-docrevid => $DocRevID} );
    if ($RevisionXML) {
      $RevisionXML -> paste(last_child => $DocumentXML);
    }
  }

  return $DocumentXML;
}

sub RevisionXMLOut {
  my ($ArgRef) = @_;
  my $DocRevID = exists $ArgRef->{-docrevid} ? $ArgRef->{-docrevid} : 0;
  my $Authors  = exists $ArgRef->{-authors}  ? $ArgRef->{-authors}  : $TRUE;
  
  require "Security.pm";

  my $Version    = $DocRevisions{$DocRevID}{Version};
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID}  ;
 
  unless ($DocRevID && CanAccess($DocumentID,$Version) ) {
    return undef;
  }
  
  my %Attributes = ();
  
  $Attributes{docid}    = $DocumentID;
  $Attributes{version}  = $Version;
  $Attributes{modified} = $DocRevisions{$DocRevID}{Date};
  $Attributes{href}     = $ShowDocument."?docid=$DocumentID&amp;version=$Version";
  
  my $RevisionXML = XML::Twig::Elt -> new(docrevision => \%Attributes );
  XML::Twig::Elt -> new("title",$DocRevisions{$DocRevID}{Title}) -> paste(first_child => $RevisionXML);

  if ($Authors) {
    require "AuthorSQL.pm";
    my @AuthorIDs = GetRevisionAuthors($DocRevID);
    foreach my $AuthorID (@AuthorIDs) {
      my $AuthorXML = AuthorXMLOut( {-authorid => $AuthorID} );
      if ($AuthorXML) {
        $AuthorXML -> paste(last_child => $RevisionXML);
      }  
    }
  }
         
  return $RevisionXML;
}  

sub AuthorXMLOut {
  my ($ArgRef) = @_;
  my $AuthorID = exists $ArgRef->{-authorid} ? $ArgRef->{-authorid} : 0;
  
  require "AuthorSQL.pm";
  
  unless ($AuthorID && FetchAuthor($AuthorID)) {
    return undef;
  }  
  
  my %Attributes = ();
  $Attributes{id} = $AuthorID;
  
  my $AuthorXML = XML::Twig::Elt -> new(author => \%Attributes );
  my $First     = XML::Twig::Elt -> new("firstname",$Authors{$AuthorID}{FirstName});
  my $Last      = XML::Twig::Elt -> new("lastname", $Authors{$AuthorID}{LastName});
  my $Full      = XML::Twig::Elt -> new("fullname", $Authors{$AuthorID}{FULLNAME});
        
  $First -> paste(last_child => $AuthorXML);
  $Last  -> paste(last_child => $AuthorXML);
  $Full  -> paste(last_child => $AuthorXML);
    
  return $AuthorXML; 
}

1;
