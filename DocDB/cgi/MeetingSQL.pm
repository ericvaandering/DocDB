#
#        Name: MiscSQL.pm 
# Description: Routines to access SQL tables related to conferences and meetings 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Have to re-do conferences, storing them by ConferenceID rather than topic ID. Probably 
# a translation hash between them and making one lookup a special case of the other 


sub GetConferences { # Probably redo this so it just gets all conferences, regardless
  %Conferences = ();
  my $MinorTopicID;
  foreach my $MajorID (@MeetingMajorIDs,@ConferenceMajorIDs) {
    my $MinorList   = $dbh -> prepare(
      "select MinorTopicID from MinorTopic where MajorTopicID=$MajorID");
    $MinorList -> execute();
    $MinorList -> bind_columns(undef, \($MinorTopicID));
    while ($MinorList -> fetch) {
      &FetchConferenceByTopicID($MinorTopicID);
    }
  }
}

sub FetchConferenceByTopicID { # Fetches a conference by MinorTopicID
  my ($minorTopicID) = @_;
  my ($ConferenceID,$MinorTopicID,$Location,$URL,$Title,$Preamble,$Epilogue,$StartDate,$EndDate,$TimeStamp);
  my $ConferenceFetch   = $dbh -> prepare(
    "select ConferenceID,MinorTopicID,Location,URL,Title,Preamble,Epilogue,StartDate,EndDate,TimeStamp ".
    "from Conference ".
    "where MinorTopicID=?");
  if ($Conference{$minorTopicID}{MINOR}) { # We already have this one
    return $Conference{$minorTopicID}{MINOR};
  }
  
  &FetchMinorTopic($minorTopicID);
  $ConferenceFetch -> execute($minorTopicID);
  ($ConferenceID,$MinorTopicID,$Location,$URL,$Title,$Preamble,$Epilogue,$StartDate,$EndDate,$TimeStamp) 
    = $ConferenceFetch -> fetchrow_array;
  $Conferences{$MinorTopicID}{MINOR}     = $MinorTopicID;
  $Conferences{$MinorTopicID}{Location}  = $Location;
  $Conferences{$MinorTopicID}{URL}       = $URL;
  $Conferences{$MinorTopicID}{Title}     = $Title;
  $Conferences{$MinorTopicID}{Preamble}  = $Preamble;
  $Conferences{$MinorTopicID}{Epilogue}  = $Epilogue;
  $Conferences{$MinorTopicID}{StartDate} = $StartDate;
  $Conferences{$MinorTopicID}{EndDate}   = $EndDate;
  $Conferences{$MinorTopicID}{TimeStamp} = $TimeStamp;

  return $Conferences{$MinorTopicID}{MINOR};
}



1;
