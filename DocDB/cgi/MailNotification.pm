sub MailNotices ($) {
  require Mail::Send;
  require Mail::Mailer;

  require "RevisionSQL.pm";
  require "ResponseElements.pm";
  
  my ($DocRevID) = @_;
  
  &FetchDocRevisionByID($DocRevID);

# Figure out who cares 

  my @Addressees = &UsersToNotify($DocRevID,"immediate");

# If anyone, open the mailer

  if (@Addressees) {
    $Mailer = new Mail::Mailer 'smtp', Server => $MailServer;
#    $Mailer = new Mail::Mailer 'test', Server => $MailServer;
    my %Headers = ();

    my $FullID = &FullDocumentID($DocRevisions{$DocRevID}{DOCID},$DocRevisions{$DocRevID}{VERSION});
    my $Title  = $DocRevisions{$DocRevID}{TITLE};

    $Headers{To} = \@Addressees;
    $Headers{From} = "BTeV Document Database <$DBWebMasterEmail>";
    $Headers{Subject} = "$FullID: $Title";

    $Mailer -> open(\%Headers);    # Start mail with headers
    print $Mailer "The following document was added to the BTeV Document Database:\n\n";
    &RevisionMailBody($DocRevID);  # Write the body
    $Mailer -> close;              # Complete the message and send it
    my $Addressees = join ', ',@Addressees;
    $Addressees =~ s/\&/\&amp\;/g;
    $Addressees =~ s/</\&lt\;/g;
    $Addressees =~ s/>/\&gt\;/g;
    
    print "<b>E-mail sent to: </b>",$Addressees,"<p>";
  }  
}

sub RevisionMailBody ($) {
  require "RevisionSQL.pm";
  require "ResponseElements.pm";
  require "AuthorSQL.pm";
  require "Sorts.pm";

  my ($DocRevID) = @_;
  &FetchDocRevisionByID($DocRevID);
  
  my $Title  = $DocRevisions{$DocRevID}{TITLE};
  my $FullID = &FullDocumentID($DocRevisions{$DocRevID}{DOCID},$DocRevisions{$DocRevID}{VERSION});
  my $URL    = &DocumentURL($DocRevisions{$DocRevID}{DOCID});
  
  &FetchAuthor($DocRevisions{$DocRevID}{SUBMITTER});
  my $Submitter = $Authors{$DocRevisions{$DocRevID}{SUBMITTER}}{FULLNAME};

  my @AuthorIDs = &GetRevisionAuthors($DocRevID);
  my @TopicIDs  = &GetRevisionTopics($DocRevID);
  
  my @Authors = ();
  foreach $AuthorID (@AuthorIDs) {
    &FetchAuthor($AuthorID);
  }
  @AuthorIDs = sort byLastName @AuthorIDs;
  foreach $AuthorID (@AuthorIDs) {
    push @Authors,$Authors{$AuthorID}{FULLNAME};
  }
  my $Authors = join ', ',@Authors;
  
  my @Topics = ();
  foreach $TopicID (@TopicIDs) {
    &FetchAuthor($TopicID);
  }
  @TopicIDs = sort byTopic @TopicIDs;
  foreach $TopicID (@TopicIDs) {
    push @Topics,$MinorTopics{$TopicID}{FULL};
  }
  my $Topics = join ', ',@Topics;
  
  # Construct the mail body
  
  print $Mailer "       Title: ",$DocRevisions{$DocRevID}{TITLE},"\n";
  print $Mailer " Document ID: ",$FullID,"\n";
  print $Mailer "         URL: ",$URL,"\n";
  print $Mailer "        Date: ",$DocRevisions{$DocRevID}{DATE},"\n";;
  print $Mailer "Requested by: ",$Submitter,"\n";;
  print $Mailer "     Authors: ",$Authors,"\n";;
  print $Mailer "      Topics: ",$Topics,"\n";;
  print $Mailer "    Keywords: ",$DocRevisions{$DocRevID}{Keywords},"\n";;
  print $Mailer "    Abstract: ",$DocRevisions{$DocRevID}{ABSTRACT},"\n";;
}

sub UsersToNotify ($$) {
  my ($DocRevID,$Mode) = @_;

  &GetTopics;

  my $UserID;
  my %UserIDs = (); # Hash to make user IDs unique (one notification per person)
  my @Addressees = ();
  
  if ($Mode eq "immediate") {
    $Table = "EmailTopicImmediate";
  } elsif ($Mode eq "daily")  {
    $Table = "EmailTopicDaily";
  } elsif ($Mode eq "weekly")  {
    $Table = "EmailTopicWeekly";
  } else {   
    return;
  }    
  
  my $AllFetch   = $dbh -> prepare(
    "select EmailUserID from $Table where MinorTopicID=0 and MajorTopicID=0");
  my $MinorFetch   = $dbh -> prepare(
    "select EmailUserID from $Table where MinorTopicID=?");
  my $MajorFetch   = $dbh -> prepare(
    "select EmailUserID from $Table where MajorTopicID=?");

# Get users interested in all documents for this reporting period

  $AllFetch -> execute();
  $AllFetch -> bind_columns(undef,\($UserID));
  while ($AllFetch -> fetch) {
    $UserIDs{$UserID} = 1; 
  }

# Get users interested in major or minor topics for this reporting period

  my @MinorTopicIDs = &GetRevisionTopics($DocRevID);
  foreach my $MinorTopicID (@MinorTopicIDs) {
    $MinorFetch -> execute($MinorTopicID);
    $MinorFetch -> bind_columns(undef,\($UserID));
    while ($MinorFetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }

    my $MajorTopicID = $MinorTopics{$MinorTopicID}{MAJOR};
    $MajorFetch -> execute($MajorTopicID);
    $MajorFetch -> bind_columns(undef,\($UserID));
    while ($MajorFetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }
  }  

# Translate UserIDs into E-mail addresses
   
  foreach $UserID (keys %UserIDs) {
    my $EmailUserID = &FetchEmailUser($UserID);
    if ($EmailUserID) {
      my $Name         = $EmailUser{$UserID}{Name}        ; # FIXME: TRYME: Have to use UserID as index for some reason
      my $EmailAddress = $EmailUser{$UserID}{EmailAddress};
      if ($EmailAddress) {
        push @Addressees,$EmailAddress;
      }
    }
  } 
  
  return @Addressees;
}

sub FetchEmailUser($) {
  my ($eMailUserID) = @_;
  my ($EmailUserID,$Username,$Password,$Name,$EmailAddress,$PreferHTML);

  my $UserFetch   = $dbh -> prepare(
    "select EmailUserID,Username,Password,Name,EmailAddress,PreferHTML ".
    "from EmailUser where EmailUserID=?");
  
  if ($EmailUser{$eMailUserID}{EmailUserID}) {
    return $EmailUser{$eMailUserID}{EmailUserID};
  }  
  
  $UserFetch -> execute($eMailUserID);
  
  ($EmailUserID,$Username,$Password,$Name,$EmailAddress,$PreferHTML) = $UserFetch -> fetchrow_array;
  
  $EmailUser{$EmailUserID}{EmailUserID}  = $EmailUserID;
  $EmailUser{$EmailUserID}{Username}     = $Username;
  $EmailUser{$EmailUserID}{Password}     = $Password;
  $EmailUser{$EmailUserID}{Name}         = $Name;
  $EmailUser{$EmailUserID}{EmailAddress} = $EmailAddress;
  $EmailUser{$EmailUserID}{PreferHTML}   = $PreferHTML;
  
  return $EmailUser{$EmailUserID}{EmailUserID};
}

sub EmailPrefForm($$) {
  my ($EmailUserID,$Set) = @_;
  &FetchNotificationPrefs($EmailUserID,$Set);
  &NotifyTopicSelect($Set);
}

sub NotifyTopicSelect ($) { # Check for all, boxes for major and minor topics
  my ($Set) = @_;

  print "<td valign=top>\n";
  print "<b><a ";
  &HelpLink("notifytopic");
  print "$Set:</a></b><p>\n";
  if ($NotifyAllTopics) {
    print $query -> checkbox(-name => "all$Set", -checked => 'checked', -value => 1, -label => '');
  } else {
    print $query -> checkbox(-name => "all$Set", -value => 1, -label => '');
  }                             
  print "<b> All Topics</b> ";

  print "<td>\n";
  my @MajorIDs = sort byMajorTopic keys %MajorTopics;
  my %MajorLabels = ();
  foreach my $ID (@MajorIDs) {
    $MajorLabels{$ID} = $MajorTopics{$ID}{SHORT};
  }  
  print $query -> scrolling_list(-name => "majortopic$Set", -values => \@MajorIDs, 
                                 -labels => \%MajorLabels,  
                                 -size => 10, -default => \@NotifyMajorIDs,
                                 -multiple => 'true');
  print "</td>\n";
  
  print "<td colspan=2>\n";
  my @MinorIDs = sort byTopic keys %MinorTopics;
  my %MinorLabels = ();
  foreach my $ID (@MinorIDs) {
    $MinorLabels{$ID} = $MinorTopics{$ID}{FULL};
  }  
  
  print $query -> scrolling_list(-name => "minortopic$Set", -values => \@MinorIDs, 
                                 -labels => \%MinorLabels,  
                                 -size => 10, -default => \@NotifyMinorIDs,
                                 -multiple => 'true');
  print "</td>\n";
}

sub FetchNotificationPrefs ($$) {
  my ($EmailUserID,$Set) = @_;

  my $MajorTopicID,$MinorTopicID;

  $Table = "EmailTopic$Set";
  @NotifyMajorIDs = ();
  @NotifyMinorIDs = ();
  $NotifyAllTopics = 0;
  
  my $UserFetch   = $dbh -> prepare("select MajorTopicID,MinorTopicID from $Table where EmailUserID=?");

# Get users interested in all documents for this reporting period

  $UserFetch -> execute($EmailUserID);
  $UserFetch -> bind_columns(undef,\($MajorTopicID,$MinorTopicID));
  while ($UserFetch -> fetch) {
    if ($MajorTopicID) {
      push @NotifyMajorIDs,$MajorTopicID;
    } elsif ($MinorTopicID) { 
      push @NotifyMinorIDs,$MinorTopicID;
    } else { 
      $NotifyAllTopics = 1;
    }  
  }
}

sub SetEmailNotifications ($$) {
  my ($EmailUserID,$Set) = @_;

  my $Table = "EmailTopic$Set";  # Tables    for immediate, daily, weekly 
  my $Field = $Set."EmailID";    # ID fields for immediate, daily, weekly  
  
# Delete all old notifications  
  
  my $Delete = $dbh -> prepare("delete from $Table where EmailUserID=?");
  $Delete -> execute($EmailUserID);

# Get parameters from input

  my $AllTopics = $params{"all$Set"};
  my @MinorIDs  = split /\0/,$params{"minortopic$Set"};
  my @MajorIDs  = split /\0/,$params{"majortopic$Set"};

# Insert in relevant table

  if ($AllTopics) {
    my $AllInsert = $dbh -> prepare(
      "insert into $Table ($Field,EmailUserID,MinorTopicID,MajorTopicID) ".
      "            values (0,     ?,          0,           0)");
    $AllInsert -> execute($EmailUserID); 
  }
  foreach my $MinorID (@MinorIDs) {
    my $MinorInsert = $dbh -> prepare(
      "insert into $Table ($Field,EmailUserID,MinorTopicID) ".
      "            values (0,     ?,          ?)");
    $MinorInsert -> execute($EmailUserID,$MinorID); 
  }   
  foreach my $MajorID (@MajorIDs) {
    my $MajorInsert = $dbh -> prepare(
      "insert into $Table ($Field,EmailUserID,MajorTopicID) ".
      "            values (0,     ?,          ?)");
    $MajorInsert -> execute($EmailUserID,$MajorID); 
  }   
}
  
1;
