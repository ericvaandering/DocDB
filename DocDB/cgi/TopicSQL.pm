sub GetTopics {
  my $minor_list   = $dbh->prepare("select MinorTopicID,MajorTopicID,ShortDescription,LongDescription from MinorTopic");
  my $major_list   = $dbh->prepare("select MajorTopicID,ShortDescription,LongDescription from MajorTopic");

  %MinorTopics = ();
  %MajorTopics = ();
  %FullTopics  = ();

  $major_list -> execute;
  $major_list -> bind_columns(undef, \($MajorTopicID,$ShortDescription,$LongDescription));
  while ($major_list -> fetch) {
    $MajorTopics{$MajorTopicID}{MAJOR} = $MajorTopicID;
    $MajorTopics{$MajorTopicID}{SHORT} = $ShortDescription;
    $MajorTopics{$MajorTopicID}{LONG}  = $LongDescription;
  }

  my ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription);
  $minor_list -> execute;
  $minor_list -> bind_columns(undef, \($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription));
  while ($minor_list -> fetch) {
    $MinorTopics{$MinorTopicID}{MINOR} = $MinorTopicID;
    $MinorTopics{$MinorTopicID}{MAJOR} = $MajorTopicID;
    $MinorTopics{$MinorTopicID}{SHORT} = $ShortDescription;
    $MinorTopics{$MinorTopicID}{LONG}  = $LongDescription;
    $MinorTopics{$MinorTopicID}{FULL}  = $MajorTopics{$MajorTopicID}{SHORT}.":".$ShortDescription;
  }
  foreach $key (keys %MinorTopics) {
    $FullTopics{$key} =  $MinorTopics{$key}{FULL};
  }
};

sub FetchMinorTopic { # Fetches an MinorTopic by ID, adds to $Topics{$TopicID}{}
  my ($minorTopicID) = @_;
  my ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription);
  my $minor_fetch   = $dbh -> prepare(
    "select MinorTopicID,MajorTopicID,ShortDescription,LongDescription ".
    "from MinorTopic ".
    "where MinorTopicID=?");
  if ($MinorTopics{$minorTopicID}{MINOR}) { # We already have this one
    return $MinorTopics{$minorTopicID}{MINOR};
  }
  
  $minor_fetch -> execute($minorTopicID);
  ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription) = $minor_fetch -> fetchrow_array;
  &FetchMajorTopic($MajorTopicID);
  $MinorTopics{$MinorTopicID}{MINOR} = $MinorTopicID;
  $MinorTopics{$MinorTopicID}{MAJOR} = $MajorTopicID;
  $MinorTopics{$MinorTopicID}{SHORT} = $ShortDescription;
  $MinorTopics{$MinorTopicID}{LONG}  = $LongDescription;
  $MinorTopics{$MinorTopicID}{FULL}  = $MajorTopics{$MajorTopicID}{SHORT}.":".$ShortDescription;

  $FullTopics{$MinorTopicID} = $MinorTopics{$MinorTopicID}{FULL};

  return $MinorTopics{$MinorTopicID}{MINOR};
}

sub FetchMajorTopic { # Fetches an MajorTopic by ID, adds to $Topics{$TopicID}{}
  my ($majorTopicID) = @_;
  my ($MajorTopicID,$ShortDescription,$LongDescription);
  my $major_fetch   = $dbh -> prepare(
    "select MajorTopicID,ShortDescription,LongDescription ".
    "from MajorTopic ".
    "where MajorTopicID=?");
  if ($MajorTopics{$majorTopicID}{MAJOR}) { # We already have this one
    return $MajorTopics{$majorTopicID}{MAJOR};
  }

  $major_fetch -> execute($majorTopicID);
  ($MajorTopicID,$ShortDescription,$LongDescription) = $major_fetch -> fetchrow_array;
  $MajorTopics{$MajorTopicID}{MAJOR} = $MajorTopicID;
  $MajorTopics{$MajorTopicID}{SHORT} = $ShortDescription;
  $MajorTopics{$MajorTopicID}{LONG}  = $LongDescription;

  return $MajorTopics{$MajorTopicID}{MAJOR};
}

sub GetRevisionTopics {
  my ($DocRevID) = @_;
  
  require "Utilities.pm";
  
  my @topics = ();
  my ($RevTopicID,$MinorTopicID);
  my $topic_list = $dbh->prepare(
    "select RevTopicID,MinorTopicID from RevisionTopic where DocRevID=?");
  $topic_list -> execute($DocRevID);
  $topic_list -> bind_columns(undef, \($RevTopicID,$MinorTopicID));
  while ($topic_list -> fetch) {
    push @topics,$MinorTopicID;
  }
  @topics = &Unique(@topics);
  return @topics;
}

sub LookupMajorTopic { # Returns MajorTopicID from Topic Name
  my ($TopicName) = @_;
  my $major_fetch   = $dbh -> prepare(
    "select MajorTopicID from MajorTopic where ShortDescription=?");

  $major_fetch -> execute($TopicName);
  my $MajorTopicID = $major_fetch -> fetchrow_array;
  &FetchMajorTopic($MajorTopicID);
  
  return $MajorTopicID;
}

sub SpecialMajorTopics { # Store MajorTopicID for special topics
  unless ($SpecialMajorsFound) {
    $SpecialMajorsFound = 1;
    $ConferenceMajorID  = &LookupMajorTopic("Conferences");
    $CollabMeetMajorID  = &LookupMajorTopic("Collaboration Meetings");
    $OtherMeetMajorID   = &LookupMajorTopic("Other Meetings");
  }
}


1;
