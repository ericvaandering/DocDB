sub TextSearch {
  my ($Field,$Mode,$Words) = @_;
  
  my $Phrase = "";
  my $Join;
  my $Delimit;
  my @Atoms = ();
  
  if ($Mode eq "anysub" || $Mode eq "allsub") {
    my @Words = split /\s+/,$Words;
    foreach $Word (@Words) {
      $Word =~ tr/[A-Z]/[a-z]/;
      push @Atoms,"LOWER($Field) like \"%$Word%\"";
    }  
  }

  if      ($Mode eq "anysub") {
    $Join = " OR ";
  } elsif ($Mode eq "allsub") {
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
    while ($revtopic_list -> fetch) {
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
  
  foreach $AuthorID (@AuthorIDs) {
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

sub ValidateRevisions {
  require "RevisionSQL.pm";
  
  my (@RevisionIDs) = @_;
  my %DocumentIDs = ();
  my @DocumentIDs = ();
  
  foreach my $RevID (@RevisionIDs) {
    &FetchDocRevisionByID($RevID);
    unless ($DocRevisions{$RevID}{OBSOLETE}) {
      $DocumentIDs{$DocRevisions{$RevID}{DOCID}} = 1;
    }
  }
  @DocumentIDs = keys %DocumentIDs;
  return @DocumentIDs;
}

1;
