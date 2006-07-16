
# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License 
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

sub numerically {$a <=> $b;}

sub TopicByAlpha {
   $Topics{$a}{Short} cmp $Topics{$b}{Short};
} 

sub TopicByProvenance {
  my @ProvA = @{$TopicProvenance{$a}};
  my @ProvB = @{$TopicProvenance{$b}};
  
### Make sure we are comparing things at the same level, truncate arrays
   
  if ($#ProvA > $#ProvB) {
    $#ProvA = $#ProvB;
  } elsif ($#ProvB > $#ProvA) {
    $#ProvB = $#ProvA;
  }   

### Compare by "most distant" ancestor first
   
  while (@ProvA || @ProvB) {
    $TopicA = pop @ProvA;    
    $TopicB = pop @ProvB;    
    my $Cmp = $Topics{$TopicA}{Short} cmp $Topics{$TopicB}{Short};
    if ($Cmp) {return $Cmp;}
  }
  return 0;  
} 

sub byMajorTopic { #V8OBS
  $MajorTopics{$a}{SHORT} cmp $MajorTopics{$b}{SHORT};
}    

sub byMinorTopic { #V8OBS
  $MinorTopics{$a}{SHORT} cmp $MinorTopics{$b}{SHORT};
}    

sub byTopic { #V8OBS
  $MajorTopics{$MinorTopics{$a}{MAJOR}}{SHORT} cmp
  $MajorTopics{$MinorTopics{$b}{MAJOR}}{SHORT}
                 or
      $MinorTopics{$a}{SHORT} cmp
      $MinorTopics{$b}{SHORT};
}    

sub byLastName {
  require "AuthorSQL.pm";

  unless ($Authors{$a}{LastName}) {
    FetchAuthor($a);
  }    
  unless ($Authors{$b}{LastName}) {
    FetchAuthor($b);
  }    

  my $LastA  = $Authors{$a}{LastName};
  my $LastB  = $Authors{$b}{LastName};
  my $FirstA = $Authors{$a}{FirstName};
  my $FirstB = $Authors{$b}{FirstName};
  $LastA  =~ tr/[a-z]/[A-Z]/;
  $LastB  =~ tr/[a-z]/[A-Z]/;
  $FirstA =~ tr/[a-z]/[A-Z]/;
  $FirstB =~ tr/[a-z]/[A-Z]/;

   $LastA cmp $LastB
          or
  $FirstA cmp $FirstB;
}    

sub byInstitution {
  $Institutions{$a}{SHORT} cmp $Institutions{$b}{SHORT};
}    

sub DocumentByRevisionDate {

### All revisions and documents (of interest) must be fetched before calling
  
  my $adr = $DocRevIDs{$a}{$Documents{$a}{NVersions}};
  my $bdr = $DocRevIDs{$b}{$Documents{$b}{NVersions}};
  
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

  my $adr = $Documents{$a}{Requester};
  my $bdr = $Documents{$b}{Requester};
  &FetchAuthor($adr);
  &FetchAuthor($bdr);
    
   $Authors{$adr}{LastName} cmp $Authors{$bdr}{LastName}
                            or
  $Authors{$adr}{FirstName} cmp $Authors{$bdr}{FirstName}
}

sub DocumentByFirstAuthor {
  
  ### All documents (of interest) must be fetched before calling

  require "AuthorSQL.pm";

  my $adr = $DocRevIDs{$a}{$Documents{$a}{NVersions}};
  my $bdr = $DocRevIDs{$b}{$Documents{$b}{NVersions}};

  $adt = $DocRevisions{$adr}{DATE};
  $bdt = $DocRevisions{$bdr}{DATE};
  
  ($adate,$atime) = split /\s+/,$adt;
  ($bdate,$btime) = split /\s+/,$bdt;
  
  ($ayear,$amonth,$aday) = split /\-/,$adate;
  ($byear,$bmonth,$bday) = split /\-/,$bdate;
  
  ($ahour,$amin,$asec) = split /:/,$atime;
  ($bhour,$bmin,$bsec) = split /:/,$btime;
  
  unless ($DocFirstAuthor{$adr}{Have}) {
    $DocFirstAuthor{$adr}{Have} = 1;
    my $FirstID = FirstAuthorID( {-docrevid => $adr} );
    if ($FirstID) {
      FetchAuthor($FirstID);
      $DocFirstAuthor{$adr}{LastName}  = $Authors{$FirstID}{LastName};
      $DocFirstAuthor{$adr}{FirstName} = $Authors{$FirstID}{FirstName};
    }
  }
    
  unless ($DocFirstAuthor{$bdr}{Have}) {
    $DocFirstAuthor{$bdr}{Have} = 1;
    my $FirstID = FirstAuthorID( {-docrevid => $bdr} );
    if ($FirstID) {
      FetchAuthor($FirstID);
      $DocFirstAuthor{$bdr}{LastName}  = $Authors{$FirstID}{LastName};
      $DocFirstAuthor{$bdr}{FirstName} = $Authors{$FirstID}{FirstName};
    }
  }
  
   $DocFirstAuthor{$adr}{LastName} cmp $DocFirstAuthor{$bdr}{LastName}
                                   or
  $DocFirstAuthor{$adr}{FirstName} cmp $DocFirstAuthor{$bdr}{FirstName}
                                   or
                           $byear  <=>  $ayear 
                                   or         
                           $bmonth <=> $amonth 
                                   or         
                           $bday   <=>   $aday 
                                   or         
                           $bhour  <=>  $ahour 
                                   or         
                           $bmin   <=>   $amin 
                                   or         
                           $bsec   <=>   $asec ;            
}

sub DocumentByConferenceDate {
  require "MeetingSQL.pm";
  
  my $adr = $DocRevIDs{$a}{$Documents{$a}{NVersions}};
  my $bdr = $DocRevIDs{$b}{$Documents{$b}{NVersions}};
  
  unless ($LastConf{$adr}) {
    my $LastDate = "0";
    my @EventIDs = reverse GetRevisionEvents($adr);
    foreach my $ID (@EventIDs) {
      FetchConferenceByConferenceID($ID);
      if ($Conferences{$ID}{EndDate} gt $LastDate) {
        $LastDate = $Conferences{$ID}{EndDate};
        $LastConf{$adr} = $ID;
      }
    }
  }      

  unless ($LastConf{$bdr}) {
    my $LastDate = "0";
    my @EventIDs = reverse GetRevisionEvents($bdr);
    foreach my $ID (@EventIDs) {
      FetchConferenceByConferenceID($ID);
      if ($Conferences{$ID}{EndDate} gt $LastDate) {
        $LastDate = $Conferences{$ID}{EndDate};
        $LastConf{$bdr} = $ID;
      }
    }
  }      

  my $atid = $LastConf{$adr};
  my $btid = $LastConf{$bdr};

  my $adate = $Conferences{$atid}{EndDate}; 
  my $bdate = $Conferences{$btid}{EndDate};
  
  $adate cmp $bdate
}

sub DocumentByRelevance { # Documents to be sorted must be fetched before calling

  my $adr = $DocRevIDs{$a}{$Documents{$a}{NVersions}};
  my $bdr = $DocRevIDs{$b}{$Documents{$b}{NVersions}};

  my $adt = $DocRevisions{$adr}{DATE};
  my $bdt = $DocRevisions{$bdr}{DATE};
  
  my ($adate,$atime)        = split /\s+/,$adt;
  my ($bdate,$btime)        = split /\s+/,$bdt;
  
  my ($ayear,$amonth,$aday) = split /\-/,$adate;
  my ($byear,$bmonth,$bday) = split /\-/,$bdate;
  
  my ($ahour,$amin,$asec)   = split /:/,$atime;
  my ($bhour,$bmin,$bsec)   = split /:/,$btime;
   
   $Documents{$a}{Relevance} <=> $Documents{$b}{Relevance}
                             or
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

sub MeetingOrderIDByOrder { # Sort lists of Sessions, SessionSeparators 
  $MeetingOrders{$a}{SessionOrder} <=> $MeetingOrders{$b}{SessionOrder}
}

sub SessionOrderIDByOrder { # Sort lists of SessionTalks, TalkSeparators 
  $SessionOrders{$a}{TalkOrder} <=> $SessionOrders{$b}{TalkOrder}
}

sub byKeywordGroup {
  $KeywordGroups{$a}{Short} cmp $KeywordGroups{$b}{Short};
}    

sub byKeyword {
  $Keywords{$a}{Short} cmp $Keywords{$b}{Short};
}    

sub DocIDsByScore {
  $TalkMatches{$a}{Score} <=> $TalkMatches{$b}{Score};
}    

sub EmailUserIDsByName {
  my $an = $EmailUser{$a}{Name};
  my $bn = $EmailUser{$b}{Name};
  
  my @aparts = split /\s+/,$an;
  my @bparts = split /\s+/,$bn;
  my $alast  = "";
  my $afirst = "";
  my $blast  = "";
  my $bfirst = "";
 
  my $FoundWord = 0;
  while (!$FoundWord && @aparts) {
    my $Part = pop @aparts;

    if (grep /\D/,$Part) {
      $alast = $Part;
      $afirst = pop @aparts;
      $FoundWord = 1;
    }   
  }
  my $FoundWord = 0;
  while (!$FoundWord && @bparts) {
    my $Part = pop @bparts;

    if (grep /\D/,$Part) {
      $blast = $Part;
      $bfirst = pop @bparts;
      $FoundWord = 1;
    }   
  }
  
  $alast  =~ tr/[A-Z]/[a-z]/;
  $blast  =~ tr/[A-Z]/[a-z]/;
  $afirst =~ tr/[A-Z]/[a-z]/;
  $bfirst =~ tr/[A-Z]/[a-z]/;
  
   $alast cmp $blast 
          or
  $afirst cmp $bfirst;
}  

sub EventsByDate { # Do sort by date 
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

sub SessionsByDateTime {
  my $adt = $Sessions{$a}{StartTime}; 
  my $bdt = $Sessions{$b}{StartTime};

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


sub EventGroupsByName {
  $EventGroups{$a}{ShortDescription} cmp $EventGroups{$b}{ShortDescription};
}

sub FilesByDescription {
  $DocFiles{$a}{DESCRIPTION} cmp $DocFiles{$b}{DESCRIPTION}
                             or
         $DocFiles{$a}{NAME} cmp $DocFiles{$b}{NAME}
}                              

sub FieldsByColumn {
  $SortFields{$a}{Row}    <=> $SortFields{$b}{Row} 
                         or
  $SortFields{$a}{Column} <=> $SortFields{$b}{Column} 
}

1;
