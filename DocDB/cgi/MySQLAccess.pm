sub GetAuthors {
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName);
  my $people_list  = $dbh->prepare("select AuthorID,FirstName,MiddleInitials,LastName,Active from Author order by LastName");
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active));
  while ($people_list -> fetch) {
    if ($Active) {
      $names{$AuthorID} = "$FirstName $MiddleInitials $LastName";
    }
  }
};

sub GetTopics {
  my $minor_list   = $dbh->prepare("select MinorTopicID,MajorTopicID,ShortDescription,LongDescription from MinorTopic");
  my $major_list   = $dbh->prepare("select MajorTopicID,ShortDescription,LongDescription from MajorTopic");
  $major_list -> execute;
  $major_list -> bind_columns(undef, \($MajorTopicID,$ShortDescription,$LongDescription));
  while ($major_list -> fetch) {
    $major_topics{$MajorTopicID}{SHORT} = $ShortDescription;
    $major_topics{$MajorTopicID}{LONG}  = $LongDescription;
  }

  my ($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription);
  $minor_list -> execute;
  $minor_list -> bind_columns(undef, \($MinorTopicID,$MajorTopicID,$ShortDescription,$LongDescription));
  while ($minor_list -> fetch) {
    $minor_topics{$MinorTopicID}{MAJOR} = $MajorTopicID;
    $minor_topics{$MinorTopicID}{SHORT} = $ShortDescription;
    $minor_topics{$MinorTopicID}{LONG}  = $LongDescription;
    $minor_topics{$MinorTopicID}{FULL}  = $major_topics{$MajorTopicID}{SHORT}.":".$ShortDescription;
  }
  foreach $key (keys %minor_topics) {
    $full_topics{$key} =  $minor_topics{$key}{FULL};
  }
};

sub GetSecurities {
  my ($field,$type);
  my $security_list = $dbh->prepare("describe DocumentRevision Security");
  $security_list -> execute;
  $security_list -> bind_columns(undef, \($field,$type,$Null,$Key,$Default,$Extra));
  $security_list -> fetch;
  my $set_values = $type;

  $set_values =~ s/set\(//g; # Parse out everything but the types
  $set_values =~ s/\)//g;
  $set_values =~ s/\'//g;
  $set_values =~ s/\s+//g;
  (@available_securities) = split /\,/,$set_values;
};

1;
