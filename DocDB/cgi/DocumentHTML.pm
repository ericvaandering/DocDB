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
  require "RevisionSQL.pm";
  require "Security.pm";
  require "Sorts.pm";
  
  my %Params = @_;
  
  my $SortBy        =   $Params{-sortby}; 
  my $Reverse       =   $Params{-reverse};
  my $MaxDocs       =   $Params{-maxdocs};
  my $SessionTalkID = $Params{-talkid};
  my @DocumentIDs   = @{$Params{-docids}};
  my @Fields        = @{$Params{-fields}}; 
  my %FieldOptions  = %{$Params{-fieldoptions}}; 
  
  my %FieldTitles = (Docid   => "$ShortProject-doc-#", Updated => "Last Updated", 
                     CanSign => "Next Signature(s)", Confirm => "Confirm?");  
  
### Write out the beginning and header of table

  print "<center><table id=\"DocumentList\" class=\"Alternating\">\n";

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

### Fetch all documents so sorts have info

  foreach my $DocumentID (@DocumentIDs) {
    my $Version = &LastAccess($DocumentID);
    if ($Version == -1) {next;}
    my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
  }

### Sort document IDs, reverse from convention if needed

  if ($SortBy eq "docid") { 
    @DocumentIDs = sort numerically @DocumentIDs;
  } elsif ($SortBy eq "date") {
    @DocumentIDs = sort DocumentByRevisionDate @DocumentIDs; 
  } elsif ($SortBy eq "requester") {
    @DocumentIDs = sort DocumentByRequester @DocumentIDs; 
  } elsif ($SortBy eq "confdate") {
    @DocumentIDs = sort DocumentByConferenceDate @DocumentIDs; 
  }

  
  if ($Reverse) {
    @DocumentIDs = reverse @DocumentIDs;
  }

### Loop over document IDs

  my $NumberOfDocuments = 0;
  my $RowClass;
  foreach my $DocumentID (@DocumentIDs) {
  
### Which version (if any) can they view
    my $Version = &LastAccess($DocumentID);
    if ($Version == -1) {next;}
    my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    ++$NumberOfDocuments;

    if ($MaxDocs && $NumberOfDocuments > $MaxDocs) {
      last;
    }
    
### Print fields requested
    if ($NumberOfDocuments % 2) { 
      $RowClass = "Odd";
    } else {
      $RowClass = "Even";
    }    
    print "<tr class=\"$RowClass\">\n";
    foreach my $Field (@Fields) {
      print "<td class=\"$Field\">";
      if      ($Field eq "Docid") {    # Document number
        print &NewerDocumentLink(-docid => $DocumentID, -version => $Version, 
                                 -numwithversion => true); 
      } elsif ($Field eq "Title") {    # Document title
        print &NewerDocumentLink(-docid => $DocumentID, -version => $Version, 
                                 -titlelink => true); 
      } elsif ($Field eq "Author") {   # Single author (et. al.)
        print &FirstAuthor($DocRevID);
      } elsif ($Field eq "Updated") {  # Date of last update
        print &EuroDate($DocRevisions{$DocRevID}{DATE});
      } elsif ($Field eq "CanSign") {  # Who can sign document
        require "SignoffUtilities.pm";
        require "SignoffHTML.pm";
        my @EmailUserIDs = &ReadySignatories($DocRevID);
        foreach my $EmailUserID (@EmailUserIDs) {
          print &SignatureLink($EmailUserID),"<br/>\n";
        }  
      } elsif ($Field eq "Conference") {  # Conferences. Simplify in v7
        require "TopicHTML.pm";
        require "TopicSQL.pm";
        my @topics = &GetRevisionTopics($DocRevID);
        foreach my $topic (@topics) {
          if (&MajorIsConference($MinorTopics{$topic}{MAJOR})) {
            my $conference_link = &ConferenceLink($topic,"short");
            print "$conference_link<br>\n";
          }  
        }
      } elsif ($Field eq "Topics") {  # Topics for document
        require "TopicHTML.pm";
        require "TopicSQL.pm";
        my @TopicIDs = &GetRevisionTopics($DocRevID);
        &ShortTopicListByID(@TopicIDs); 
      } elsif ($Field eq "Files") {   # Files in document
        require "FileHTML.pm";
        &ShortFileListByRevID($DocRevID); 
      } elsif ($Field eq "Confirm") {  
        print $query -> start_multipart_form('POST',$ConfirmTalkHint);
        print $query -> hidden(-name => 'documentid',   -default => $DocumentID);
        print $query -> hidden(-name => 'sessiontalkid',-default => $SessionTalkID);
        print $query -> submit (-value => "Confirm");
        print $query -> end_multipart_form;
      } else {
        print "Unknown field"
      }  
      print "</td>\n";
    }  
    print "</tr>\n";
  }  

### End table, return

  print "</table></center>\n";
  
  return $NumberOfDocuments;
}

sub NewerDocumentLink (%) { # FIXME: Make this the default (DocumentLink)
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  require "ResponseElements.pm";
  
  my %Params = @_;
  
  my $DocumentID       = $Params{-docid};
#  my $Version          = $Params{-version}; #FIXME: Remember 0 version documents
#  my $DocRevID         = $Params{-docrevid}; #FIXME
  my $DocIDOnly        = $Params{-docidonly}        || 0;
  my $NumWithVersion   = $Params{-numwithversion}   || 0;
  my $TitleLink        = $Params{-titlelink}        || 0;
  my $NoApprovalStatus = $Params{-noapprovalstatus} || 0;

  &FetchDocument($DocumentID);
  my $Version      = $Documents{$DocumentID}{NVersions};

  my $DocRevID  = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
  unless ($DocRevID) {
    return "";
  }
  my $FullDocID = &FullDocumentID($DocumentID,$Version);
    
  my $Link = "<a href=\"$ShowDocument\?docid=$DocumentID\"";
     $Link .= " title=\"$FullDocID\"";
   
  # When adding the version number, remember to use &amp; for XHTML 
  # or use DocumentURL
  
  $Link .= "\">"; 
  if ($DocIDOnly) {           # Like 1234                   
    $Link .= $DocumentID;
    $Link .= "</a>";
  } elsif ($NumWithVersion) { # Like 1234-v56
    $Link .= $DocumentID."-v".$Version;
    $Link .= "</a>";
  } elsif ($TitleLink) {      # Use the document Title
    $Link .= $DocRevisions{$DocRevID}{Title};
    $Link .= "</a>";
    if ($UseSignoffs && !$NoApprovalStatus) { # Put document status on next line
      require "SignoffUtilities.pm";
      my ($ApprovalStatus,$LastApproved) = &RevisionStatus($DocRevID);
      unless ($ApprovalStatus eq "Unmanaged") { 
        $Link .= "<br/>($ApprovalStatus";
        if ($ApprovalStatus eq "Unapproved") {
          if (defined $LastApproved) {
            my $DocumentID = $DocRevisions{$LastApproved}{DOCID};
            my $Version    = $DocRevisions{$LastApproved}{Version};
            my $LastLink   = &DocumentLink($DocumentID,$Version,"version $Version"); # Will Recurse
            $Link .= " - Last approved: $LastLink";
          } else {
            $Link .= " - No approved version";
          }
        }
        $Link .= ")";
      }  
    }  
  } else {                    # Like Project-doc-1234-v56
    $Link .= &FullDocumentID($DocumentID,$Version);  
    $Link .= "</a>";
  }
  return $Link;
}         

sub PrintDocNumber { # And type
  my ($DocRevID) = @_;
  print "<dt>Document #:</dt>";
  print "<dd>";
  print (&FullDocumentID($DocRevisions{$DocRevID}{DOCID}));
  print "-v$DocRevisions{$DocRevID}{VERSION}";
  print "</dd>\n";
  
  print "<dt>Document type:</dt>";
  my $type_link = &TypeLink($Documents{$DocRevisions{$DocRevID}{DOCID}}{TYPE},"short");
  print "<dd>$type_link</dd>\n";
}

1;
