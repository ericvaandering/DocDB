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

  my $DocumentList = $dbh -> prepare("select DocumentID from DocumentRevision where DocRevID=? and Obsolete=0"); 

  # Find documents in a time window

  my $TimedList = $dbh -> prepare("select DocRevID from DocumentRevision where RevisionDate>=? and RevisionDate<=?"); 

  $TimedList -> execute($StartDate,$EndDate); # Between Start and End date
  $TimedList -> bind_columns(undef, \($DocRevID));
  while ($TimedList -> fetch) {
    $DocumentList -> execute($DocRevID);
    ($DocumentID) = $DocumentList -> fetchrow_array;
    $DocumentIDs{$DocumentID} = "Timed"; 
  }

  my $TimedList = $dbh -> prepare("select DocRevID from DocumentRevision where ABS(TO_DAYS(?)-TO_DAYS(RevisionDate))<=?"); 

  $TimedList -> execute($StartDate,$SearchDays); # Within $SearchDays days of start
  $TimedList -> bind_columns(undef, \($DocRevID));
  while ($TimedList -> fetch) {
    $DocumentList -> execute($DocRevID);
    ($DocumentID) = $DocumentList -> fetchrow_array;
    $DocumentIDs{$DocumentID} = "Timed"; 
  }

  $TimedList -> execute($EndDate,$SearchDays);   # Within $SearchDays days of end
  $TimedList -> bind_columns(undef, \($DocRevID));
  while ($TimedList -> fetch) {
    $DocumentList -> execute($DocRevID);
    ($DocumentID) = $DocumentList -> fetchrow_array;
    $DocumentIDs{$DocumentID} = "Timed"; 
  }

  if ($MinorTopicID) {
    my $RevisionList = $dbh -> prepare("select DocRevID from RevisionTopic where MinorTopicID=?"); 

    $RevisionList -> execute($MinorTopicID);
    $RevisionList -> bind_columns(undef, \($DocRevID));
    while ($RevisionList -> fetch) {
      $DocumentList -> execute($DocRevID);
      ($DocumentID) = $DocumentList -> fetchrow_array;
      $DocumentIDs{$DocumentID} = "Topic"; # Hash removes duplicates
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

  # Loop over all session talk IDs

  my %BestDocuments = ();
  foreach my $SessionTalkID (@SessionTalkIDs) { 
    &FetchSessionTalkByID($SessionTalkID);
    if ($SessionTalks{$SessionTalkID}{Confirmed}) {next;} # Skip if confirmed

    if ($SessionTalks{$SessionTalkID}{DocumentID}) { # Remove hints to confirmed documents
      my $DocumentID = $SessionTalks{$SessionTalkID}{DocumentID};
      foreach my $ConfirmedDocumentID (@ConfirmedDocumentIDs) {
        if ($DocumentID == $ConfirmedDocumentID) {
          my $BestDocUpdate = $dbh -> prepare("update SessionTalk set DocumentID=0 where SessionTalkID=?"); 
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
      
      my $DocumentID = $DocRevisions{$DocRevID}{DOCID};

      my $MethodScore = 0;
      if ($DocumentIDs{$DocumentID} eq "Timed") { # More points for being with right meeting topic than time window
        $MethodScore = 1;
      } elsif ($DocumentIDs{$DocumentID} eq "Topic") {
        $MethodScore = 2;
      } 

      my $Score = $MethodScore*($AuthorMatches+1)*(2*$TopicMatches+1);
      if ($Score > $BestDocuments{$SessionTalkID}{Score} && ($AuthorMatches+$TopicMatches)) {
        $BestDocuments{$SessionTalkID}{Score}      = $Score;
        $BestDocuments{$SessionTalkID}{DocumentID} = $DocumentID;
      }
    }  
  
    if ($BestDocuments{$SessionTalkID}{Score} > 1) {
      my $BestDocUpdate = $dbh -> prepare("update SessionTalk set DocumentID=? where SessionTalkID=?"); 
      my $DocumentID    = $BestDocuments{$SessionTalkID}{DocumentID};
      $BestDocUpdate -> execute($DocumentID,$SessionTalkID); # Update database
    }  
  }
}


1;
