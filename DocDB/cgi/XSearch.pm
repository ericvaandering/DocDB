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

sub XSearchParse ($) {
  my ($ArgRef) = @_;
  my $Project = exists $ArgRef->{-project} ? $ArgRef->{-project} : "";
  my $Text    = exists $ArgRef->{-text}    ? $ArgRef->{-text}    : "";
  my $UseTwig = exists $ArgRef->{-usetwig} ? $ArgRef->{-usetwig} : $FALSE;

  use XML::Twig;
  require "XRefSQL.pm";

  my $Twig = XML::Twig -> new();

  my %FoundDocuments = ();
  my $ProjectXML;  
  if ($Project) {
    my $ExternalDocDBID = $ExternalProjects{$Project};

    unless ($ExternalDocDBID) {
      return undef;
    }   

    my $SearchURL = $ExternalDocDBs{$ExternalDocDBID}{PublicURL}."Search";
    $SearchURL .= "?outformat=XML&simple=1";
    $SearchURL .= "&simpletext=$Text";

    $Twig -> parseurl($SearchURL);
    ($ProjectXML) = $Twig -> children();
  } elsif ($UseTwig) {
#    return undef;
    my $XML = $DocDBXML -> sprint();
    $Twig -> parse($XML);
    $ProjectXML = $Twig -> root();
  } else {
    return undef;
  }

  my $Project = $ProjectXML -> {'att'} -> {'shortproject'};
  my $Version = $ProjectXML -> {'att'} -> {'version'};

  print "<p>Project $Project $Version</p>";

  print "<p/>\n";
  $ProjectXML -> print();
  print "<p/>\n";
  
  my @Documents = $ProjectXML -> children();

  foreach my $Document (@Documents) {
    my $DocID     = $Document -> {'att'} -> {'id'};
    my $URL       = $Document -> {'att'} -> {'href'};
    my $Relevance = $Document -> {'att'} -> {'relevance'};
    print "<p> $DocID $URL</p>";
    
    my $Identifier = $Project."-".$DocID;
    
    my $Revision =  $Document -> first_child();
    unless ($Revision) {
      next;
    }  
    my $DateTime = $Revision -> {'att'} -> {'modified'};
    print "<p> $DateTime</p>";
    my ($Date,$Time) = split /\s+/,$DateTime;
    my $Title    = $Revision -> first_child("title")  -> text();;
    my $Author   = $Revision -> first_child("author") -> first_child("fullname") 
                             -> text();
    my @Authors = $Revision -> children("author");
    if (scalar(@Authors)>1) {
      $EtAl = $TRUE;
    }  
    $FoundDocuments{$Identifier}{URL}       = $URL;
    $FoundDocuments{$Identifier}{Title}     = $Title;
    $FoundDocuments{$Identifier}{Relevance} = $Relevance;
    $FoundDocuments{$Identifier}{Author}    = $Author;
    $FoundDocuments{$Identifier}{EtAl}      = $EtAl;
    $FoundDocuments{$Identifier}{Date}      = $Date;
  }  
  
  return %FoundDocuments;
}

sub XSearchDocsByRelevance {
  $XSearchDocs{$a}{Relevance} <=> $XSearchDocs{$b}{Relevance}
}
1;
