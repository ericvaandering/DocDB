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

sub TitleBox (%) {
  my (%Params) = @_; 
  
  my $Required   = $Params{-required}   || 0;

  print "<b><a ";
  &HelpLink("title");
  print "Title:</a></b>";
  if ($Required) {
    print $RequiredMark;
  }  
  print "<br> \n";
  print $query -> textfield (-name => 'title', -default => $TitleDefault, 
                             -size => 70, -maxlength => 240);
};

sub AbstractBox (%) {
  my (%Params) = @_; 
  
  my $Required = $Params{-required} || 0;
  my $HelpLink = $Params{-helplink} || "abstract";
  my $HelpText = $Params{-helptext} || "Abstract";
  my $Name     = $Params{-name}     || "abstract";
  my $Columns  = $Params{-columns}  || 60;
  my $Rows     = $Params{-rows}     || 6;

  if ($HelpLink) {
    print "<b><a ";
    &HelpLink($HelpLink);
    print "$HelpText</a></b>";
    if ($Required) {
      print $RequiredMark;
    }  
    print "<br> \n";
  }  
  print $query -> textarea (-name    => $Name, -default => $AbstractDefault,
                            -rows    => $Rows, -columns => $Columns);
};

sub RevisionNoteBox {
  my (%Params) = @_;
  my $Default  = $Params{-default}  || "";
  my $JSInsert = $Params{-jsinsert} || "";
  print "<a name=\"RevisionNote\">";
  print "<b><a ";
  &HelpLink("revisionnote");
  print "Notes and Changes:</a> </b>\n";

  # Convert text string w/ control characters to JS literal

  if ($JSInsert) {
    $JSInsert =~ s/\n/\\n/g;
    $JSInsert =~ s/\r//g;
    $JSInsert =~ s/\'/\\\'/g;
    $JSInsert =~ s/\"/\\\'/g; # FIXME: See if there is a way to insert double quotes
                              #        Bad HTML/JS interaction, I think

    print "<a href=\"#RevisionNote\" onClick=\"InsertRevisionNote('$JSInsert');\">(Insert notes from previous version)</a>";
  }
  print "<br>\n";
  print $query -> textarea (-name => 'revisionnote', -default => $Default,
                            -columns => 60, -rows => 6);
};

sub DocTypeButtons (%) {
# FIXME Get rid of fetches, make sure GetDocTypes is executed
  my (%Params) = @_; 
  
  my $Required   = $Params{-required}   || 0;

  my ($DocTypeID,$ShortType,$LongType);
  my $doctype_list  = $dbh->prepare("select DocTypeID,ShortType,LongType from DocumentType");
  $doctype_list -> execute;
  $doctype_list -> bind_columns(undef, \($DocTypeID,$ShortType,$LongType));
  while ($doctype_list -> fetch) {
    $doc_type{$DocTypeID}{SHORT} = $ShortType;
    $short_type{$DocTypeID}      = $ShortType;
    $doc_type{$DocTypeID}{LONG}  = $LongType;
  }
  @values = keys %short_type;
  
  print "<b><a ";
  &HelpLink("doctype");
  print "Document type:</a></b>";
  if ($Required) {
    print $RequiredMark;
  }  
  print "<br> \n";
  print $query -> radio_group(-columns => 3, -name => "doctype", 
                              -values => \%short_type, -default => "-");
};

sub PrintRevisionInfo {

  require "FormElements.pm";
  require "AuthorSQL.pm";
  require "SecuritySQL.pm";
  require "TopicSQL.pm";
  require "Security.pm";
 
  my ($DocRevID,$HideButtons) = @_;

  &FetchDocRevisionByID($DocRevID);
  
  my $DocumentID  = $DocRevisions{$DocRevID}{DOCID};
  my $Version     = $DocRevisions{$DocRevID}{VERSION};
  my @AuthorIDs   = &GetRevisionAuthors($DocRevID);
  my @TopicIDs    = &GetRevisionTopics($DocRevID);
  my @GroupIDs    = &GetRevisionSecurityGroups($DocRevID);
  my @ModifyIDs;
  if ($EnhancedSecurity) {
    @ModifyIDs   = &GetRevisionModifyGroups($DocRevID);
  }
  
  print "<div id=\"RevisionInfo\">\n";
  
  ### Header info
  
  print "<div id=\"Header3Col\">\n";

  print "<div id=\"DocTitle\">\n";
   &PrintTitle($DocRevisions{$DocRevID}{Title});
   if ($UseSignoffs) {
     require "SignoffUtilities.pm";
     my ($ApprovalStatus,$LastApproved) = &RevisionStatus($DocRevID);
     unless ($ApprovalStatus eq "Unmanaged") { 
       print "(Document Status: $ApprovalStatus)";
     }  
   }  
  print "</div>\n";  # DocTitle
  print "</div>\n";  # Header3Col

  ### Left Column

  print "<div id=\"LeftColumn3Col\">\n";
  print "<div id=\"DocumentID\">\n";
   &PrintDocNumber($DocRevID);
  print "</div>\n";
  
  print "<div id=\"Requester\">\n";
   &RequesterByID($Documents{$DocumentID}{REQUESTER});
   &SubmitterByID($DocRevisions{$DocRevID}{SUBMITTER});
  print "</div>\n";

  print "<div id=\"BasicDocInfo\">\n";
   &ModTimes;
  print "</div>\n";
  
  print "<div id=\"OtherVersions\">\n";
  print "</div>\n";
  
  print "</div>\n";  # LeftColumn3Col

  ### Right column (wrapped around by middle column)

  print "<div id=\"RightColumn3Col\">\n";
  
  print "<div id=\"Files\">\n";
   &FileListByRevID($DocRevID);
  print "</div>\n";
  
  print "<div id=\"Authors\">\n";
   &AuthorListByID(@AuthorIDs);
  print "</div>\n";

  print "<div id=\"Topics\">\n";
   &TopicListByID(@TopicIDs);
  print "</div>\n";

  print "<div id=\"Viewable\">\n";
   &SecurityListByID(@GroupIDs);
  print "</div>\n";

  if ($EnhancedSecurity) {
    print "<div id=\"Modifiable\">\n";
     &ModifyListByID(@ModifyIDs);
    print "</div>\n";
  }

  print "</div>\n";  # RightColumn3Col
  
  ### Main Column
  
  print "<div id=\"MainColumn3Col\">\n";

  print "<div id=\"Abstract\">\n";
   &PrintAbstract($DocRevisions{$DocRevID}{ABSTRACT});
  print "</div>\n";
  
  print "<div id=\"Keywords\">\n";
   &PrintKeywords($DocRevisions{$DocRevID}{Keywords});
  print "</div>\n";
  
  print "<div id=\"RevisionNote\">\n";
   &PrintRevisionNote($DocRevisions{$DocRevID}{Note});
  print "</div>\n";
  
  print "<div id=\"Reference\">\n";
   &PrintReferenceInfo($DocRevID);
  print "</div>\n";
  
  print "<div id=\"ConfereneInfo\">\n";
   &PrintConfInfo(@TopicIDs);
  print "</div>\n";
  
  print "<div id=\"PubInfo\">\n";
   &PrintPubInfo($DocRevisions{$DocRevID}{PUBINFO});
  print "</div>\n";
  
  if ($UseSignoffs) {
    require "SignoffHTML.pm";
    print "<div id=\"Signoffs\">\n";
    &PrintRevisionSignoffInfo($DocRevID);
    print "</div>\n";
  }  
  print "</div>\n";  # MainColumn3Col

  if (&CanModify($DocumentID) && !$HideButtons) {
    print "<hr width=\"90%\"/>\n";
    print "<table cellpadding=10>\n";
    print "<tr valign=top>";
    print "<td align=center width=33%>";
    &UpdateButton($DocumentID);
    print "<td align=center width=33%>";
    &UpdateDBButton($DocumentID,$Version);
    print "<td align=center width=33%>";
    &AddFilesButton($DocumentID,$Version);
    print "</td></tr>\n";
    print "</table></center>\n"; 
  }  

}
 
sub PrintAbstract {
  my ($Abstract) = @_;
  
  if ($Abstract) {
    $Abstract = &URLify($Abstract);
    $Abstract =~ s/\n\n/<p>/g;
    $Abstract =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt><b>Abstract:</b><br>\n";
    print "<dd>$Abstract<br>\n";
    print "</dl>\n";
  } else {
    print "<b>Abstract:</b> none<br>\n";
  }
}

sub PrintKeywords {
  my ($Keywords) = @_;
  
  require "KeywordHTML.pm";
  
  $Keywords =~ s/^\s+//;
  $Keywords =~ s/\s+$//;
  
  if ($Keywords) {
    print "<dl>\n";
    print "<dt><b>Keywords:</b><br>\n";
    print "<dd>\n";
    my @Keywords = split /\,*\s+/,$Keywords;
    my $Link;
    foreach my $Keyword (@Keywords) {
      $Link = &KeywordLink($Keyword);
      print "$Link \n";
    }  
    print "<br></dl>\n";
  }
}

sub PrintRevisionNote {
  require "Utilities.pm";

  my ($RevisionNote) = @_;
  if ($RevisionNote) {
    $RevisionNote = &URLify($RevisionNote);
    $RevisionNote =~ s/\n\n/<p>/g;
    $RevisionNote =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt><b>Notes and Changes:</b><br>\n";
    print "<dd>$RevisionNote<br>\n";
    print "</dl>\n";
  }
}

sub PrintPubInfo ($) {
  require "Utilities.pm";

  my ($pubinfo) = @_;
  if ($pubinfo) {
    $pubinfo = &URLify($pubinfo);
    $pubinfo =~ s/\n\n/<p>/g;
    $pubinfo =~ s/\n/<br>/g;
    print "<dl>\n";
    print "<dt><b>Publication Information:</b><br>\n";
    print "<dd>$pubinfo<br>\n";
    print "</dl>\n";
  }
}

1;
