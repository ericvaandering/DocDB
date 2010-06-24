#
# Description: Routines to create HTML elements for authors and institutions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:
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

sub FirstAuthor ($;$) {
  my ($DocRevID,$ArgRef) = @_;
  my $Institution = exists $ArgRef->{-institution} ? $ArgRef->{-institution} : $FALSE;

  require "AuthorSQL.pm";
  require "AuthorUtilities.pm";
  require "Sorts.pm";

  FetchDocRevisionByID($DocRevID);

  my $FirstID = FirstAuthorID( {-docrevid => $DocRevID} );
  unless ($FirstID) {return "None";}
  my @AuthorRevIDs = GetRevisionAuthors($DocRevID);

  my $AuthorLink = AuthorLink($FirstID);
  if ($#AuthorRevIDs) {$AuthorLink .= " <i>et al.</i>";}
  if ($Institution) {
    FetchInstitution($Authors{$FirstID}{InstitutionID});
    $AuthorLink .= "<br/><em>".
                   $Institutions{$Authors{$FirstID}{InstitutionID}}{SHORT}.
                   "</em>";
  }
  return $AuthorLink;
}

sub AuthorListByAuthorRevID {
  my ($ArgRef) = @_;
  my @AuthorRevIDs = exists $ArgRef->{-authorrevids} ? @{$ArgRef->{-authorrevids}} : ();
  my $Format       = exists $ArgRef->{-format}       ?   $ArgRef->{-format}        : "long";
#  my $ListFormat  = exists $ArgRef->{-listformat}  ?   $ArgRef->{-listformat}  : "dl";
#  my $ListElement = exists $ArgRef->{-listelement} ?   $ArgRef->{-listelement} : "short";
#  my $LinkType    = exists $ArgRef->{-linktype}    ?   $ArgRef->{-linktype}    : "document";
#  my $SortBy      = exists $ArgRef->{-sortby}      ?   $ArgRef->{-sortby}      : "";

  require "AuthorUtilities.pm";
  require "Sorts.pm";

  @AuthorRevIDs = sort AuthorRevIDsByOrder @AuthorRevIDs;
  my @AuthorIDs = AuthorRevIDsToAuthorIDs({ -authorrevids => \@AuthorRevIDs, });

  my $HTML;
  if ($Format eq "long") {
    $HTML = AuthorListByID({ -listformat => "dl", -authorids => \@AuthorIDs });
  } elsif ($Format eq "short") {
    $HTML = AuthorListByID({ -listformat => "br", -authorids => \@AuthorIDs });
  }

  print $HTML;

}

sub AuthorListByID {
  my ($ArgRef) = @_;
  my @AuthorIDs   = exists $ArgRef->{-authorids}   ? @{$ArgRef->{-authorids}}  : ();
  my $ListFormat  = exists $ArgRef->{-listformat}  ?   $ArgRef->{-listformat}  : "dl";
#  my $ListElement = exists $ArgRef->{-listelement} ?   $ArgRef->{-listelement} : "short";
  my $LinkType    = exists $ArgRef->{-linktype}    ?   $ArgRef->{-linktype}    : "document";
  my $SortBy      = exists $ArgRef->{-sortby}      ?   $ArgRef->{-sortby}      : "";

  require "AuthorSQL.pm";
  require "Sorts.pm";

  foreach my $AuthorID (@AuthorIDs) {
    FetchAuthor($AuthorID);
  }

  if ($SortBy eq "name") {
    @AuthorIDs = sort byLastName     @AuthorIDs;
  }

  my ($HTML,$StartHTML,$EndHTML,$StartElement,$EndElement,$StartList,$EndList,$NoneText);

  if ($ListFormat eq "dl") {
    $StartHTML .= '<div id="Authors"><dl>';
    $StartHTML .= '<dt class="InfoHeader"><span class="InfoHeader">Authors:</span></dt>';
    $StartHTML .= '</dl>';
    $EndHTML    = '</div>';
    $StartList  = '<ul>';
    $EndList    = '</ul>';
    $StartElement = '<li>';
    $EndElement   = '</li>';
    $NoneText     = '<div id="Authors"><dl><dt class="InfoHeader"><span class="InfoHeader">Authors:</span></dt>None<br/></dl>';
  } else {  #$ListFormat eq "br"
    $StartHTML  = '<div>';
    $EndHTML    = '</div>';
    $EndElement = '<br/>';
    $NoneText   = 'None<br/>';
  }

  if (@AuthorIDs) {
    $HTML .= $StartHTML;
    $HTML .= $StartList;
    foreach my $AuthorID (@AuthorIDs) {
      $HTML .= $StartElement.AuthorLink($AuthorID,-type => $LinkType).$EndElement;
    }
    $HTML .= $EndList;
  } else {
    $HTML = $NoneText;
  }
  $HTML .= $EndHTML;

  return PrettyHTML($HTML);
}

sub RequesterByID {
  my ($RequesterID) = @_;

  my $AuthorLink   = &AuthorLink($RequesterID);
  print "<dt>Submitted by:</dt>\n";
  print "<dd>$AuthorLink</dd>\n";
}

sub SubmitterByID {
  my ($RequesterID) = @_;

  my $AuthorLink   = &AuthorLink($RequesterID);
  print "<dt>Updated by:</dt>\n";
  print "<dd>$AuthorLink</dd>\n";
}

sub AuthorLink ($;%) {
  require "AuthorSQL.pm";

  my ($AuthorID,%Params) = @_;
  my $Format = $Params{-format} || "full"; # full, formal
  my $Type   = $Params{-type}   || "document"; # document, event

  FetchAuthor($AuthorID);
  FetchInstitution($Authors{$AuthorID}{InstitutionID});
  my $InstitutionName = $Institutions{$Authors{$AuthorID}{InstitutionID}}{LONG};
  unless ($Authors{$AuthorID}{FULLNAME}) {
    return "Unknown";
  }
  my $Script;
  if ($Type eq "event") {
    $Script = $ListEventsBy;
  } else {
    $Script = $ListBy;
  }

  my $Link;
  $Link = "<a href=\"$Script?authorid=$AuthorID\" title=\"$InstitutionName\">";
  if ($Format eq "full") {
    $Link .= $Authors{$AuthorID}{FULLNAME};
  } elsif ($Format eq "formal") {
    $Link .= $Authors{$AuthorID}{Formal};
  }
  $Link .= "</a>";

  return $Link;
}

sub PrintAuthorInfo {
  require "AuthorSQL.pm";

  my ($AuthorID) = @_;

  &FetchAuthor($AuthorID);
  &FetchInstitution($Authors{$AuthorID}{InstitutionID});
  my $link = &AuthorLink($AuthorID);

  print "$link\n";
  print " of ";
  print $Institutions{$Authors{$AuthorID}{InstitutionID}}{LONG};
}

sub AuthorsByInstitution {
  my ($InstID) = @_;
  require "Sorts.pm";

  my @AuthorIDs = sort byLastName keys %Authors;

  print "<td><strong>$Institutions{$InstID}{SHORT}</strong>\n";
  print "<ul>\n";
  foreach my $AuthorID (@AuthorIDs) {
    if ($InstID == $Authors{$AuthorID}{InstitutionID}) {
      my $author_link = &AuthorLink($AuthorID);
      print "<li>$author_link</li>\n";
    }
  }
  print "</ul></td>";
}

sub AuthorsTable {
  require "Sorts.pm";
  require "MeetingSQL.pm";
  require "MeetingHTML.pm";

  my @AuthorIDs     = sort byLastName keys %Authors;
  my $NCols         = 4;
  my $NPerCol       = int (scalar(@AuthorIDs)/$NCols);
  my $UseAnchors    = (scalar(@AuthorIDs) >= 75);
  my $CheckEvent    = $TRUE;

  if (scalar(@AuthorIDs) % $NCols) {++$NPerCol;}

  print "<table class=\"CenteredTable MedPaddedTable\">\n";
  if ($UseAnchors ) {
    print "<tr><th colspan=\"$NCols\">\n";
    foreach my $Letter (A..Z) {
      print "<a href=\"#$Letter\">$Letter</a>\n";
    }
    print "</th></tr>\n";
  }

  print "<tr>\n";

  my $NThisCol       = 0;
  my $PreviousLetter = "";
  my $FirstPass       = 1; # First sub-list of column
  my $StartNewColumn  = 1;
  my $CloseLastColumn = 0;
  foreach my $AuthorID (@AuthorIDs) {
    $FirstLetter = substr $Authors{$AuthorID}{LastName},0,1;
    $FirstLetter =~ tr/[a-z]/[A-Z]/;
    if ($NThisCol >= $NPerCol && $FirstLetter ne $PreviousLetter) {
      $StartNewColumn = 1;
    }

    if ($StartNewColumn) {
      if ($CloseLastColumn) {
        print "</ul></td>\n";
      }
      print "<td>\n";
      $StartNewColumn = 0;
      $NThisCol = 0;
      $FirstPass = 1;
    }

    ++$NThisCol;

    if ($FirstLetter ne $PreviousLetter) {
      $PreviousLetter = $FirstLetter;
      unless ($FirstPass) {
        print "</ul>\n";
      }
      $FirstPass = 0;
      if ($UseAnchors) {
        print "<a name=\"$FirstLetter\" />\n";
        print "<strong>$FirstLetter</strong>\n";
      }
      print "<ul>\n";
    }
    my $AuthorLink = AuthorLink($AuthorID, -format => "formal");
#    if ($CheckEvent) {
#      my %Hash = GetEventHashByModerator($AuthorID);
#      if (%Hash) {
#        $AuthorLink .= ListByEventLink({ -authorid => $AuthorID });
#      }
#    }

    print "<li>$AuthorLink</li>\n";
    $CloseLastColumn = 1;
  }
  print "</ul></td></tr>";
  print "</table>\n";
}


# FIXME: This is no longer used and can be removed
sub AuthorChooser {
  my ($ArgRef) = @_;
  my $Depth      = exists $ArgRef->{-depth}      ?   $ArgRef->{-depth}      : 2;
  my @DefaultAuthorIDs = exists $ArgRef->{-defaultauthorids}   ? @{$ArgRef->{-defaultauthorids}}  : ();
  my $Name   = exists $ArgRef->{-name}   ?   $ArgRef->{-name}   : "authors";
  my $HelpLink   = exists $ArgRef->{-helplink}   ?   $ArgRef->{-helplink}   : "authors";
  my $HelpText   = exists $ArgRef->{-helptext}   ?   $ArgRef->{-helptext}   : "Authors";
  my $ExtraText =   exists $ArgRef->{-extratext}   ?   $ArgRef->{-extratext}   : "Authors";
  my $Required   = exists $ArgRef->{-required}   ?   $ArgRef->{-required}   : $TRUE;
  my $Multiple  =    exists $ArgRef->{-multiple}   ?   $ArgRef->{-multiple}   :   0;
  my $ExtraText =   $Params{-extratext} || "";
  my $HTML;
  unless (keys %Author) {
    GetAuthors();
  }

  my @AuthorIDs = sort byLastName keys %Authors;
  my %AuthorLabels = ();
  my @ActiveIDs = ();
  foreach my $ID (@AuthorIDs) {
    if ($Authors{$ID}{ACTIVE} || $All) {
      $AuthorLabels{$ID} = $Authors{$ID}{Formal};
      push @ActiveIDs,$ID;
    }
  }
  if ($HelpLink) {
    $HTML .= FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                              -required => $Required, -extratext => $ExtraText, );
    $HTML .= "\n";
  }

  $HTML .= '<ul class="mktree" id="AuthorTree">'."\n";
  my $LastLetter = 'Nothing';
  my $LastSecond = 'Nothing';
  my $IsOpen = $FALSE;
  my $SecondOpen = $FALSE;
  my ($FirstLetter,$SecondLetter,$NodeClass);

  # Loop over default AuthorIDs to find lists that should be left open

  my %OpenLists = ();
  foreach my $AuthorID (@DefaultAuthorIDs) {
    $SecondLetter = substr $Authors{$AuthorID}{LastName},0,2;
    $SecondLetter =~ tr/[A-Z]/[a-z]/;
    $SecondLetter =~ s/\b(\w)/\u$1/g;
    $FirstLetter = substr $SecondLetter,0,1;

    $OpenLists{$FirstLetter} = $TRUE;
    $OpenLists{$SecondLetter} = $TRUE;
  }

  foreach my $AuthorID (@AuthorIDs) {
    $SecondLetter = substr $Authors{$AuthorID}{LastName},0,2;
    $SecondLetter =~ tr/[A-Z]/[a-z]/;
    $SecondLetter =~ s/\b(\w)/\u$1/g;
    $FirstLetter = substr $SecondLetter,0,1;

    if ($FirstLetter ne $LastLetter) {
      if ($IsOpen) {
        $HTML .= "</ul></li></ul>\n";
        $SecondOpen = $FALSE;
      }
      if ($OpenLists{$FirstLetter}) {
        $NodeClass = "liOpen";
      } else {
        $NodeClass = "liClosed";
      }
      $HTML .= "<li class=\"$NodeClass\">";
      $HTML .= "Beginning with ".$FirstLetter;
      $HTML .= "<ul>\n";
      $IsOpen = $TRUE;
      $LastLetter = $FirstLetter;
    }

    if ($SecondLetter ne $LastSecond) {
      if ($SecondOpen) {
        $HTML .= "</ul>\n";
      }
      if ($OpenLists{$SecondLetter}) {
        $NodeClass = "liOpen";
      } else {
        $NodeClass = "liClosed";
      }

      $HTML .= "<li class=\"$NodeClass\">";
      $HTML .= $SecondLetter;
      $HTML .= "<ul>\n";
      $SecondOpen = $TRUE;
      $LastSecond = $SecondLetter;
    }
    $HTML .= '<li class="3-deep">';
    if ($Multiple) {
      if (defined IndexOf($AuthorID,@DefaultAuthorIDs)) {
        $HTML.= $query -> checkbox(-name => $Name, -value => $AuthorID, -label => $AuthorLabels{$AuthorID}, -checked => 'checked',);
      } else {
        $HTML.= $query -> checkbox(-name => $Name, -value => $AuthorID, -label => $AuthorLabels{$AuthorID},);
      }
    } else {
      if (defined IndexOf($AuthorID,@DefaultAuthorIDs)) {
        $HTML.= '<label><input type="radio" name="'.$Name.
                '" value="'.$AuthorID.'" checked="checked" />'.$AuthorLabels{$AuthorID}.'</label>'."\n";
      } else {
        $HTML.= '<label><input type="radio" name="'.$Name.
                '" value="'.$AuthorID.'" />'.$AuthorLabels{$AuthorID}.'</label>'."\n";
      }
    }
    $HTML .= "</li>\n";

  }
  print "</ul></li></ul></ul>\n";
  print $HTML;
}

sub RequesterActiveSearch {
  my ($ArgRef) = @_;
  my $DefaultID = exists $ArgRef->{-default}   ? $ArgRef->{-default}  : 0;
  my $Name   = exists $ArgRef->{-name}   ?   $ArgRef->{-name}   : "requester";
  my $HelpLink   = exists $ArgRef->{-helplink}   ?   $ArgRef->{-helplink}   : "authors";
  my $HelpText   = exists $ArgRef->{-helptext}   ?   $ArgRef->{-helptext}   : "Submitter";
  my $Required   = exists $ArgRef->{-required}   ?   $ArgRef->{-required}   : $TRUE;
  my $ExtraText =   $Params{-extratext} || "";

  my $HTML;
  if ($HelpLink) {
    $HTML .= FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                              -required => $Required, -extratext => $ExtraText, );
    $HTML .= "\n";
  }

  my ($Default, $DefaultName);
  if ($DefaultID) {
    $Default = $DefaultID;
    $DefaultName = $Authors{$DefaultID}{Formal};
  }

  $HTML .= '<ul id="padding_ul"></ul>'."\n";
  $HTML .= '<input name="requester_text" type="text" id="requester-submitter" value="'.$DefaultName.'">'.
           '<input name="requester" type="hidden" id="requester-submitter-id" value="'.$Default.'">'."\n";
  return $HTML;
}

sub AuthorActiveSearch {
  my ($ArgRef) = @_;
  my $Depth      = exists $ArgRef->{-depth}      ?   $ArgRef->{-depth}      : 2;
  my @DefaultAuthorIDs = exists $ArgRef->{-defaultauthorids}   ? @{$ArgRef->{-defaultauthorids}}  : ();
  my $Name   = exists $ArgRef->{-name}   ?   $ArgRef->{-name}   : "authors";
  my $HelpLink   = exists $ArgRef->{-helplink}   ?   $ArgRef->{-helplink}   : "authors";
  my $HelpText   = exists $ArgRef->{-helptext}   ?   $ArgRef->{-helptext}   : "Authors";
  my $Required   = exists $ArgRef->{-required}   ?   $ArgRef->{-required}   : $TRUE;
  my $ExtraText =   $Params{-extratext} || "";

  my @AuthorIDs = sort byLastName keys %Authors;

  my $HTML;

  if ($HelpLink) {
    $HTML .= FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                              -required => $Required, -extratext => $ExtraText, );
    $HTML .= "\n";
  }
  $HTML .= '<div id="sel_authors_box">'."\n";
  $HTML .= '<ul id="authors_id_span"></ul>'."\n";
  $HTML .= '</div>'."\n";
  $HTML .= '<input name="authors_selection_text" type="text" id="authors_selector"><br /> (click or press <i>Enter</i>)'."\n";

  if (@DefaultAuthorIDs) {
    $HTML .= '<script type="text/javascript">
                <!--

                $().ready(function() {';
    foreach my $AuthorID (@DefaultAuthorIDs) {
      # /* call this function for each author, with authors_id and title [do not forget to escape it]  */
      $HTML .= 'addAuthorList(['.$AuthorID.', "'.$Authors{$AuthorID}{Formal}.'"]);'."\n";
    }
    $HTML .= '});

                // -->
        </script>';
  }
  return $HTML;

}

sub AuthorScroll (%) {
  require "AuthorSQL.pm";
  require "Sorts.pm";

  my (%Params) = @_;

  my $All       =   $Params{-showall}   || 0;
  my $Multiple  =   $Params{-multiple}  || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Authors";
  my $ExtraText =   $Params{-extratext} || "";
  my $Required  =   $Params{-required}  || 0;
  my $Name      =   $Params{-name}      || "authors";
  my $Size      =   $Params{-size}      || 10;
  my $Disabled  =   $Params{-disabled}  || "";
  my @Defaults  = @{$Params{-default}};

  unless (keys %Author) {
    GetAuthors();
  }

  my @AuthorIDs = sort byLastName keys %Authors;
  my %AuthorLabels = ();
  my @ActiveIDs = ();
  foreach my $ID (@AuthorIDs) {
    if ($Authors{$ID}{ACTIVE} || $All) {
      $AuthorLabels{$ID} = $Authors{$ID}{Formal};
      push @ActiveIDs,$ID;
    }
  }
  if ($HelpLink) {
    my $ElementTitle = FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                                        -required => $Required, -extratext => $ExtraText, );
    print $ElementTitle,"\n";
  }
  if ($Disabled) { # FIXME: Use Booleans
    print $query -> scrolling_list(-name => $Name, -values => \@ActiveIDs,
                                   -labels => \%AuthorLabels,
                                   -size => 10, -multiple => $Multiple,
                                   -default => \@Defaults, -disabled);
  } else {
    print $query -> scrolling_list(-name => $Name, -values => \@ActiveIDs,
                                   -labels => \%AuthorLabels,
                                   -size => 10, -multiple => $Multiple,
                                   -default => \@Defaults);
  }
}

sub AuthorTextEntry ($;@) {
  my ($ArgRef) = @_;

#  my $Disabled = exists $ArgRef->{-disabled} ?   $ArgRef->{-disabled} : "0";
  my $HelpLink  = exists $ArgRef->{-helplink}  ?   $ArgRef->{-helplink}  : "authormanual";
  my $HelpText  = exists $ArgRef->{-helptext}  ?   $ArgRef->{-helptext}  : "Authors";
  my $Name      = exists $ArgRef->{-name}      ?   $ArgRef->{-name}      : "authormanual";
  my $Required  = exists $ArgRef->{-required}  ?   $ArgRef->{-required}  : $FALSE;
  my $ExtraText = exists $ArgRef->{-extratext} ?   $ArgRef->{-extratext} : "";
  my @Defaults  = exists $ArgRef->{-default}   ? @{$ArgRef->{-default}}  : ();

  my $AuthorManDefault = "";

  foreach $AuthorID (@Defaults) {
    FetchAuthor($AuthorID);
    $AuthorManDefault .= "$Authors{$AuthorID}{FULLNAME}\n" ;
  }

  print FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                         -required => $Required, -extratext => $ExtraText, );
  print $query -> textarea (-name    => $Name, -default => $AuthorManDefault,
                            -columns => 25,    -rows    => 8);
};

sub InstitutionEntryBox (;%) {
  my (%Params) = @_;

  my $Disabled = $Params{-disabled}  || "0";

  my $Booleans = "";

  if ($Disabled) {
    $Booleans .= "-disabled";
  }

  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "instentry", -helptext => "Short Name");
  print $query -> textfield (-name => 'shortdesc',
                             -size => 30, -maxlength => 40,$Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print FormElementTitle(-helplink => "instentry", -helptext => "Long Name");
  print $query -> textfield (-name => 'longdesc',
                             -size => 40, -maxlength => 80,$Booleans);
  print "</td>\n";
  print "</tr></table>\n";
}

1;
