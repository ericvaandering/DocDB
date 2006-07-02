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
require "Utilities.pm";

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
  my $DocumentID = exists $ArgRef->{-docid}   ?   $ArgRef->{-docid}    : 0;
  my $Version    = exists $ArgRef->{-version} ?   $ArgRef->{-version}  : "lastaccesible";
  my %XMLDisplay = exists $ArgRef->{-display}  ? %{$ArgRef->{-display}} : ("Authors" => $TRUE);

  unless ($DocumentID) { return undef; }
  
  my %Attributes = ();
  $Attributes{id}           = $DocumentID;
  $Attributes{href}         = $ShowDocument."?docid=$DocumentID";
  
  if ($Documents{$DocumentID}{Relevance}) { 
    $Attributes{relevance} = $Documents{$DocumentID}{Relevance};
  }
  
  my $DocumentXML = XML::Twig::Elt -> new(document => \%Attributes );

  if ($Version eq "lastaccesible") {
    require "Security.pm";
    $Version = LastAccess($DocumentID);
  }
  
  my $DocRevID = FetchRevisionByDocumentAndVersion($DocumentID,$Version);
  my $RevisionXML = RevisionXMLOut( {-docrevid => $DocRevID, -display => \%XMLDisplay} );
  if ($RevisionXML) {
    $RevisionXML -> paste(last_child => $DocumentXML);
    return $DocumentXML;
  } else {
    return undef;
  }    
}

sub RevisionXMLOut {
  my ($ArgRef) = @_;
  my $DocRevID   = exists $ArgRef->{-docrevid} ?   $ArgRef->{-docrevid} : 0;
  my %XMLDisplay = exists $ArgRef->{-display}  ? %{$ArgRef->{-display}} : ();
  
#  my $Authors  = exists $XMLDisplay{Authors}  ? $ArgRef->{-authors}  : $TRUE;
#  my $Topics   = exists $ArgRef->{-topics}   ? $ArgRef->{-topics}   : $FALSE;
#  my $Events   = exists $ArgRef->{-events}   ? $ArgRef->{-events}   : $FALSE;
  
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
  XML::Twig::Elt -> new("title",Printable($DocRevisions{$DocRevID}{Title})) -> paste(first_child => $RevisionXML);

  if ($XMLDisplay{All} || $XMLDisplay{Authors}) {
    require "AuthorSQL.pm";
    my @AuthorIDs = GetRevisionAuthors($DocRevID);
    foreach my $AuthorID (@AuthorIDs) {
      my $AuthorXML = AuthorXMLOut( {-authorid => $AuthorID} );
      if ($AuthorXML) {
        $AuthorXML -> paste(last_child => $RevisionXML);
      }  
    }
  }
         
  if ($XMLDisplay{All} || $XMLDisplay{Topics}) {
    require "TopicSQL.pm";
    my @TopicIDs = GetRevisionTopics($DocRevID);
    foreach my $TopicID (@TopicIDs) {
      my $TopicXML = TopicXMLOut( {-topicid => $TopicID} );
      if ($TopicXML) {
        $TopicXML -> paste(last_child => $RevisionXML);
      }  
    }
  }

  if ($XMLDisplay{All} || $XMLDisplay{Events}) {
    require "MeetingSQL.pm";
    my @EventIDs = GetRevisionEvents($DocRevID);
    foreach my $EventID (@EventIDs) {
      my $EventXML = EventXMLOut( {-eventid => $EventID} );
      if ($EventXML) {
        $EventXML -> paste(last_child => $RevisionXML);
      }  
    }
  }

  if ($XMLDisplay{All} || $XMLDisplay{Abstract}) {
    # FIXME: Figure out how to do Paragraphize in XML. My routines are getting made safe like &lt;
    my $AbstractXML = XML::Twig::Elt -> new("abstract", Printable($DocRevisions{$DocRevID}{Abstract}));
    $AbstractXML -> paste(last_child => $RevisionXML);
  }
  
  if ($XMLDisplay{All} || $XMLDisplay{Keywords}) {
    my @KeywordXML = KeywordXMLOut( {-keywords => $DocRevisions{$DocRevID}{Keywords}} );
    foreach my $KeywordXML (@KeywordXML) {
      $KeywordXML -> paste(last_child => $RevisionXML);
    }
  }

  if ($XMLDisplay{All} || $XMLDisplay{XRefs}) {
    my @XRefToXML = XRefToXMLOut( {-docrevid => $DocRevID} );
    foreach my $XRefToXML (@XRefToXML) {
      $XRefToXML -> paste(last_child => $RevisionXML);
    }
  }

  if ($XMLDisplay{All} || $XMLDisplay{XRefs}) {
    my @XRefByXML = XRefByXMLOut( {-docrevid => $DocRevID} );
    foreach my $XRefByXML (@XRefByXML) {
      $XRefByXML -> paste(last_child => $RevisionXML);
    }
  }

  if ($XMLDisplay{All} || $XMLDisplay{PubInfo}) {
    # FIXME: Figure out how to do Paragraphize in XML. My routines are getting made safe like &lt;
    my $PubInfoXML = XML::Twig::Elt -> new("publicationinfo", Printable($DocRevisions{$DocRevID}{PUBINFO}));
    $PubInfoXML -> paste(last_child => $RevisionXML);
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
  my $First     = XML::Twig::Elt -> new("firstname",Printable($Authors{$AuthorID}{FirstName}));
  my $Last      = XML::Twig::Elt -> new("lastname", Printable($Authors{$AuthorID}{LastName}));
  my $Full      = XML::Twig::Elt -> new("fullname", Printable($Authors{$AuthorID}{FULLNAME}));
        
  $First -> paste(last_child => $AuthorXML);
  $Last  -> paste(last_child => $AuthorXML);
  $Full  -> paste(last_child => $AuthorXML);
    
  return $AuthorXML; 
}

sub TopicXMLOut {
  my ($ArgRef) = @_;
  my $TopicID = exists $ArgRef->{-topicid} ? $ArgRef->{-topicid} : 0;
  
  require "TopicSQL.pm";
  
  unless ($TopicID && FetchMinorTopic($TopicID)) {
    return undef;
  }  
  
  my %Attributes = ();
  $Attributes{id} = $TopicID;
  $Attributes{majorid} = $MinorTopics{$TopicID}{MAJOR}; # Soon to be Obsolete
  
  my $TopicXML = XML::Twig::Elt -> new(topic => \%Attributes );
  my $Short    = XML::Twig::Elt -> new("name",       Printable($MinorTopics{$TopicID}{SHORT}));
  my $Long     = XML::Twig::Elt -> new("description",Printable($MinorTopics{$TopicID}{LONG}));
  my $Full     = XML::Twig::Elt -> new("fullname",   Printable($MinorTopics{$TopicID}{Full}));
        
  $Short -> paste(last_child => $TopicXML);
  $Long  -> paste(last_child => $TopicXML);
  $Full  -> paste(last_child => $TopicXML);
    
  return $TopicXML; 
}

sub EventXMLOut {
  my ($ArgRef) = @_;
  my $EventID = exists $ArgRef->{-eventid} ? $ArgRef->{-eventid} : 0;
  
  require "MeetingSQL.pm";
  
  unless ($EventID && FetchConferenceByConferenceID($EventID)) {
    return undef;
  }  
  
  my %Attributes = ();
  $Attributes{id}           = $EventID;
  $Attributes{eventgroupid} = $Conferences{$EventID}{EventGroupID}; 
  $Attributes{start}        = $Conferences{$EventID}{StartDate}; 
  $Attributes{end}          = $Conferences{$EventID}{EndDate}; 
  if ($Conferences{$EventID}{URL}) {
    $Attributes{href}       = $Conferences{$EventID}{URL}; 
  }  
  
  my $EventXML    = XML::Twig::Elt -> new(event => \%Attributes );
  my $Name        = XML::Twig::Elt -> new("name",        Printable($Conferences{$EventID}{Title}));
  my $Location    = XML::Twig::Elt -> new("location",    Printable($Conferences{$EventID}{Location}));
  my $Description = XML::Twig::Elt -> new("description", Printable($Conferences{$EventID}{LongDescription}));
  my $FullName    = XML::Twig::Elt -> new("fullname",    Printable($Conferences{$EventID}{Full}));     
        
  $Name        -> paste(last_child => $EventXML);
  $FullName    -> paste(last_child => $EventXML);
  if ($Location) {
    $Location    -> paste(last_child => $EventXML);
  }  
  if ($Description) {
    $Description -> paste(last_child => $EventXML);
  }  
    
  return $EventXML; 
}

sub KeywordXMLOut {
  my ($ArgRef) = @_;
  my $Keywords = exists $ArgRef->{-keywords} ? $ArgRef->{-keywords} : 0;
    
  $Keywords =~ s/^\s+//;
  $Keywords =~ s/\s+$//;
  
  unless ($Keywords) {
    return undef;
  }  
  
  my @Keywords = split /\,*\s+/,$Keywords;
  my @KeywordXML = ();
  
  foreach my $Keyword (@Keywords) { 
    my $KeywordXML    = XML::Twig::Elt -> new("keyword",Printable($Keyword));
    push @KeywordXML,$KeywordXML;
  }
  return @KeywordXML;
}

sub XRefToXMLOut {
  my ($ArgRef) = @_;
  my $DocRevID = exists $ArgRef->{-docrevid} ? $ArgRef->{-docrevid} : 0;
  
  require "XRefSQL.pm";
  
  my @DocXRefIDs = FetchXRefs(-docrevid => $DocRevID);

  unless (@DocXRefIDs) {
    return undef;
  }  
  
  my @XRefToXML = ();
  
  foreach my $DocXRefID (@DocXRefIDs) {
    my $DocumentID = $DocXRefs{$DocXRefID}{DocumentID};
    my $Version    = $DocXRefs{$DocXRefID}{Version};
    my $ExtProject = $DocXRefs{$DocXRefID}{Project};
    my %Attributes = ();
    $Attributes{docid} = $DocumentID;
    if ($Version) {
      $Attributes{version} = $Version;
    }
    if ($ExtProject) {
      $Attributes{shortproject} = $ExtProject;
    } else {  
      $Attributes{shortproject} = $ShortProject;
    }
    
    my $XRefToXML = XML::Twig::Elt -> new(xrefto => \%Attributes );
    push @XRefToXML,$XRefToXML;
  }
  return @XRefToXML;  
}

sub XRefByXMLOut {
  my ($ArgRef) = @_;
  my $DocRevID = exists $ArgRef->{-docrevid} ? $ArgRef->{-docrevid} : 0;
  
  require "XRefSQL.pm";
  
  my @RawDocXRefIDs = FetchXRefs(-docid => $DocRevisions{$DocRevID}{DOCID});
  my @DocXRefIDs = ();
  
  foreach my $DocXRefID (@RawDocXRefIDs) { # Remove links to other projects, versions
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
    
  unless (@DocXRefIDs) {
    return undef;
  }  
  
  my @XRefByXML = ();
  
  foreach my $DocXRefID (@DocXRefIDs) {
    my $DocRevID = $DocXRefs{$DocXRefID}{DocRevID};
    FetchDocRevisionByID($DocRevID);
    if ($DocRevisions{$DocRevID}{Obsolete}) {
      next;
    }
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    if ($DocumentID && !$SeenDocument{$DocumentID}) {
      my %Attributes = ();
      $Attributes{docid} = $DocumentID;
      $Attributes{shortproject} = $ShortProject;
      my $XRefByXML = XML::Twig::Elt -> new(xrefby => \%Attributes );
      push @XRefByXML,$XRefByXML;
      $SeenDocument{$DocumentID} = $TRUE;
    }
  }
  return @XRefByXML;  
}

1;
