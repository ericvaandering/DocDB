sub FirstAuthor {
  require "AuthorSQL.pm";

  my ($DocRevID) = @_;

  &FetchDocRevisionByID($DocRevID);
  my $Authors_ref = &GetRevisionAuthors($DocRevID);
  my @AuthorIDs = @{$Authors_ref};
  
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
  
  if (@AuthorIDs) {
    print "<b>Authors:</b><br>\n";
    print "<ul>\n";
    foreach $AuthorID (@AuthorIDs) {
      &FetchAuthor($AuthorID);
      my $author_link = &AuthorLink($AuthorID);
      print "<li> $author_link </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Authors:</b> none<br>\n";
  }
}

sub RequesterByID { # Uses non HTML-4.01 <nobr> tag. 
  my ($RequesterID) = @_;
  my $author_link   = &AuthorLink($RequesterID);
  
  print "<nobr><b>Requested by:</b> ";
  print "$author_link</nobr><br>\n";
}

sub SubmitterByID { # Uses non HTML-4.01 <nobr> tag.
  my ($RequesterID) = @_;
  my $author_link   = &AuthorLink($RequesterID);
  
  print "<nobr><b>Updated by:</b> ";
  print "$author_link</nobr><br>\n";
}

sub AuthorLink {
  require "AuthorSQL.pm";
  
  my ($AuthorID) = @_;
  
  &FetchAuthor($AuthorID);
  my $link;
  $link = "<a href=$ListByAuthor?authorid=$AuthorID>";
  $link .= $Authors{$AuthorID}{FULLNAME};
  $link .= "</a>";
  
  return $link;
}

sub PrintAuthorInfo {
  require "AuthorSQL.pm";

  my ($AuthorID) = @_;
  
  &FetchAuthor($AuthorID);
  my $link = &AuthorLink($AuthorID);
  
  print "$link\n";
  print " of ";
  print $Institutions{$Authors{$AuthorID}{INST}}{LONG};
}

sub AuthorsTable {
  require "Sorts.pm";

  my $NCols = 4;
  my @InstIDs   = sort byInstitution keys %Institutions;
  my @AuthorIDs = sort byLastName    keys %Authors;

  my $Col = 0;
  print "<table cellpadding=10>\n";
  foreach my $InstID (@InstIDs) {
    unless ($Col % $NCols) {
      print "<tr valign=top>\n";
    }
    print "<td><b>$Institutions{$InstID}{SHORT}</b>\n";
    ++$Col;
    print "<ul>\n";
    foreach my $AuthorID (@AuthorIDs) {
      if ($InstID == $Authors{$AuthorID}{INST}) {
        my $author_link = &AuthorLink($AuthorID);
        print "<li>$author_link\n";
      }  
    }  
    print "</ul>";
  }  
  print "</table>\n";
}


1;
