#
# Description: Routines to create HTML elements for authors and institutions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

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

sub FirstAuthor {
  require "AuthorSQL.pm";

  my ($DocRevID) = @_;

  &FetchDocRevisionByID($DocRevID);
  my @AuthorIDs = &GetRevisionAuthors($DocRevID);
  
  unless (@AuthorIDs) {return "None";}
  
  my $FirstID     = $AuthorIDs[0];
  my $SubmitterID = $DocRevisions{$DocRevID}{SUBMITTER};
  foreach $AuthorID (@AuthorIDs) {
    if ($AuthorID == $SubmitterID) {
      $FirstID = $SubmitterID;  # Submitter is in list --> first author
    }  
  }
  
  my $author_link = &AuthorLink($FirstID);
  if ($#AuthorIDs) {$author_link .= " <i>et. al.</i>";}
  return $author_link; 
}

sub AuthorListByID {
  my @AuthorIDs = @_;
  
  require "AuthorSQL.pm";
  
  if (@AuthorIDs) {
    print "<b>Authors:</b><br/>\n";
    print "<ul>\n";
    foreach my $AuthorID (@AuthorIDs) {
      &FetchAuthor($AuthorID);
      my $author_link = &AuthorLink($AuthorID);
      print "<li> $author_link </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Authors:</b> none<br/>\n";
  }
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
    print "<b>None<br/>\n";
  }
}

sub RequesterByID { 
  my ($RequesterID) = @_;
  my $author_link   = &AuthorLink($RequesterID);
  
  print "<tr><td align=right><b>Requested by:</b></td>";
  print "<td>$author_link</td></tr>\n";
}

sub SubmitterByID { 
  my ($RequesterID) = @_;
  my $author_link   = &AuthorLink($RequesterID);
  
  print "<tr><td align=right><b>Updated by:</b></td>";
  print "<td>$author_link</td></tr>\n";
}

sub AuthorLink ($;%) {
  require "AuthorSQL.pm";
  
  my ($AuthorID,%Params) = @_;
  my $Format = $Params{-format} || "full"; # full, formal
  
  &FetchAuthor($AuthorID);
  my $link;
  $link = "<a href=$ListByAuthor?authorid=$AuthorID>";
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
  &GetInstitutions; # FIXME: Can use FetchInstitution when exists
  my $link = &AuthorLink($AuthorID);
  
  print "$link\n";
  print " of ";
  print $Institutions{$Authors{$AuthorID}{INST}}{LONG};
}

sub AuthorsByInstitution { 
  my ($InstID) = @_;
  require "Sorts.pm";

  my @AuthorIDs = sort byLastName keys %Authors;

  print "<td><b>$Institutions{$InstID}{SHORT}</b>\n";
  print "<ul>\n";
  foreach my $AuthorID (@AuthorIDs) {
    if ($InstID == $Authors{$AuthorID}{INST}) {
      my $author_link = &AuthorLink($AuthorID);
      print "<li>$author_link\n";
    }  
  }  
  print "</ul>";
}

sub AuthorsTable {
  require "Sorts.pm";

  my @AuthorIDs = sort byLastName    keys %Authors;
  my $NCols     = 4;
  my $NPerCol   = int (scalar(@AuthorIDs)/$NCols + 1);
  my $NThisCol  = 0;

  print "<table>\n";
  print "<tr valign=top>\n";
  
  print "<td>\n";
  print "<ul>\n";
  
  foreach my $AuthorID (@AuthorIDs) {

    if ($NThisCol >= $NPerCol) {
      print "</ul></td>\n";
      print "<td>\n";
      print "<ul>\n";
      $NThisCol = 0;
    }
    ++$NThisCol;
    my $author_link = &AuthorLink($AuthorID, -format => "formal");
    print "<li>$author_link\n";
  }  
  print "</ul></td></tr>";
  print "</table>\n";
}

sub AuthorScroll (%) {
  require "AuthorSQL.pm";
  
  my (%Params) = @_;
  
  my $All       =   $Params{-showall}   || 0;
  my $Multiple  =   $Params{-multiple}  || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Authors";
  my $Required  =   $Params{-required}  || 0;
  my $Name      =   $Params{-name}      || "authors";
  my $Size      =   $Params{-size}      || 10;
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
    print "<b><a ";
    &HelpLink($HelpLink);
    print "$HelpText:</a></b>";
    if ($Required) {
      print $RequiredMark;
    }  
    print "<br> \n";
  }

  print $query -> scrolling_list(-name => $Name, -values => \@ActiveIDs, 
                                 -labels => \%AuthorLabels,
                                 -size => 10, -multiple => $Multiple,
                                 -default => \@Defaults);
}

sub AuthorTextEntry ($;@) {
  my ($ElementName,@Defaults) = @_;
  
  my $AuthorManDefault = "";

  foreach $AuthorID (@Defaults) {
    &FetchAuthor($AuthorID);
    $AuthorManDefault .= "$Authors{$AuthorID}{FULLNAME}\n" ;
  }  
  print $query -> textarea (-name    => $ElementName, 
                            -default => $AuthorManDefault,
                            -columns => 20, -rows    => 8);
};

sub InstitutionEntryBox {
  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print "<b><a ";
  &HelpLink("instentry");
  print "Short Name:</a></b><br> \n";
  print $query -> textfield (-name => 'short', 
                             -size => 30, -maxlength => 40);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print "<b><a ";
  &HelpLink("instentry");
  print "Long Name:</a></b><br> \n";
  print $query -> textfield (-name => 'long', 
                             -size => 40, -maxlength => 80);
  print "</td>\n";
  print "</tr></table>\n";
}

1;
