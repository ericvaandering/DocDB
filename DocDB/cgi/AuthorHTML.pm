#
# Description: Routines to create HTML elements for authors and institutions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

sub FirstAuthor ($) {
  my ($DocRevID) = @_;

  require "AuthorSQL.pm";
  require "Sorts.pm";

  FetchDocRevisionByID($DocRevID);
  my @AuthorIDs = sort byLastName GetRevisionAuthors($DocRevID);
  
  unless (@AuthorIDs) {return "None";}
  
  my $FirstID = FirstAuthorID( {-docrevid => $DocRevID} );

  my $AuthorLink = AuthorLink($FirstID);
  if ($#AuthorIDs) {$AuthorLink .= " <i>et. al.</i>";}
  return $AuthorLink; 
}

sub AuthorListByID {
  my @AuthorIDs = @_;
  
  require "AuthorSQL.pm";
  
  print "<div id=\"Authors\">\n";
  print "<dl>\n";
  print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Authors:</span></dt>\n";
  print "</dl>\n";

  if (@AuthorIDs) {
    print "<ul>\n";
    foreach my $AuthorID (@AuthorIDs) {
      &FetchAuthor($AuthorID);
      my $author_link = &AuthorLink($AuthorID);
      print "<li> $author_link </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<dd>None</dd>\n";
  }
  print "</div>\n";
}

sub ShortAuthorListByID {
  my @AuthorIDs = @_;
  
  require "AuthorSQL.pm";
  
  if (@AuthorIDs) {
    foreach my $AuthorID (@AuthorIDs) {
      &FetchAuthor($AuthorID);
      my $AuthorLink = &AuthorLink($AuthorID);
      print "$AuthorLink<br/>\n";
    }
  } else {
    print "None<br/>\n";
  }
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
  
  &FetchAuthor($AuthorID);
  &FetchInstitution($Authors{$AuthorID}{InstitutionID});
  my $InstitutionName = $Institutions{$Authors{$AuthorID}{InstitutionID}}{LONG};
  unless ($Authors{$AuthorID}{FULLNAME}) {
    return "Unknown";
  }  
  my $link;
  $link = "<a href=\"$ListBy?authorid=$AuthorID\" title=\"$InstitutionName\">";
  if ($Format eq "full") {
    $link .= $Authors{$AuthorID}{FULLNAME};
  } elsif ($Format eq "formal") {
    $link .= $Authors{$AuthorID}{Formal};
  }
  $link .= "</a>";
  
  return $link;
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

  print "<td><b>$Institutions{$InstID}{SHORT}</b>\n";
  print "<ul>\n";
  foreach my $AuthorID (@AuthorIDs) {
    if ($InstID == $Authors{$AuthorID}{InstitutionID}) {
      my $author_link = &AuthorLink($AuthorID);
      print "<li>$author_link\n";
    }  
  }  
  print "</ul>";
}

sub AuthorsTable {
  require "Sorts.pm";

  my @AuthorIDs     = sort byLastName keys %Authors;
  my $NCols         = 4;
  my $NPerCol       = int (scalar(@AuthorIDs)/$NCols);
  my $UseAnchors = (scalar(@AuthorIDs) >= 75);

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
        print "<b>$FirstLetter</b>\n";
      }
      print "<ul>\n";
    }  
    my $author_link = AuthorLink($AuthorID, -format => "formal");
    print "<li>$author_link</li>\n";
    $CloseLastColumn = 1;
  }  
  print "</ul></td></tr>";
  print "</table>\n";
}

sub AuthorScroll (%) {
  require "AuthorSQL.pm";
  require "Sorts.pm";
  
  my (%Params) = @_;
  
  my $All       =   $Params{-showall}   || 0;
  my $Multiple  =   $Params{-multiple}  || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Authors";
  my $Required  =   $Params{-required}  || 0;
  my $Name      =   $Params{-name}      || "authors";
  my $Size      =   $Params{-size}      || 10;
  my $Disabled  =   $Params{-disabled}  || "";
  my @Defaults  = @{$Params{-default}};

  unless (keys %Author) {
    &GetAuthors;
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
    my $ElementTitle = &FormElementTitle(-helplink  => $HelpLink, 
                                         -helptext  => $HelpText,
                                         -required  => $Required );
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
  my $HelpLink = exists $ArgRef->{-helplink} ?   $ArgRef->{-helplink} : "authormanual";
  my $HelpText = exists $ArgRef->{-helptext} ?   $ArgRef->{-helptext} : "Authors";           
  my $Name     = exists $ArgRef->{-name}     ?   $ArgRef->{-name}     : "authormanual";
  my $Required = exists $ArgRef->{-required} ?   $ArgRef->{-required} :  "0";
  my @Defaults = exists $ArgRef->{-default}  ? @{$ArgRef->{-default}} : ();

  my $AuthorManDefault = "";

  foreach $AuthorID (@Defaults) {
    FetchAuthor($AuthorID);
    $AuthorManDefault .= "$Authors{$AuthorID}{FULLNAME}\n" ;
  }  
  
  print FormElementTitle(-helplink => $HelpLink, -helptext => $HelpText, -required => $Required);
  print $query -> textarea (-name    => $Name, -default => $AuthorManDefault,
                            -columns => 20,    -rows    => 8);
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
  print "<b><a ";
  &HelpLink("instentry");
  print "Short Name:</a></b><br> \n";
  print $query -> textfield (-name => 'shortdesc', 
                             -size => 30, -maxlength => 40,$Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("instentry");
  print "Long Name:</a></b><br> \n";
  print $query -> textfield (-name => 'longdesc', 
                             -size => 40, -maxlength => 80,$Booleans);
  print "</td>\n";
  print "</tr></table>\n";
}

1;
