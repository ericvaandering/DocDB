#
# Author Eric Vaandering (ewv@fnal.gov)
#

# Copyright 2001-2009 Eric Vaandering, Lynn Garren, Adam Bryant

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
  $Header .= '<?xml version="1.0" encoding="'.$HTTP_ENCODING.'"?>'."\n";
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
  my %XMLDisplay = exists $ArgRef->{-display} ? %{$ArgRef->{-display}} : ("Authors" => $TRUE, "Title" => $TRUE);

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

  require "Security.pm";
  require "Sorts.pm";

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

  # Basic revision info

  my $RevisionXML = XML::Twig::Elt -> new(docrevision => \%Attributes );
  if ($XMLDisplay{All} || $XMLDisplay{Title}) {
    XML::Twig::Elt -> new("title",Printable($DocRevisions{$DocRevID}{Title})) -> paste(first_child => $RevisionXML);
  }

  if ($XMLDisplay{All} || $XMLDisplay{DocType}) {
    my $DocTypeXML = DocTypeXMLOut( {-doctypeid => $DocRevisions{$DocRevID}{DocTypeID}} );
    if ($DocTypeXML) {
      $DocTypeXML -> paste(last_child => $RevisionXML);
    }
  }

  # Add security settings

  if ($XMLDisplay{All} || $XMLDisplay{Security}) {
    my @ViewIDs   = GetRevisionSecurityGroups($DocRevID);
    my @ModifyIDs = GetRevisionModifyGroups($DocRevID);

    my @ViewXML   = SecurityXMLOut({ -viewids   => \@ViewIDs   });
    my @ModifyXML = SecurityXMLOut({ -modifyids => \@ModifyIDs });

    foreach my $SecurityXML (@ViewXML,@ModifyXML) {
      if ($SecurityXML) {
        $SecurityXML -> paste(last_child => $RevisionXML);
      }
    }
  }

  # Add submitter

  if ($XMLDisplay{All} || $XMLDisplay{Submitter}) {
    require "AuthorSQL.pm";
    my $AuthorXML = AuthorXMLOut( {-submitterid => $DocRevisions{$DocRevID}{Submitter}} );
    if ($AuthorXML) {
      $AuthorXML -> paste(last_child => $RevisionXML);
    }
  }

  # Add authors

  if ($XMLDisplay{All} || $XMLDisplay{Authors}) {
    require "AuthorSQL.pm";
    require "AuthorUtilities.pm";
    my @AuthorRevIDs = GetRevisionAuthors($DocRevID);
       @AuthorRevIDs = sort AuthorRevIDsByOrder @AuthorRevIDs;
    my @AuthorIDs    = AuthorRevIDsToAuthorIDs({ -authorrevids => \@AuthorRevIDs, });
    foreach my $AuthorID (@AuthorIDs) {
      my $AuthorXML = AuthorXMLOut( {-authorid => $AuthorID} );
      if ($AuthorXML) {
        $AuthorXML -> paste(last_child => $RevisionXML);
      }
    }
  }

  # Add Topics

  if ($XMLDisplay{All} || $XMLDisplay{Topics}) {
    require "TopicSQL.pm";
    my @TopicIDs = GetRevisionTopics({-docrevid => $DocRevID});
    foreach my $TopicID (@TopicIDs) {
      my $TopicXML = TopicXMLOut( {-topicid => $TopicID} );
      if ($TopicXML) {
        $TopicXML -> paste(last_child => $RevisionXML);
      }
    }
  }

  # Add Events

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

  # Add Abstract

  if ($XMLDisplay{All} || $XMLDisplay{Abstract}) {
    # FIXME: Figure out how to do Paragraphize in XML. My routines are getting made safe like &lt;
    my $AbstractXML = XML::Twig::Elt -> new("abstract", Printable($DocRevisions{$DocRevID}{Abstract}));
    $AbstractXML -> paste(last_child => $RevisionXML);
  }

  # Add Keywords

  if ($XMLDisplay{All} || $XMLDisplay{Keywords}) {
    my @KeywordXML = KeywordXMLOut( {-keywords => $DocRevisions{$DocRevID}{Keywords}} );
    foreach my $KeywordXML (@KeywordXML) {
      if ($KeywordXML) {
        $KeywordXML -> paste(last_child => $RevisionXML);
      }
    }
  }

  if ($XMLDisplay{All} || $XMLDisplay{Note}) {
    # FIXME: Figure out how to do Paragraphize in XML. My routines are getting made safe like &lt;
    my $NoteXML = XML::Twig::Elt -> new("note", Printable($DocRevisions{$DocRevID}{Note}));
    $NoteXML -> paste(last_child => $RevisionXML);
  }



  # Add Files

  if ($XMLDisplay{All} || $XMLDisplay{Files}) {
    my @FileXML = FileXMLOut( {-docrevid => $DocRevID} );
    foreach my $FileXML (@FileXML) {
      if ($FileXML) {
        $FileXML -> paste(last_child => $RevisionXML);
      }
    }
  }

  # Add XRefs to other documents

  if ($XMLDisplay{All} || $XMLDisplay{XRefs}) {
    my @XRefToXML = XRefToXMLOut( {-docrevid => $DocRevID} );
    foreach my $XRefToXML (@XRefToXML) {
      if ($XRefToXML) {
        $XRefToXML -> paste(last_child => $RevisionXML);
      }
    }
  }

  # Add other XRefs to this document

  if ($XMLDisplay{All} || $XMLDisplay{XRefs}) {
    my @XRefByXML = XRefByXMLOut( {-docrevid => $DocRevID} );
    foreach my $XRefByXML (@XRefByXML) {
      if ($XRefByXML) {
        $XRefByXML -> paste(last_child => $RevisionXML);
      }
    }
  }

  # Add Journal references

  if ($XMLDisplay{All} || $XMLDisplay{Journals}) {
    my @JournalXML = JournalXMLOut( {-docrevid => $DocRevID} );
    foreach my $JournalXML (@JournalXML) {
      if ($JournalXML) {
        $JournalXML -> paste(last_child => $RevisionXML);
      }
    }
  }

  # Add free-form publication info

  if ($XMLDisplay{All} || $XMLDisplay{PubInfo}) {
    # FIXME: Figure out how to do Paragraphize in XML. My routines are getting made safe like &lt;
    my $PubInfoXML = XML::Twig::Elt -> new("publicationinfo", Printable($DocRevisions{$DocRevID}{PUBINFO}));
    $PubInfoXML -> paste(last_child => $RevisionXML);
  }

  # Add list of other versions. Careful as this is recursive, so display is blank.

  if ($XMLDisplay{All} || $XMLDisplay{OtherVersions}) {
    my @OtherRevIDs = FetchRevisionsByDocument($DocumentID);
    if (@OtherRevIDs) {
      my $OtherVersionsXML = XML::Twig::Elt -> new("otherversions");
      foreach my $OtherRevID (@OtherRevIDs) {
        my $Version = $DocRevisions{$OtherRevID}{VERSION};
        unless (CanAccess($DocumentID,$Version)) {next;}
        my $OtherVersionXML = RevisionXMLOut( {-docrevid => $OtherRevID, -display => \()} );
        if ($OtherVersionXML) {
          $OtherVersionXML -> paste(last_child => $OtherVersionsXML);
        }
      }
      $OtherVersionsXML -> paste(last_child => $RevisionXML);
    }
  }

  return $RevisionXML;
}

sub DocTypeXMLOut {
  my ($ArgRef) = @_;
  my $DocTypeID = exists $ArgRef->{-doctypeid} ? $ArgRef->{-doctypeid} : 0;

  require "MiscSQL.pm";

  FetchDocType($DocTypeID);
  my %Attributes = ();
  $Attributes{id} = $DocTypeID;

  my $DocTypeXML = XML::Twig::Elt -> new("doctype" => \%Attributes);
  my $Short      = XML::Twig::Elt -> new("name",       Printable($DocumentTypes{$DocTypeID}{SHORT}));
  my $Long       = XML::Twig::Elt -> new("description",Printable($DocumentTypes{$DocTypeID}{LONG}));

  $Short -> paste(last_child => $DocTypeXML);
  $Long  -> paste(last_child => $DocTypeXML);

  return $DocTypeXML;
}


sub AuthorXMLOut {
  my ($ArgRef) = @_;
  my $AuthorID    = exists $ArgRef->{-authorid}    ? $ArgRef->{-authorid}    : 0;
  my $SubmitterID = exists $ArgRef->{-submitterid} ? $ArgRef->{-submitterid} : 0;
  require "AuthorSQL.pm";

  my $ElementName = "author";
  if ($SubmitterID) {
    $AuthorID = $SubmitterID;
    $ElementName = "submitter";
  }

  unless ($AuthorID && FetchAuthor($AuthorID)) {
    return undef;
  }

  my %Attributes = ();
  $Attributes{id} = $AuthorID;

  my $AuthorXML = XML::Twig::Elt -> new($ElementName => \%Attributes );
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

  unless ($TopicID && FetchTopic({-topicid => $TopicID})) {
    return undef;
  }
  FetchTopicParents({-topicid => $TopicID});
  my ($ParentID) = @{$TopicParents{$TopicID}};
  my %Attributes = ();
  $Attributes{id} = $TopicID;
  if ($ParentID) {
    $Attributes{parentid} = $ParentID; # Attribute not compatible with multiple parents
  }

  my $TopicXML = XML::Twig::Elt -> new(topic => \%Attributes );
  my $Short    = XML::Twig::Elt -> new("name",       Printable($Topics{$TopicID}{Short}));
  my $Long     = XML::Twig::Elt -> new("description",Printable($Topics{$TopicID}{Long}));

  $Short -> paste(last_child => $TopicXML);
  $Long  -> paste(last_child => $TopicXML);

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
  if ($Conferences{$EventID}{Location}) {
    $Location    -> paste(last_child => $EventXML);
  }
  if ($Conferences{$EventID}{LongDescription}) {
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
    my $Version    = $DocXRefs{$DocXRefID}{Version};
    my $ExtProject = $DocXRefs{$DocXRefID}{Project};
    my %Attributes = ();
    $Attributes{docid} = $DocXRefs{$DocXRefID}{DocumentID};
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

sub FileXMLOut {
  my ($ArgRef) = @_;
  my $DocRevID = exists $ArgRef->{-docrevid} ? $ArgRef->{-docrevid} : 0;

  require "MiscSQL.pm";

  my @DocFileIDs = FetchDocFiles($DocRevID) ;

  unless (@DocFileIDs) {
    return undef;
  }

  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{Version};
  my @FileXML = ();

  foreach my $DocFileID (@DocFileIDs) {
    my %Attributes = ();
    my $ShortFile = CGI::escape($DocFiles{$DocFileID}{Name});
    my $URL = $RetrieveFile."?docid=".$DocumentID."&amp;version=".$Version."&amp;filename=".$ShortFile;
    $Attributes{href} = $URL;
    $Attributes{id}   = $DocFileID;
    if ($DocFiles{$DocFileID}{ROOT}) {
      $Attributes{main} = "yes";
    } else {
      $Attributes{main} = "no";
    }
    my $FileXML     = XML::Twig::Elt -> new(file => \%Attributes );
    my $Name        = XML::Twig::Elt -> new("name",        Printable($DocFiles{$DocFileID}{Name}));
    my $Description = XML::Twig::Elt -> new("description", Printable($DocFiles{$DocFileID}{DESCRIPTION}));

    $Name -> paste(last_child => $FileXML);
    if ($DocFiles{$DocFileID}{DESCRIPTION}) {
      $Description -> paste(last_child => $FileXML);
    }

    push @FileXML,$FileXML;
  }
  return @FileXML;
}

sub JournalXMLOut {

  my ($ArgRef) = @_;
  my $DocRevID = exists $ArgRef->{-docrevid} ? $ArgRef->{-docrevid} : 0;

  require "MiscSQL.pm";
  require "ReferenceLinks.pm";

  my @ReferenceIDs = FetchReferencesByRevision($DocRevID);

  unless (@ReferenceIDs) {
    return undef;
  }

  my @JournalXML = ();
  GetJournals();
  foreach my $ReferenceID (@ReferenceIDs) {
    my %Attributes = ();

    my $JournalID = $RevisionReferences{$ReferenceID}{JournalID};

    my ($ReferenceLink,$ReferenceText) = ReferenceLink($ReferenceID);

    if ($ReferenceLink) {
      $Attributes{href} = $ReferenceLink;
    }
    unless ($ReferenceText) {
      $ReferenceText = "$Journals{$JournalID}{Abbreviation}";
      if ($RevisionReferences{$ReferenceID}{Volume}) {
        $ReferenceText .= " vol. $RevisionReferences{$ReferenceID}{Volume}";
      }
      if ($RevisionReferences{$ReferenceID}{Page}) {
        $ReferenceText .= " pg. $RevisionReferences{$ReferenceID}{Page}";
      }
    }
    my $JournalXML = XML::Twig::Elt -> new(reference => \%Attributes );
    my $Citation   = XML::Twig::Elt -> new("citation", Printable($ReferenceText));
    my $Journal    = XML::Twig::Elt -> new("journal",  Printable($Journals{$JournalID}{Name}));
     # FIXME: Journal has info with it too.
    my $Page       = XML::Twig::Elt -> new("page",     Printable($RevisionReferences{$ReferenceID}{Page}));
    my $Volume     = XML::Twig::Elt -> new("volume",   Printable($RevisionReferences{$ReferenceID}{Volume}));

    $Citation -> paste(last_child => $JournalXML);
    $Journal  -> paste(last_child => $JournalXML);
    if ($RevisionReferences{$ReferenceID}{Volume}) {
      $Volume -> paste(last_child => $JournalXML);
    }
    if ($RevisionReferences{$ReferenceID}{Page}) {
      $Page   -> paste(last_child => $JournalXML);
    }
    push @JournalXML ,$JournalXML
  }

  return @JournalXML;
}

sub SecurityXMLOut {
  my ($ArgRef) = @_;
  my @ViewIDs   = exists $ArgRef->{-viewids}   ? @{$ArgRef->{-viewids}}   : ();
  my @ModifyIDs = exists $ArgRef->{-modifyids} ? @{$ArgRef->{-modifyids}} : ();
  require "SecuritySQL.pm";

  my $ElementName = "viewgroup";
  my @IDs = @ViewIDs;

  if (@ModifyIDs) {
    $ElementName = "modifygroup";
    @IDs = @ModifyIDs;
  }

  my @SecurityXML = ();

  foreach my $ID (@IDs) {
    FetchSecurityGroup ($ID);
    my %Attributes = ('id' => $ID);
    my $SecurityXML = XML::Twig::Elt -> new($ElementName => \%Attributes );
    my $Name        = XML::Twig::Elt -> new("name",        Printable($SecurityGroups{$ID}{NAME}));
    my $Description = XML::Twig::Elt -> new("description", Printable($SecurityGroups{$ID}{Description}));
    $Name        -> paste(last_child => $SecurityXML);
    $Description -> paste(last_child => $SecurityXML);
    push @SecurityXML,$SecurityXML;
  }

  return @SecurityXML;
}


sub XMLReport {
  my %Attributes = ();
  my $ReportXML = XML::Twig::Elt -> new(report => \%Attributes );
  foreach my $Error (@ErrorStack) {
    my $Line = XML::Twig::Elt -> new("error", Printable($Error));
    $Line -> paste(last_child => $ReportXML);
  }
  foreach my $Warning (@WarnStack) {
    my $Line = XML::Twig::Elt -> new("warning", Printable($Warning));
    $Line -> paste(last_child => $ReportXML);
  }
  foreach my $Action (@ActionStack) {
    my $Line = XML::Twig::Elt -> new("action", Printable($Action));
    $Line -> paste(last_child => $ReportXML);
  }
  if ($DebugOutput) {
    foreach my $Debug (@DebugStack) {
      my $Line = XML::Twig::Elt -> new("debug", Printable($Debug));
      $Line -> paste(last_child => $ReportXML);
    }
  }

  @ErrorStack  = ();
  @WarnStack   = ();
  @ActionStack = ();
  @DebugStack  = ();

  return $ReportXML;
}

1;
