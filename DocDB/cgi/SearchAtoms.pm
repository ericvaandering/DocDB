sub TextSearch {
  my ($Field,$Mode,$Words) = @_;
  
  my $Phrase = "";
  my $Join;
  my $Delimit;
  my @Atoms = ();
  
  if ($Mode eq "anysub" || $Mode eq "allsub" || $Mode eq "anyword" || $Mode eq "allword") {
    my @Words = split /\s+/,$Words;
    foreach $Word (@Words) {
      if ($Mode eq "anysub" || $Mode eq "allsub") {
        $Word =~ tr/[A-Z]/[a-z]/;
        push @Atoms,"LOWER($Field) like \"%$Word%\"";
      } elsif ($Mode eq "anyword" || $Mode eq "allword") {
        $Word =~ tr/[A-Z]/[a-z]/;
        push @Atoms,"LOWER($Field) REGEXP \"\[\[:<:\]\]$Word\[\[:>:\]\]\"";
      }
    }    
  }

  if      ($Mode eq "anysub" || $Mode eq "anyword") {
    $Join = " OR ";
  } elsif ($Mode eq "allsub" || $Mode eq "allword") {
    $Join = " AND ";
  }

  $Phrase = join $Join,@Atoms;  
  
  if ($Phrase) {$Phrase = "($Phrase)";}
  
  return $Phrase;
}

sub IDSearch {
  my ($Table,$Field,$Mode,@IDs) = @_;
  
  my $Phrase = "";
  my $Join;
  my $Delimit;
  my @Atoms = ();
  
  $Join = $Mode;
  
  foreach $ID (@IDs) {
    push @Atoms," $Field=$ID ";
  }  

  $Phrase = join $Join,@Atoms;  
  
  if ($Phrase) {$Phrase = "($Phrase)";}
  
  return $Phrase;
}

sub TopicSearch {
  my $revtopic_list;
  my ($Logic,$Type,@TopicIDs) = @_;
  if ($Type eq "minor") {
    $revtopic_list = $dbh -> prepare(
     "select DocRevID from RevisionTopic where MinorTopicID=?"); 
  } elsif ($Type eq "major") {
    $revtopic_list = $dbh -> prepare(
      "select DocRevID from RevisionTopic,MinorTopic ".
      "where RevisionTopic.MinorTopicID=MinorTopic.MinorTopicID ".
      "and MinorTopic.MajorTopicID=?");
  }  
    
  my %Revisions = ();
  my @Revisions = ();
  my $DocRevID;
  
  foreach $TopicID (@TopicIDs) {
    $revtopic_list -> execute($TopicID );
    $revtopic_list -> bind_columns(undef, \($DocRevID));
    my %TopicRevisions = ();
    while ($revtopic_list -> fetch) { # Make sure each topic only matches once
      ++$TopicRevisions{$DocRevID};
    }
    foreach $DocRevID (keys %TopicRevisions) {
      ++$Revisions{$DocRevID};
    }  
  }
  if ($Logic eq "AND") {
    foreach $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == $#TopicIDs+1) { # Require a match for each topic
        push @Revisions,$DocRevID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Revisions = keys %Revisions;
  }  
  
  return @Revisions;     
}

sub AuthorSearch {
  my $revtopic_list;
  my ($Logic,@AuthorIDs) = @_;
  $revauthor_list = $dbh -> prepare("select DocRevID from RevisionAuthor where AuthorID=?"); 
    
  my %Revisions = ();
  my @Revisions = ();
  my $DocRevID;
  
  foreach my $AuthorID (@AuthorIDs) {
    $revauthor_list -> execute($AuthorID);
    $revauthor_list -> bind_columns(undef, \($DocRevID));
    while ($revauthor_list -> fetch) {
      ++$Revisions{$DocRevID};
    }
  }
  if ($Logic eq "AND") {
    foreach $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == $#AuthorIDs+1) { # Require a match for each topic
        push @Revisions,$DocRevID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Revisions = keys %Revisions;
  }  
  
  return @Revisions;     
}

sub TypeSearch {
  my $document_list;
  my ($Logic,@TypeIDs) = @_;
  $document_list = $dbh -> prepare("select UNIQUE(DocumentID) from DocumentRevision where DocTypeID=?"); 
    
  my %Documents = ();
  my @Documents = ();
  my $DocumentID;
  
  foreach my $TypeID (@TypeIDs) {
    $document_list -> execute($TypeID);
    $document_list -> bind_columns(undef, \($DocumentID));
    while ($document_list -> fetch) {
      ++$Documents{$DocumentID};
    }
  }
  if ($Logic eq "AND") {
    foreach $DocumentID (keys %Documents) {
      if ($Documents{$DocumentID} == $#TypeIDs+1) { # Require a match for each type
        push @Documents,$DocumentID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Documents = keys %Documents;
  }  
  
  return @Documents;     
}

sub ValidateRevisions {
  require "RevisionSQL.pm";
  
  my (@RevisionIDs) = @_;
  my %DocumentIDs = ();
  my @DocumentIDs = ();
  
  foreach my $RevID (@RevisionIDs) {
    &FetchDocRevisionByID($RevID);
    unless ($DocRevisions{$RevID}{Obsolete}) {
      $DocumentIDs{$DocRevisions{$RevID}{DOCID}} = 1;
    }
  }
  @DocumentIDs = keys %DocumentIDs;
  return @DocumentIDs;
}

1;
