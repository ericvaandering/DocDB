# Description: Subroutines to provide various parts of HTML about documents
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

sub DocumentTable (%) {
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  require "Security.pm";
  require "Sorts.pm";
  require "Fields.pm";
  
  require "AuthorHTML.pm";
 
  my %Params = @_;
  
  my $SortBy        =   $Params{-sortby}; 
  my $Reverse       =   $Params{-reverse};
  my $MaxDocs       =   $Params{-maxdocs};
  my $NoneBehavior  =   $Params{-nonebehavior} || "skip";  # skip|
  my $SessionTalkID =   $Params{-talkid};
  my @DocumentIDs   = @{$Params{-docids}};
  my @Fields        = @{$Params{-fields}}; # deprecated, remove
  my %FieldList     = %{$Params{-fieldlist}}; 
  
  unless (@DocumentIDs) {
    if ($NoneBehavior eq "skip") {
      return;
    }
  }     

### Write out the beginning and header of table

  %SortFields = %FieldList;
  my @Fields = sort FieldsByColumn keys %FieldList;  
  %SortFields = ();
  
  print qq(<table class="Alternating DocumentList">\n); 

  print "<tr>\n";
  my $LastRow = 1;
  foreach my $Field (@Fields) {
    my $Column  = $FieldList{$Field}{Column}; 
    my $Row     = $FieldList{$Field}{Row}; 
    my $RowSpan = $FieldList{$Field}{RowSpan}; 
    my $ColSpan = $FieldList{$Field}{ColSpan}; 
    
    if ($Row != $LastRow) {
      $LastRow = $Row;
      print "</tr><tr>\n";
    }  
    
    my $Header = "<th";
    if ($RowSpan > 1) {$Header .= qq( rowspan="$RowSpan");}
    if ($ColSpan > 1) {$Header .= qq( colspan="$ColSpan");}
    $Header .= " class=\"$Field\">";
    
    print "$Header";
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
    print "<tbody class=\"$RowClass\"><tr>\n";
    my $LastRow = 1;
    foreach my $Field (@Fields) {
      my $Column  = $FieldList{$Field}{Column}; 
      my $Row     = $FieldList{$Field}{Row}; 
      my $RowSpan = $FieldList{$Field}{RowSpan}; 
      my $ColSpan = $FieldList{$Field}{ColSpan}; 

      if ($Row != $LastRow) {
        $LastRow = $Row;
        print "</tr><tr>\n";
      }
        
      my $TD = qq(<td class="$Field");
      if ($RowSpan > 1) {$TD .= qq( rowspan="$RowSpan");}
      if ($ColSpan > 1) {$TD .= qq( colspan="$ColSpan");}
      $TD .= " class=\"$Field\">";
      print $TD;
      
      if      ($Field eq "Docid") {    # Document number
        print &NewerDocumentLink(-docid => $DocumentID, -version => $Version, 
                                 -numwithversion => $TRUE); 
      } elsif ($Field eq "Title") {    # Document title
        print &NewerDocumentLink(-docid => $DocumentID, -version => $Version, 
                                 -titlelink => $TRUE); 
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
      } elsif ($Field eq "Conference" || $Field eq "Events") {  
        &PrintEventInfo(-docrevid => $DocRevID, -format => "short");
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
      } elsif ($Field eq "References") {   # Journal refs
        require "RevisionHTML.pm";
        &PrintReferenceInfo($DocRevID,"short"); 
      } elsif ($Field eq "Blank") {        # Blank Cell
        print ""; 
      } else {
        print "Unknown field"
      }  
      print "</td>\n";
    }  
    print "</tr></tbody>\n";
  }  

### End table, return

  print "</table>\n";
  
  return $NumberOfDocuments;
}

sub NewDocumentTable (%) {
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  require "Security.pm";
  require "Sorts.pm";
  require "Fields.pm";
  
  require "AuthorHTML.pm";
 
  my %Params = @_;
  
  my $SortBy          =   $Params{-sortby}; 
  my $Reverse         =   $Params{-reverse};
  my $MaxDocs         =   $Params{-maxdocs};
  my $NoneBehavior    =   $Params{-nonebehavior} || "skip";  # skip|
  my $SessionTalkID   =   $Params{-talkid} || 0;
  my @DocumentIDs     = @{$Params{-docids}};
  my @SessionOrderIDs = @{$Params{-sessionorderids}};
  my @Fields          = @{$Params{-fields}}; # deprecated, remove
  my %FieldList       = %{$Params{-fieldlist}}; 
  
  my @IDs  = ();
  my $Mode;
  
  if (@SessionOrderIDs) { 
    @IDs  = @SessionOrderIDs;
    $Mode = "SessionOrder";
  } elsif (@DocumentIDs) { 
    @IDs  = @DocumentIDs;
    $Mode = "Document";
  }
  
  unless (@IDs) {
    if ($NoneBehavior eq "skip") {
      return;
    }
  }     


### Write out the beginning and header of table

  %SortFields = %FieldList;
  my @Fields = sort FieldsByColumn keys %FieldList;  
  %SortFields = ();
  
  print qq(<table class="Alternating DocumentList">\n); 

  print "<tr>\n";
  my $LastRow = 1;
  foreach my $Field (@Fields) {
    my $Column  = $FieldList{$Field}{Column}; 
    my $Row     = $FieldList{$Field}{Row}; 
    my $RowSpan = $FieldList{$Field}{RowSpan}; 
    my $ColSpan = $FieldList{$Field}{ColSpan}; 
    
    if ($Row != $LastRow) {
      $LastRow = $Row;
      print "</tr><tr>\n";
    }  
    
    my $Header = "<th";
    if ($RowSpan > 1) {$Header .= qq( rowspan="$RowSpan");}
    if ($ColSpan > 1) {$Header .= qq( colspan="$ColSpan");}
    $Header .= " class=\"$Field\">";
    
    print "$Header";
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
  foreach my $ID (@IDs) {
    my $DocumentID      = 0;
    my $SessionOrderID  = 0;
#    my $SessionTalkID   = 0;
    my $TalkSeparatorID = 0;
    if ($Mode eq "Document") {
      $DocumentID = $ID;
    } elsif ($Mode eq "SessionOrder") {
      $SessionOrderID = $ID;
      if ($SessionOrders{$SessionOrderID}{TalkSeparatorID}) {
        $TalkSeparatorID = $SessionOrders{$SessionOrderID}{TalkSeparatorID};
      }
      if ($SessionOrders{$SessionOrderID}{SessionTalkID}) {
        $SessionTalkID = $SessionOrders{$SessionOrderID}{SessionTalkID};
        $DocumentID    = $SessionTalks{$SessionTalkID}{DocumentID};
      }  
    }  
    
### Which version (if any) can they view (Move into document mode section?)
    my $Version = &LastAccess($DocumentID);
    if ($Version == -1 && $Mode eq "Document") {next;}
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
    print "<tbody class=\"$RowClass\"><tr>\n";
    my $LastRow = 1;
    foreach my $Field (@Fields) {
      my $Column  = $FieldList{$Field}{Column}; 
      my $Row     = $FieldList{$Field}{Row}; 
      my $RowSpan = $FieldList{$Field}{RowSpan}; 
      my $ColSpan = $FieldList{$Field}{ColSpan}; 

      if ($Row != $LastRow) {
        $LastRow = $Row;
        print "</tr><tr>\n";
      }
        
      my $TD = qq(<td class="$Field");
      if ($RowSpan > 1) {$TD .= qq( rowspan="$RowSpan");}
      if ($ColSpan > 1) {$TD .= qq( colspan="$ColSpan");}
      $TD .= " class=\"$Field\">";
      print $TD;
      
      if      ($Field eq "Docid") {    # Document number
        print NewerDocumentLink(-docid => $DocumentID, -version => $Version, 
                                -numwithversion => $TRUE); 
      } elsif ($Field eq "Title") {    # Document title
        if ($DocumentID) {
          print NewerDocumentLink(-docid => $DocumentID, -version => $Version, 
                                  -titlelink => $TRUE); 
        } elsif ($TalkSeparatorID) { # TalkSeparator
          print "$TalkSeparators{$TalkSeparatorID}{Title}";
        } elsif ($SessionTalkID) { # TalkSeparator
          print "$SessionTalks{$SessionTalkID}{HintTitle}";
        }
      } elsif ($Field eq "Author") {   # Single author (et. al.)
        require "TalkHintSQL.pm";
        if ($DocRevID) {
          print FirstAuthor($DocRevID);
        } elsif ($SessionTalkID) {
          my @AuthorHintIDs = FetchAuthorHintsBySessionTalkID($SessionTalkID);
          my @AuthorIDs = (); 
          foreach my $AuthorHintID (@AuthorHintIDs) {
            push @AuthorIDs,$AuthorHints{$AuthorHintID}{AuthorID};
          }
          print ShortAuthorListByID(@AuthorIDs); 
        }  
      } elsif ($Field eq "Updated") {  # Date of last update
        print &EuroDate($DocRevisions{$DocRevID}{DATE});
      } elsif ($Field eq "CanSign") {  # Who can sign document
        require "SignoffUtilities.pm";
        require "SignoffHTML.pm";
        my @EmailUserIDs = ReadySignatories($DocRevID);
        foreach my $EmailUserID (@EmailUserIDs) {
          print SignatureLink($EmailUserID),"<br/>\n";
        }  
      } elsif ($Field eq "Conference" || $Field eq "Events") {  
        PrintEventInfo(-docrevid => $DocRevID, -format => "short");
      } elsif ($Field eq "Topics") {  # Topics for document
        require "TopicHTML.pm";
        require "TopicSQL.pm";
        require "TalkHintSQL.pm";
        my @TopicIDs = ();
        if ($DocRevID) {
          @TopicIDs = GetRevisionTopics($DocRevID);
        } elsif ($SessionTalkID) {
          my @TopicHintIDs  = FetchTopicHintsBySessionTalkID($SessionTalkID);
          foreach my $TopicHintID (@TopicHintIDs) {
            push @TopicIDs,$TopicHints{$TopicHintID}{MinorTopicID};
          }
        }
        ShortTopicListByID(@TopicIDs); 
      } elsif ($Field eq "Files") {   # Files in document
        require "FileHTML.pm";
        if ($DocRevID) {
          ShortFileListByRevID($DocRevID); 
        } else {
          print "None";  
      } elsif ($Field eq "Confirm") {  
        print $query -> start_multipart_form('POST',$ConfirmTalkHint);
        print $query -> hidden(-name => 'documentid',   -default => $DocumentID);
        print $query -> hidden(-name => 'sessiontalkid',-default => $SessionTalkID);
        print $query -> submit (-value => "Confirm");
        print $query -> end_multipart_form;
      } elsif ($Field eq "References") {   # Journal refs
        require "RevisionHTML.pm";
        PrintReferenceInfo($DocRevID,"short"); 
      } elsif ($Field eq "TalkTime") {
        if ($SessionOrderID) {
          print "<strong>",TruncateSeconds($SessionOrders{$SessionOrderID}{StartTime}),"</strong>";
        } else {
          print "";
        }    
      } elsif ($Field eq "TalkLength") {
        if ($SessionTalkID) {
          print TruncateSeconds($SessionTalks{$SessionTalkID}{Time});
        } elsif ($TalkSeparatorID) {
          print TruncateSeconds($TalkSeparators{$TalkSeparatorID}{Time});
        } else {
          print "";
        }  
      } elsif ($Field eq "TalkNotes") {
        if ($SessionTalkID) {
          if ($SessionTalks{$SessionTalkID}{Note}) {
            print "<strong>",TalkNoteLink($SessionTalkID),"</strong>";
          } else {
            print TalkNoteLink($SessionTalkID);
          }
        }
      } elsif ($Field eq "Blank") {        # Blank Cell
        print ""; 
      } else {
        print "Unknown field: $Field"
      }  
      print "</td>\n";
    }  
    print "</tr></tbody>\n";
  }  

### End table, return

  print "</table>\n";
  
  return $NumberOfDocuments;
}

sub NewerDocumentLink (%) { # FIXME: Make this the default (DocumentLink)
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  require "ResponseElements.pm";
  
  my %Params = @_;
  
  my $DocumentID       = $Params{-docid};
#  my $DocRevID         = $Params{-docrevid}; #FIXME
  my $DocIDOnly        = $Params{-docidonly}        || 0;
  my $NumWithVersion   = $Params{-numwithversion}   || 0;
  my $NoVersion        = $Params{-noversion}        || 0;
  my $TitleLink        = $Params{-titlelink}        || 0;
  my $NoApprovalStatus = $Params{-noapprovalstatus} || 0;

# Treat Version special since v0 is valid and we don't know the last version # until later

  my $Version = "latest";
  if (defined $Params{-version}) {
    $Version = $Params{-version};
  }  

  &FetchDocument($DocumentID);
  if ($Version eq "latest") {  
    $Version      = $Documents{$DocumentID}{NVersions};
  }
  
  my $DocRevID  = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
  unless ($DocRevID) {
    return "";
  }
  my $FullDocID = &FullDocumentID($DocumentID,$Version);
    
  my $Link = "<a href=\"$ShowDocument\?docid=$DocumentID";
  if ($Version != $Documents{$DocumentID}{NVersions}) { # For other than last one
    $Link .= "&amp;version=$Version";
  }
  $Link .= "\"";
  $Link .= " title=\"$FullDocID\"";
  $Link .= ">"; 

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
  } elsif ($NoVersion) {      # Like Project-doc-1234
    $Link .= &FullDocumentID($DocumentID);  
    $Link .= "</a>";
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
  print "-v$DocRevisions{$DocRevID}{Version}";
  print "</dd>\n";
  
  print "<dt>Document type:</dt>";
  my $type_link = &TypeLink($DocRevisions{$DocRevID}{DocTypeID},"short");
  print "<dd>$type_link</dd>\n";
}

sub FieldListChooser (%) {
  my %Params = @_;
  
  require "Fields.pm";
  require "FormElements.pm";
 
  my $Partition = $Params{-partition};

  if ($Partition == 1) {
    print "<tr>\n";
    print "<th>",FormElementTitle(-helplink => "customlist", -helptext => "Field",      -nocolon => $TRUE),"</th>\n";
    print "<th>",FormElementTitle(-helplink => "customlist", -helptext => "Row",        -nocolon => $TRUE),"</th>\n";
    print "<th>",FormElementTitle(-helplink => "customlist", -helptext => "Column",     -nocolon => $TRUE),"</th>\n";
    print "<th>",FormElementTitle(-helplink => "customlist", -helptext => "Row(s)",     -nocolon => $TRUE),"</th>\n";
    print "<th>",FormElementTitle(-helplink => "customlist", -helptext => "Columns(s)", -nocolon => $TRUE),"</th>\n";
    print "</tr>\n";
  }
  
  my %FormFields = %FieldTitles;

  $FormFields{xxxx}  = "-- Select a Field --";      # Add option for nothing
  $FormFields{Blank} = "Empty field (placeholder)"; # Add option for nothing
  
  my @Fields = sort keys %FormFields;

  print "<tr>";
  print "<td>\n";     
  print $query -> popup_menu (-name => "field$Partition",   -values => \@Fields, -default => "xxxx", -labels => \%FormFields);
  print "</td>\n";     
  print "<td>\n";     
  print $query -> popup_menu (-name => "row$Partition",     -values => [1..15],  -default => 1);
  print "</td>\n";     
  print "<td>\n";     
  print $query -> popup_menu (-name => "col$Partition",     -values => [1..15],  -default => $Partition);
  print "</td>\n";     
  print "<td>\n";     
  print $query -> popup_menu (-name => "rowspan$Partition", -values => [1..5],   -default => 1);
  print "</td>\n";     
  print "<td>\n";     
  print $query -> popup_menu (-name => "colspan$Partition", -values => [1..5],   -default => 1);
  print "</td>\n";     
  print "</tr>";

  return  
}  

1;
