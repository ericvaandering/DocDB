sub numerically {$a <=> $b;}

sub byMajorTopic {
  $MajorTopics{$a}{SHORT} cmp $MajorTopics{$b}{SHORT};
}    

sub byMinorTopic {
  $MinorTopics{$a}{SHORT} cmp $MinorTopics{$b}{SHORT};
}    

sub byMeetingDate {
  ($adays,$amonth,$ayear) = split /\s+/,$MinorTopics{$a}{SHORT};
  ($bdays,$bmonth,$byear) = split /\s+/,$MinorTopics{$b}{SHORT};
  ($aday) = split /\-/,$adays;
  ($bday) = split /\-/,$bdays;
  
                      $ayear <=> $byear
                             or
  $ReverseFullMonth{$amonth} <=> $ReverseFullMonth{$bmonth} 
                             or
                       $aday <=> $bday;            
}    

sub byTopic {

  # Do reverse sort by date for Collaboration meetings, otherwise alphabetical
  # FIXME use special topics numbering
  
  if (&MajorIsMeeting($MinorTopics{$a}{MAJOR}) &&
      &MajorIsMeeting($MinorTopics{$b}{MAJOR})) {
    my ($adays,$amonth,$ayear) = split /\s+/,$MinorTopics{$a}{SHORT};
    my ($bdays,$bmonth,$byear) = split /\s+/,$MinorTopics{$b}{SHORT};
    my ($aday) = split /\-/,$adays;
    my ($bday) = split /\-/,$bdays;

                        $byear <=> $ayear
                               or
    $ReverseFullMonth{$bmonth} <=> $ReverseFullMonth{$amonth} 
                               or
                         $bday <=> $aday;            
  } elsif (&MajorIsConference($MinorTopics{$a}{MAJOR}) &&
           &MajorIsConference($MinorTopics{$b}{MAJOR})) {
           
    my $adate = $Conferences{$a}{StartDate}; 
    my $bdate = $Conferences{$b}{StartDate};
    my ($ayear,$amonth,$aday) = split /\-/,$adate;
    my ($byear,$bmonth,$bday) = split /\-/,$bdate;

     $byear <=> $ayear
            or
    $bmonth <=> $amonth 
            or
      $bday <=> $aday
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

sub DocumentByConferenceDate {
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

  my $acid = $FirstConf{$adr};
  my $bcid = $FirstConf{$bdr};

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

sub ConferenceByDate {
  $MinorTopics{$a}{SHORT} cmp $MinorTopics{$b}{SHORT};
  my $adate = $Conferences{$a}{StartDate}; 
  my $bdate = $Conferences{$b}{StartDate};
  my ($ayear,$amonth,$aday) = split /\-/,$adate;
  my ($byear,$bmonth,$bday) = split /\-/,$bdate;

   $ayear <=> $byear
          or
  $amonth <=> $bmonth 
          or
    $aday <=> $bday

}

1;
