sub numerically {$a <=> $b;}

sub byMajorTopic {
  $MajorTopics{$a}{SHORT} cmp $MajorTopics{$b}{SHORT};
}    

sub byMinorTopic {
  $MinorTopics{$a}{SHORT} cmp $MinorTopics{$b}{SHORT};
}    

sub byTopic {

  # Do reverse sort by date for meetings, otherwise alphabetical
  
  if ($MinorTopics{$a}{MAJOR} == $MinorTopics{$b}{MAJOR} &&
      &MajorIsGathering($MinorTopics{$a}{MAJOR}) &&
      &MajorIsGathering($MinorTopics{$b}{MAJOR}) ) {
    
    my $acid = $ConferenceMinor{$a};
    my $bcid = $ConferenceMinor{$b};
    my $adate = $Conferences{$acid}{StartDate}; 
    my $bdate = $Conferences{$bcid}{StartDate};
    my ($ayear,$amonth,$aday) = split /\-/,$adate;
    my ($byear,$bmonth,$bday) = split /\-/,$bdate;

                     $byear <=> $ayear
                            or
                    $bmonth <=> $amonth 
                            or
                      $bday <=> $aday
                            or 
    $MinorTopics{$a}{SHORT} cmp $MinorTopics{$b}{SHORT};
  } else {
    $MajorTopics{$MinorTopics{$a}{MAJOR}}{SHORT} cmp
    $MajorTopics{$MinorTopics{$b}{MAJOR}}{SHORT}
                   or
        $MinorTopics{$a}{SHORT} cmp
        $MinorTopics{$b}{SHORT};
  }
}    

sub byLastName {
   $Authors{$a}{LASTNAME} cmp $Authors{$b}{LASTNAME}
                          or
  $Authors{$a}{FIRSTNAME} cmp $Authors{$b}{FIRSTNAME};
}    

sub byInstitution {
  $Institutions{$a}{SHORT} cmp $Institutions{$b}{SHORT};
}    

sub DocumentByRevisionDate {

### All revisions and documents (of interest) must be fetched before calling
  
  my $adr = $DocRevIDs{$a}{$Documents{$a}{NVER}};
  my $bdr = $DocRevIDs{$b}{$Documents{$b}{NVER}};
  
  $adt = $DocRevisions{$adr}{DATE};
  $bdt = $DocRevisions{$bdr}{DATE};
  
  ($adate,$atime) = split /\s+/,$adt;
  ($bdate,$btime) = split /\s+/,$bdt;
  
  ($ayear,$amonth,$aday) = split /\-/,$adate;
  ($byear,$bmonth,$bday) = split /\-/,$bdate;
  
  ($ahour,$amin,$asec) = split /:/,$atime;
  ($bhour,$bmin,$bsec) = split /:/,$btime;
  
   $ayear <=> $byear
          or
  $amonth <=> $bmonth 
          or
    $aday <=> $bday
          or
   $ahour <=> $bhour
          or
    $amin <=> $bmin 
          or
    $asec <=> $bsec;            
}

sub RevisionByRevisionDate {

### All revisions and documents (of interest) must be fetched before calling
  
  my $adt = $DocRevisions{$a}{DATE};
  my $bdt = $DocRevisions{$b}{DATE};
  
  my ($adate,$atime) = split /\s+/,$adt;
  my ($bdate,$btime) = split /\s+/,$bdt;
  
  my ($ayear,$amonth,$aday) = split /\-/,$adate;
  my ($byear,$bmonth,$bday) = split /\-/,$bdate;
  
  my ($ahour,$amin,$asec) = split /:/,$atime;
  my ($bhour,$bmin,$bsec) = split /:/,$btime;
  
   $ayear <=> $byear
          or
  $amonth <=> $bmonth 
          or
    $aday <=> $bday
          or
   $ahour <=> $bhour
          or
    $amin <=> $bmin 
          or
    $asec <=> $bsec;            
}

sub RevisionByVersion {

### All revisions and documents (of interest) must be fetched before calling
  
  $DocRevisions{$a}{Version} <=> $DocRevisions{$b}{Version};
}

sub DocumentByRequester {

### All documents (of interest) must be fetched before calling

  require "AuthorSQL.pm";

  my $adr = $Documents{$a}{REQUESTER};
  my $bdr = $Documents{$b}{REQUESTER};
  &FetchAuthor($adr);
  &FetchAuthor($bdr);
    
   $Authors{$adr}{LASTNAME} cmp $Authors{$bdr}{LASTNAME}
                            or
  $Authors{$adr}{FIRSTNAME} cmp $Authors{$bdr}{FIRSTNAME}
}

sub DocumentByConferenceDate { # FIXME: Look at this and see if it can be 
                               # simplified after re-indexing conferences
  require "TopicSQL.pm";
  
  my $adr = $DocRevIDs{$a}{$Documents{$a}{NVER}};
  my $bdr = $DocRevIDs{$b}{$Documents{$b}{NVER}};
  
  unless ($FirstConf{$adr}) {
    my @topics = &GetRevisionTopics($adr);
    foreach my $ID (@topics) {
      if (&MajorIsConference($MinorTopics{$ID}{MAJOR})) {
        $FirstConf{$adr} = $ID;
        last;
      }
    }
  }      

  unless ($FirstConf{$bdr}) {
    my @topics = &GetRevisionTopics($bdr);
    foreach my $ID (@topics) {
      if (&MajorIsConference($MinorTopics{$ID}{MAJOR})) {
        $FirstConf{$bdr} = $ID;
        last;
      }
    }
  }      

  my $atid = $FirstConf{$adr};
  my $btid = $FirstConf{$bdr};
  my $acid = $ConferenceMinor{$atid};
  my $bcid = $ConferenceMinor{$btid};

  my $adate = $Conferences{$acid}{StartDate}; 
  my $bdate = $Conferences{$bcid}{StartDate};
  my ($ayear,$amonth,$aday) = split /\-/,$adate;
  my ($byear,$bmonth,$bday) = split /\-/,$bdate;

   $ayear <=> $byear
          or
  $amonth <=> $bmonth 
          or
    $aday <=> $bday
}

sub MeetingOrderIDByOrder { # Sort lists of Sessions, SessionSeparators 
  $MeetingOrders{$a}{SessionOrder} <=> $MeetingOrders{$b}{SessionOrder}
}

sub SessionOrderIDByOrder { # Sort lists of SessionTalks, TalkSeparators 
  $SessionOrders{$a}{TalkOrder} <=> $SessionOrders{$b}{TalkOrder}
}

1;
