#
#        Name: $RCSfile$
# Description: SQL access routings for authors and institutions
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:

# Copyright 2001-2011 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub GetAuthors { # Creates/fills a hash $Authors{$AuthorID}{} with all authors
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID);
  my $people_list  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active,InstitutionID from Author");
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID));
  %Authors = ();
  %AuthorCounts = ();
  while ($people_list -> fetch) {
    $Authors{$AuthorID}{AUTHORID}  =  $AuthorID;
    if ($MiddleInitials) {
      $Authors{$AuthorID}{FULLNAME}  = "$FirstName $MiddleInitials $LastName";
      $Authors{$AuthorID}{Formal}    = "$LastName, $FirstName $MiddleInitials";
    } elsif ($FirstName) {
      $Authors{$AuthorID}{FULLNAME}  = "$FirstName $LastName";
      $Authors{$AuthorID}{Formal}    = "$LastName, $FirstName";
    } else {
      $Authors{$AuthorID}{FULLNAME}  = "$LastName";
      $Authors{$AuthorID}{Formal}    = "$LastName";
    }
    $Authors{$AuthorID}{LastName}      = $LastName;
    $Authors{$AuthorID}{FirstName}     = $FirstName;
    $Authors{$AuthorID}{ACTIVE}        = $Active;
    $Authors{$AuthorID}{InstitutionID} = $InstitutionID;
  }
  # Count how many times each author is listed
  my $AuthorCount = $dbh -> prepare("select DISTINCT RevisionAuthor.AuthorID,DocumentRevision.DocumentID ".
                                    "from RevisionAuthor ".
                                    "LEFT JOIN DocumentRevision on (RevisionAuthor.DocRevID=DocumentRevision.DocRevID)");
  $AuthorCount -> execute();
  $AuthorCount -> bind_columns(undef, \($AuthorID,$Count));
  while ($AuthorCount -> fetch) {
    if (exists $AuthorCounts{$AuthorID}{Exact}) {
      ++$AuthorCounts{$AuthorID}{Exact};
    } else {
      $AuthorCounts{$AuthorID}{Exact} = 1;
    }
  }

}

sub FetchAuthor { # Fetches an Author by ID, adds to $Authors{$AuthorID}{}
  my ($authorID) = @_;
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID);

  my $author_fetch  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active,InstitutionID ".
     "from Author ".
     "where AuthorID=?");
  if ($Authors{$authorID}{AUTHORID}) { # We already have this one
    return $Authors{$authorID}{AUTHORID};
  }

  $author_fetch -> execute($authorID);
  ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID) = $author_fetch -> fetchrow_array;
  $Authors{$AuthorID}{AUTHORID}  =  $AuthorID;
  if ($MiddleInitials) {
    $Authors{$AuthorID}{FULLNAME}  = "$FirstName $MiddleInitials $LastName";
    $Authors{$AuthorID}{Formal}    = "$LastName, $FirstName $MiddleInitials";
  } else {
    $Authors{$AuthorID}{FULLNAME}  = "$FirstName $LastName";
    $Authors{$AuthorID}{Formal}    = "$LastName, $FirstName";
  }
  $Authors{$AuthorID}{LastName}      = $LastName;
  $Authors{$AuthorID}{FirstName}     = $FirstName;
  $Authors{$AuthorID}{ACTIVE}        = $Active;
  $Authors{$AuthorID}{InstitutionID} = $InstitutionID;

  return $Authors{$AuthorID}{AUTHORID};
}

sub GetRevisionAuthors {
  my ($DocRevID) = @_;
  my @RevAuthorIDs = ();
  my ($RevAuthorID,$AuthorID,$AuthorOrder);
  my $AuthorList = $dbh->prepare(
    "select RevAuthorID,AuthorID,AuthorOrder from RevisionAuthor where DocRevID=?");
  $AuthorList -> execute($DocRevID);
  $AuthorList -> bind_columns(undef, \($RevAuthorID,$AuthorID,$AuthorOrder));
  while ($AuthorList -> fetch) {
    $RevisionAuthors{$RevAuthorID}{AuthorID}    = $AuthorID;
    $RevisionAuthors{$RevAuthorID}{AuthorOrder} = $AuthorOrder;
    push @RevAuthorIDs,$RevAuthorID;
  }
  return @RevAuthorIDs;
}

sub GetInstitutionAuthors { # Creates/fills a hash $Authors{$AuthorID}{} with authors from institution
  my ($InstitutionID) = @_;

  #FIXME: Make it call GetAuthor

  my @AuthorIDs = ();
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active);
  my $PeopleList  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active ".
     "from Author where InstitutionID=?");
  $PeopleList -> execute($InstitutionID);
  $PeopleList -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active));
  while ($PeopleList -> fetch) {
    push @AuthorIDs,$AuthorID;
    $Authors{$AuthorID}{AUTHORID}   =  $AuthorID;
    if ($MiddleInitials) {
      $Authors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
      $Authors{$AuthorID}{Formal}   = "$LastName, $FirstName $MiddleInitials";
    } else {
      $Authors{$AuthorID}{FULLNAME} = "$FirstName $LastName";
      $Authors{$AuthorID}{Formal}   = "$LastName, $FirstName";
    }
    $Authors{$AuthorID}{LastName}      =  $LastName;
    $Authors{$AuthorID}{FirstName}     =  $FirstName;
    $Authors{$AuthorID}{ACTIVE}        =  $Active;
    $Authors{$AuthorID}{InstitutionID} =  $InstitutionID;
  }
  return @AuthorIDs;
}

sub GetInstitutions { # Creates/fills a hash $Institutions{$InstitutionID}{} with all Institutions
  if ($HaveAllInstitutions) {
    return;
  }

  my ($InstitutionID,$ShortName,$LongName);
  my $inst_list  = $dbh -> prepare(
     "select InstitutionID,ShortName,LongName from Institution");
  $inst_list -> execute;
  $inst_list -> bind_columns(undef, \($InstitutionID,$ShortName,$LongName));
  %Institutions = ();
  while ($inst_list -> fetch) {
    $Institutions{$InstitutionID}{InstitutionID} = $InstitutionID;
    $Institutions{$InstitutionID}{SHORT}         = $ShortName;
    $Institutions{$InstitutionID}{LONG}          = $LongName;
  }
  $HaveAllInstitutions = 1;
}

sub ClearInstitutions {
  %Institutions = ();
  $HaveAllInstitutions = 0;
  return;
}

sub FetchInstitution { # Creates/fills a hash $Institutions{$InstitutionID}{} with all Institutions
  my ($InstitutionID) = @_;
  if ($Institutions{$InstitutionID}{InstitutionID}) {
    return;
  }

  my ($ShortName,$LongName);
  my $InstitutionFetch  = $dbh -> prepare(
     "select ShortName,LongName from Institution where InstitutionID=?");
  $InstitutionFetch -> execute($InstitutionID);
  ($ShortName,$LongName) = $InstitutionFetch -> fetchrow_array;
  $Institutions{$InstitutionID}{InstitutionID} = $InstitutionID;
  $Institutions{$InstitutionID}{SHORT}         = $ShortName;
  $Institutions{$InstitutionID}{LONG}          =  $LongName;
}

sub GetAuthorDocuments { # Return a list of all documents the author is associated with
  require "RevisionSQL.pm";

  my ($AuthorID) = @_;   # FIXME: Using join, can simplify into one SQL statement?

  my $List = $dbh -> prepare("select DISTINCT(DocumentRevision.DocumentID) from ".
              "DocumentRevision,RevisionAuthor where DocumentRevision.DocRevID=RevisionAuthor.DocRevID ".
              "and DocumentRevision.Obsolete=0 and RevisionAuthor.AuthorID=?");
  $List -> execute($AuthorID);

  my @DocumentIDs = ();
  my $DocumentID;
  $List -> bind_columns(undef, \($DocumentID));
  while ($List -> fetch) {
    push @DocumentIDs,$DocumentID;
  }
  return @DocumentIDs;
}

sub ProcessManualAuthors {
  my ($author_list,$ArgRef) = @_;
  my $Warn = exists $ArgRef->{-warn} ? $ArgRef->{-warn} : $FALSE;

  # FIXME: Handle authors in Smith, John format too

  my $AuthorID;
  my @AuthorIDs = ();
  my @AuthorEntries = split /\n/,$author_list;
  foreach my $entry (@AuthorEntries) {
    my @parts   = split /\s+/,$entry;
    my $first   = shift @parts;
    my $last    = pop @parts;
    my $initial = substr($first,0,1).".";

    unless ($first && $last) {
      if ($Warn) {
        push @WarnStack, "Your author entry $entry did not have a first and last name.";
      } else {
        push @ErrorStack,"Your author entry $entry did not have a first and last name.";
      }
      next;
    }

    my $author_list = $dbh -> prepare(
       "select AuthorID from Author where FirstName=? and LastName=?");
    my $fuzzy_list = $dbh -> prepare(
       "select AuthorID from Author where FirstName like ? and LastName=?");

### Find exact match (initial or full name)

    $author_list -> execute($first,$last);
    $author_list -> bind_columns(undef, \($AuthorID));
    @Matches = ();
    while ($author_list -> fetch) {
      push @Matches,$AuthorID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      push @AuthorIDs,$AuthorID;
      next;
    }

### Match initial if given initial or full name

    $author_list -> execute($initial,$last);
    $author_list -> bind_columns(undef, \($AuthorID));
    @Matches = ();
    while ($author_list -> fetch) {
      push @Matches,$AuthorID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      push @AuthorIDs,$AuthorID;
      next;
    }

### Match full name if given initial

    $first =~ s/\.//g;    # Remove dots if any
    $first .= "%";        # Add SQL wildcard
    $fuzzy_list -> execute($first,$last);
    $fuzzy_list -> bind_columns(undef, \($AuthorID));
    @Matches = ();
    while ($fuzzy_list -> fetch) {
      push @Matches,$AuthorID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      push @AuthorIDs,$AuthorID;
      next;
    }

### Haven't found a match if we get down here

# FIXME: Remove error_stack when modifications done.

    if ($Warn) {
      push @WarnStack, "No match was found for the author $entry.";
    } else {
      push @ErrorStack,"No match was found for the author $entry. Please go back and try again.";
    }
  }
  return @AuthorIDs;
}

sub MatchAuthor ($) {
  my ($ArgRef) = @_;
  my $Either = exists $ArgRef->{-either} ? $ArgRef->{-either} : "";
#  my $First = exists $ArgRef->{-first}  ? $ArgRef->{-first}  : "";
#  my $Last  = exists $ArgRef->{-last}   ? $ArgRef->{-last}   : "";

  my $AuthorID;
  my @MatchIDs = ();
  if ($Either) {
    $Either =~ tr/[A-Z]/[a-z]/;
    my $List = $dbh -> prepare(
       "select AuthorID from Author where LOWER(FirstName) like \"%$Either%\" or LOWER(LastName) like \"%$Either%\"");
    $List -> execute();
    $List -> bind_columns(undef, \($AuthorID));
    while ($List -> fetch) {
      push @MatchIDs,$AuthorID;
    }
  }
  return @MatchIDs;
}

sub InsertAuthors (%) {
  my %Params = @_;

  my $DocRevID  =   $Params{-docrevid}   || "";
  my $Order     =   $Params{-order}      || $FALSE;
  my @AuthorIDs = @{$Params{-authorids}};

  my $Count       = 0;
  my $AuthorOrder = 0;
  my $Insert = $dbh->prepare("insert into RevisionAuthor (RevAuthorID, DocRevID, AuthorID, AuthorOrder) values (0,?,?,?)");

  foreach my $AuthorID (@AuthorIDs) {
    if ($AuthorID) {
      if ($Order) {
        $AuthorOrder = $Count;
      }
      $Insert -> execute($DocRevID,$AuthorID,$AuthorOrder);
      ++$Count;
    }
  }

  return $Count;
}

1;
