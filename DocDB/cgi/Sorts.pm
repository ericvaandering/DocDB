
# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

sub numerically {$a <=> $b;}

sub byMajorTopic {
  $MajorTopics{$a}{SHORT} cmp $MajorTopics{$b}{SHORT};
}    

sub byMinorTopic {
  $MinorTopics{$a}{SHORT} cmp $MinorTopics{$b}{SHORT};
}    

sub byTopic {
  $MajorTopics{$MinorTopics{$a}{MAJOR}}{SHORT} cmp
  $MajorTopics{$MinorTopics{$b}{MAJOR}}{SHORT}
                 or
      $MinorTopics{$a}{SHORT} cmp
      $MinorTopics{$b}{SHORT};
}    

sub byLastName {
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

sub DocumentByConferenceDate { # FIXME: Look at this and see if it can be 
                               # simplified after re-indexing conferences
  require "TopicSQL.pm";
  
  my $adr = $DocRevIDs{$a}{$Documents{$a}{NVersions}};
  my $bdr = $DocRevIDs{$b}{$Documents{$b}{NVersions}};
  
  unless ($FirstConf{$adr}) {
    my @topics = &GetRevisionTopics($adr);
    foreach my $ID (@topics) {
#      if (&MajorIsConference($MinorTopics{$ID}{MAJOR})) {
#        $FirstConf{$adr} = $ID;
#        last;
#      }
    }
  }      

  unless ($FirstConf{$bdr}) {
    my @topics = &GetRevisionTopics($bdr);
    foreach my $ID (@topics) {
#      if (&MajorIsConference($MinorTopics{$ID}{MAJOR})) {
#        $FirstConf{$bdr} = $ID;
#        last;
#      }
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

sub EventsByDate {

  # Do reverse sort by date 
  
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

1;
