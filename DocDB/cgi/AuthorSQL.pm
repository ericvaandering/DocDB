sub GetAuthors { # Creates/fills a hash $Authors{$AuthorID}{} with all authors
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID);
  my $people_list  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active,InstitutionID from Author"); 
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID));
  %Authors = ();
  while ($people_list -> fetch) {
    $Authors{$AuthorID}{AUTHORID}  =  $AuthorID;
    if ($MiddleInitials) {
      $Authors{$AuthorID}{FULLNAME}  = "$FirstName $MiddleInitials $LastName";
    } else {
      $Authors{$AuthorID}{FULLNAME}  = "$FirstName $LastName";
    }
    $Authors{$AuthorID}{LASTNAME}  =  $LastName;
    $Authors{$AuthorID}{FIRSTNAME} =  $FirstName;
    $Authors{$AuthorID}{ACTIVE}    =  $Active;
    $Authors{$AuthorID}{INST}      =  $InstitutionID;
    if ($Active) {
      $ActiveAuthors{$AuthorID}{FULLNAME} = $Authors{$AuthorID}{FULLNAME};
      $names{$AuthorID}                   = "$FirstName $MiddleInitials $LastName"; # FIXME
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
  } else {
    $Authors{$AuthorID}{FULLNAME}  = "$FirstName $LastName";
  }
  $Authors{$AuthorID}{LASTNAME}  =  $LastName;
  $Authors{$AuthorID}{FIRSTNAME} =  $FirstName;
  $Authors{$AuthorID}{ACTIVE}    =  $Active;
  $Authors{$AuthorID}{INST}      =  $InstitutionID;
  
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
  return @authors;  
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

sub ProcessManualAuthors {
  my ($author_list) = @_;
  my $AuthorID;
  my @AuthorIDs = ();
  my @AuthorEntries = split /\n/,$author_list;
  foreach my $entry (@AuthorEntries) {
    my @parts   = split /\s+/,$entry;
    my $first   = shift @parts;
    my $last    = pop @parts;
    my $initial = substr($first,0,1).".";
    
    unless ($first && $last) {
      push @error_stack,"Your author entry $entry did not have
                         a first and last name.";
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

    push @error_stack,"No match was found for the the author $entry. Please go 
                      back and try again.";   
  }
  return @AuthorIDs;
}


1;
