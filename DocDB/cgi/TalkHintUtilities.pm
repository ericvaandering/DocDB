sub ReHintTalksBySessionID ($) {
  my ($SessionID) = @_;

  require "MeetingSQL.pm";
  require "TalkSQL.pm";
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  require "TopicSQL.pm";
  require "AuthorSQL.pm";
  require "TalkHintSQL.pm";
  require "Utilities.pm";
  
  if ($Public) { # Can't write to DB
    return;
  }  

  my $DocRevID,$DocumentID;
  my %DocumentIDs = (); 
  my $SearchDays  = 5;

  &FetchSessionByID($SessionID);
  my @SessionTalkIDs   = &FetchSessionTalksBySessionID($SessionID);
  my $ConferenceID     = $Sessions{$SessionID}{ConferenceID};

  &FetchConferenceByConferenceID($ConferenceID);
  my $StartDate    = $Conferences{$ConferenceID}{StartDate};
  my $EndDate      = $Conferences{$ConferenceID}{EndDate};
  my $MinorTopicID = $Conferences{$ConferenceID}{Minor};

  if ($MinorTopicID) { 
    $TalkMatchThreshold = $TopicMatchThreshold;
  } else {     
    $TalkMatchThreshold = $NoTopicMatchThreshold 
  }	

  my $DocumentList = $dbh -> prepare("select DocumentID from DocumentRevision where DocRevID=? and Obsolete=0"); 

  # Find documents in a time window

  my $TimedList = $dbh -> prepare("select DocRevID from DocumentRevision where RevisionDate>=? and RevisionDate<=?"); 

  $TimedList -> execute($StartDate,$EndDate); # Between Start and End date
  $TimedList -> bind_columns(undef, \($DocRevID));
  while ($TimedList -> fetch) {
    $DocumentList -> execute($DocRevID);
    ($DocumentID) = $DocumentList -> fetchrow_array;
    if ($DocumentID) {
      $DocumentIDs{$DocumentID} = "Timed";
    }   
  }

  my $TimedList = $dbh -> prepare("select DocRevID from DocumentRevision where ABS(TO_DAYS(?)-TO_DAYS(RevisionDate))<=?"); 

  $TimedList -> execute($StartDate,$SearchDays); # Within $SearchDays days of start
  $TimedList -> bind_columns(undef, \($DocRevID));
  while ($TimedList -> fetch) {
    $DocumentList -> execute($DocRevID);
    ($DocumentID) = $DocumentList -> fetchrow_array;
    if ($DocumentID) {
      $DocumentIDs{$DocumentID} = "Timed"; 
    }   
  }

  $TimedList -> execute($EndDate,$SearchDays);   # Within $SearchDays days of end
  $TimedList -> bind_columns(undef, \($DocRevID));
  while ($TimedList -> fetch) {
    $DocumentList -> execute($DocRevID);
    ($DocumentID) = $DocumentList -> fetchrow_array;
    if ($DocumentID) {
      $DocumentIDs{$DocumentID} = "Timed"; 
    }   
  }

  if ($MinorTopicID) {
    my $RevisionList = $dbh -> prepare("select DocRevID from RevisionTopic where MinorTopicID=?"); 

    $RevisionList -> execute($MinorTopicID);
    $RevisionList -> bind_columns(undef, \($DocRevID));
    while ($RevisionList -> fetch) {
      $DocumentList -> execute($DocRevID);
      ($DocumentID) = $DocumentList -> fetchrow_array;
      if ($DocumentID) {
        $DocumentIDs{$DocumentID} = "Topic"; # Hash removes duplicates
      }
    }
  }

  # Get unique document IDs

  my @DocumentIDs = sort keys %DocumentIDs;

  # Remove documents already confirmed with a conference
  
  my $ConfirmedList = $dbh -> prepare("select DocumentID from SessionTalk where Confirmed=1"); 
  my %ConfirmedDocumentIDs = ();
  $ConfirmedList -> execute();
  $ConfirmedList -> bind_columns(undef, \($DocumentID));
  while ($ConfirmedList -> fetch) {
    $ConfirmedDocumentIDs{$DocumentID} = 1;
  }
  my @ConfirmedDocumentIDs = sort keys %ConfirmedDocumentIDs;
  
  @DocumentIDs = sort &RemoveArray(\@DocumentIDs,@ConfirmedDocumentIDs);
  
  # Convert to revisions (latest versions only)

  my @DocRevIDs   = ();
  foreach my $DocumentID (@DocumentIDs) { # For shorter lists
    &FetchDocument($DocumentID);
    my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Documents{$DocumentID}{NVersions});
    push @DocRevIDs,$DocRevID;
  }

  my $dbh_w = DBI->connect('DBI:mysql:'.$db_name.':'.$db_host,$db_rwuser,$db_rwpass);

  # Loop over all session talk IDs

  my %BestDocuments = ();
  foreach my $SessionTalkID (@SessionTalkIDs) { 
    &FetchSessionTalkByID($SessionTalkID);
    if ($SessionTalks{$SessionTalkID}{Confirmed}) {next;} # Skip if confirmed
    my $HintTitle = $SessionTalks{$SessionTalkID}{HintTitle};

    if ($SessionTalks{$SessionTalkID}{DocumentID}) { # Remove hints to confirmed documents
      my $DocumentID = $SessionTalks{$SessionTalkID}{DocumentID};
      foreach my $ConfirmedDocumentID (@ConfirmedDocumentIDs) {
        if ($DocumentID == $ConfirmedDocumentID) {
          my $BestDocUpdate = $dbh_w -> prepare("update SessionTalk set DocumentID=0 where SessionTalkID=?"); 
          $BestDocUpdate -> execute($SessionTalkID); # Remove hinted DocumentID
          last;  
        }
      }
    }
          
    my @TopicHintIDs  = &FetchTopicHintsBySessionTalkID($SessionTalkID);
    my @AuthorHintIDs = &FetchAuthorHintsBySessionTalkID($SessionTalkID); 
    
    foreach my $DocRevID (@DocRevIDs) { # Check each document in the list
      my @RevTopics  = &GetRevisionTopics($DocRevID);
      my @RevAuthors = &GetRevisionAuthors($DocRevID);
      
      # Accumulate matches # FIXME: Look at soundex and fuzzy matching, cookbook 1.16 and 6.13
      
      my $TopicMatches = 0;
      foreach my $RevTopic (@RevTopics) {
        foreach my $TopicHintID (@TopicHintIDs) {
          my $HintTopic = $TopicHints{$TopicHintID}{MinorTopicID};
          if ($HintTopic == $RevTopic) {
            ++$TopicMatches;
          }   
        }
      }
       
      my $AuthorMatches = 0;
      foreach my $RevAuthor (@RevAuthors) {
        foreach my $AuthorHintID (@AuthorHintIDs) {
          my $HintAuthor = $AuthorHints{$AuthorHintID}{AuthorID};
          if ($HintAuthor == $RevAuthor) {
            ++$AuthorMatches;
          }   
        }
      }

      # Assemble a score based on hints, track maximum
      
      my $DocumentID    = $DocRevisions{$DocRevID}{DOCID};
      my $DocumentTitle = $DocRevisions{$DocRevID}{Title};

      my $MethodScore = 0;
      if ($DocumentIDs{$DocumentID} eq "Timed") { # More points for being with right meeting topic than time window
        $MethodScore = 1;
      } elsif ($DocumentIDs{$DocumentID} eq "Topic") {
        $MethodScore = 3;
      } 
      
      my $FuzzyScore1 = &FuzzyStringMatch($DocumentTitle,$HintTitle);
      my $FuzzyScore2 = &FuzzyStringMatch($HintTitle,$DocumentTitle);
      my $FuzzyScore;
      
      if ($FuzzyScore1 > $FuzzyScore2) { # Can be different since "test" matches "testbeam," not vvs.
        $FuzzyScore = $FuzzyScore1;
      } else {	 
        $FuzzyScore = $FuzzyScore2;
      }
            
      my $Score = $MethodScore*($AuthorMatches+1)*(2*$TopicMatches+1)+(2*$FuzzyScore+1);
      if ($Score > $BestDocuments{$SessionTalkID}{Score} && ($AuthorMatches+$TopicMatches)) {
        $BestDocuments{$SessionTalkID}{Score}      = $Score;
        $BestDocuments{$SessionTalkID}{DocumentID} = $DocumentID;
      }
    }  
  
    if ($BestDocuments{$SessionTalkID}{Score} > $TalkMatchThreshold) {
      my $BestDocUpdate = $dbh_w -> prepare("update SessionTalk set DocumentID=? where SessionTalkID=?"); 
      my $DocumentID    = $BestDocuments{$SessionTalkID}{DocumentID};
      $BestDocUpdate -> execute($DocumentID,$SessionTalkID); # Update database
    } else {
      my $BestDocUpdate = $dbh_w -> prepare("update SessionTalk set DocumentID=? where SessionTalkID=?"); 
      $BestDocUpdate -> execute(0,$SessionTalkID); # Update database
    }   
  }
}

sub FuzzyStringMatch ($$) {
#  use String::Approx qw(amatch);
  
  # FIXME: Look at soundex and fuzzy matching, cookbook 1.16 and 6.13
  
  my ($String1,$String2) = @_;
  
  $String1 =~ tr/[A-Z]/[a-z]/;
  $String2 =~ tr/[A-Z]/[a-z]/;
  
  my @Words1 = split /\s+/,$String1;
  my @Words2 = split /\s+/,$String2;
  
  @Words1 = &RemoveArray(\@Words1,@MatchIgnoreWords); 
  @Words2 = &RemoveArray(\@Words2,@MatchIgnoreWords); 
  
  my $Matches = 0;
  foreach my $Word (@Words1) {
    $Word =~ s/\W//;
    my $WordLength = length $Word;
    if ($WordLength < 4) {next;}
    if (grep /$Word/,@Words2) {
      if ($WordLength > 6) { # More points for matching longer words
        $Matches += $WordLength/6;
      } else {
        ++$Matches;
      }		
    }  
  }
  
  my $NWords1 = @Words1;
  my $NWords2 = @Words2;
  
  # Use NWords to calculate a "fraction" of matches, restrict to 3 - 10
  
  $NWords = 3;
  
  if ($NWords1 > $NWords) {$NWords = $NWords1;}
  if ($NWords2 > $NWords) {$NWords = $NWords2;}
  if ($NWords > 10)       {$NWords = 10;}
 
  my $MatchScore = 0;
  if ($Matches >= 1.1) {
    $MatchScore = $Matches/$NWords * 10;
  }
  return $MatchScore;  
}

1;
