sub GetAuthors { # Creates/fills a hash $Authors{$AuthorID}{} with all authors
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active);
  my $people_list  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active from Author"); 
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active));
  %Authors = ();
  while ($people_list -> fetch) {
    $Authors{$AuthorID}{AUTHORID} =  $AuthorID;
    $Authors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
    $Authors{$AuthorID}{LASTNAME} =  $LastName;
    $Authors{$AuthorID}{ACTIVE}   =  $Active;
    if ($Active) {
      $ActiveAuthors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
      $names{$AuthorID}                   = "$FirstName $MiddleInitials $LastName"; # FIXME
    }
  }
}

sub FetchAuthor { # Fetches an Author by ID, adds to $Authors{$AuthorID}{}
  my ($authorID) = @_;
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active);

  my $author_fetch  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active ". 
     "from Author ". 
     "where AuthorID=?");
  if ($Authors{$authorID}{AUTHORID}) { # We already have this one
    return $Authors{$authorID}{AUTHORID};
  }
  
  $author_fetch -> execute($authorID);
  ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active) = $author_fetch -> fetchrow_array;
  $Authors{$AuthorID}{AUTHORID} =  $AuthorID;
  $Authors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
  $Authors{$AuthorID}{LASTNAME} =  $LastName;
  $Authors{$AuthorID}{ACTIVE}   =  $Active;
  
  return $Authors{$AuthorID}{AUTHORID};
}

sub GetRevisionAuthors {
  my ($DocRevID) = @_;
  my @authors = ();
  my ($RevAuthorID,$AuthorID);
  my $author_list = $dbh->prepare(
    "select RevAuthorID,AuthorID from RevisionAuthor where DocRevID=?");
  $author_list -> execute($DocRevID);
  $author_list -> bind_columns(undef, \($RevAuthorID,$AuthorID));
  while ($author_list -> fetch) {
    push @authors,$AuthorID;
  }
  return \@authors;  
}

sub GetInstitutions { # Creates/fills a hash $Institutions{$InstitutionID}{} with all Institutions
  my ($InstitutionID,$ShortName,$LongName);
  my $inst_list  = $dbh -> prepare(
     "select InstitutionID,ShortName,LongName from Institution"); 
  $inst_list -> execute;
  $inst_list -> bind_columns(undef, \($InstitutionID,$ShortName,$LongName));
  %Institutions = ();
  while ($inst_list -> fetch) {
    $Institutions{$InstitutionID}{INSTID} =  $InstitutionID;
    $Institutions{$InstitutionID}{SHORT} = $ShortName;
    $Institutions{$InstitutionID}{LONG} =  $LongName;
  }
}

1;
