#
#        Name: TalkHintSQL.pm 
# Description: Routines to access SQL tables related to hints for talks
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

sub InsertTopicHints ($@) {
  my ($SessionTalkID,@TopicHints) = @_;
  
  my $HintDelete = $dbh -> prepare("delete from TopicHint where SessionTalkID=?");   
  my $HintInsert = $dbh -> prepare("insert into TopicHint (TopicHintID, SessionTalkID, MinorTopicID) values (0,?,?)");
 
  $HintDelete -> execute($SessionTalkID);
  foreach my $TopicHint (@TopicHints) {
    $HintInsert -> execute($SessionTalkID,$TopicHint);
  }
}

sub InsertAuthorHints ($@) {
  my ($SessionTalkID,@AuthorHints) = @_;
  
  my $HintDelete = $dbh -> prepare("delete from AuthorHint where SessionTalkID=?");   
  my $HintInsert = $dbh -> prepare("insert into AuthorHint (AuthorHintID, SessionTalkID, AuthorID) values (0,?,?)");
 
  $HintDelete -> execute($SessionTalkID);
  foreach my $AuthorHint (@AuthorHints) {
    $HintInsert -> execute($SessionTalkID,$AuthorHint);
  }
}

sub DeleteHints ($) {
  my ($SessionTalkID) = @_;

  my $AuthorDelete = $dbh -> prepare("delete from TopicHint  where SessionTalkID=?");   
  my $TopicDelete  = $dbh -> prepare("delete from AuthorHint where SessionTalkID=?");   
  $AuthorDelete -> execute($SessionTalkID);
  $TopicDelete  -> execute($SessionTalkID);
}

sub FetchHintsBySessionTalkID ($) {
  my ($SessionTalkID) = @_;
  &FetchTopicHintsBySessionTalkID($SessionTalkID);
  &FetchAuthorHintsBySessionTalkID($SessionTalkID);
}

sub FetchTopicHintsBySessionTalkID ($) {
  my ($SessionTalkID) = @_;

  my ($TopicHintID,$MinorTopicID,$TimeStamp); 
  my $TopicHintList   = $dbh -> prepare(
    "select TopicHintID,MinorTopicID,TimeStamp from TopicHint where SessionTalkID=?");
  my @TopicHintIDs = ();
  $TopicHintList -> execute($SessionTalkID);
  $TopicHintList -> bind_columns(undef, \($TopicHintID,$MinorTopicID,$TimeStamp));

  while ($TopicHintList -> fetch) {
    $TopicHints{$TopicHintID}{SessionTalkID} = $SessionTalkID;
    $TopicHints{$TopicHintID}{MinorTopicID}  = $MinorTopicID;
    $TopicHints{$TopicHintID}{TimeStamp}     = $TimeStamp;
    push @TopicHintIDs,$TopicHintID;
  }
  return @TopicHintIDs; 
}

sub FetchAuthorHintsBySessionTalkID ($) {
  my ($SessionTalkID) = @_;

  my ($AuthorHintID,$AuthorID,$TimeStamp); 
  my $AuthorHintList   = $dbh -> prepare(
    "select AuthorHintID,AuthorID,TimeStamp from AuthorHint where SessionTalkID=?");
  my @AuthorHintIDs = ();
  $AuthorHintList -> execute($SessionTalkID);
  $AuthorHintList -> bind_columns(undef, \($AuthorHintID,$AuthorID,$TimeStamp));

  while ($AuthorHintList -> fetch) {
    $AuthorHints{$AuthorHintID}{SessionTalkID} = $SessionTalkID;
    $AuthorHints{$AuthorHintID}{AuthorID}      = $AuthorID;
    $AuthorHints{$AuthorHintID}{TimeStamp}     = $TimeStamp;
    push @AuthorHintIDs,$AuthorHintID;
  }
  return @AuthorHintIDs;
}

1;
