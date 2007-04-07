#
#        Name: TalkHintSQL.pm 
# Description: Routines to access SQL tables related to hints for talks
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2007 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub InsertTopicHints ($@) {
  my ($SessionTalkID,@TopicHints) = @_;
  
  my $HintDelete = $dbh -> prepare("delete from TopicHint where SessionTalkID=?");   
  my $HintInsert = $dbh -> prepare("insert into TopicHint (TopicHintID, SessionTalkID, TopicID) values (0,?,?)");
 
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

sub FetchTopicHintsBySessionTalkID ($) {
  my ($SessionTalkID) = @_;

  my ($TopicHintID,$TopicID,$TimeStamp); 
  my $TopicHintList   = $dbh -> prepare(
    "select TopicHintID,TopicID,TimeStamp from TopicHint where SessionTalkID=?");
  my @TopicHintIDs = ();
  $TopicHintList -> execute($SessionTalkID);
  $TopicHintList -> bind_columns(undef, \($TopicHintID,$TopicID,$TimeStamp));

  while ($TopicHintList -> fetch) {
    $TopicHints{$TopicHintID}{SessionTalkID} = $SessionTalkID;
    $TopicHints{$TopicHintID}{TopicID}       = $TopicID;
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
