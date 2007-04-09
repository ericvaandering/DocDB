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

sub ClearEmailUsers () {
  %EmailUser         = ();
  $HaveAllEmailUsers = $FALSE;
  return;
}

sub GetEmailUserIDs () {
  my $EmailUserID;
  my @EmailUserIDs;

  my $EmailIDQuery = $dbh -> prepare("select DISTINCT(EmailUserID) from EmailUser");
  $EmailIDQuery -> execute();
  $EmailIDQuery -> bind_columns(undef,\($EmailUserID));
  while ($EmailIDQuery -> fetch) {
    FetchEmailUser($EmailUserID);
    push @EmailUserIDs,$EmailUserID;
  }
  return @EmailUserIDs;
}

sub FetchEmailUser ($) {
  my ($eMailUserID) = @_;
  my ($EmailUserID,$Username,$Password,$Name,$EmailAddress,$PreferHTML,$CanSign,$Verified,$AuthorID);

  my $UserFetch   = $dbh -> prepare(
    "select EmailUserID,Username,Password,Name,EmailAddress,PreferHTML,CanSign,Verified,AuthorID ".
    "from EmailUser where EmailUserID=?");

  if ($EmailUser{$eMailUserID}{EmailUserID}) {
    return $EmailUser{$eMailUserID}{EmailUserID};
  }

  $UserFetch -> execute($eMailUserID);

  ($EmailUserID,$Username,$Password,$Name,$EmailAddress,$PreferHTML,$CanSign,$Verified,$AuthorID) = $UserFetch -> fetchrow_array;

  if ($Verified != 1) { # Have some weird ones out there
    $Verified = 0;
  }

  $EmailUser{$EmailUserID}{EmailUserID}  = $EmailUserID;
  $EmailUser{$EmailUserID}{Username}     = $Username;
  $EmailUser{$EmailUserID}{Password}     = $Password;
  $EmailUser{$EmailUserID}{Name}         = $Name; # Construct from first/last
  $EmailUser{$EmailUserID}{EmailAddress} = $EmailAddress;
  $EmailUser{$EmailUserID}{PreferHTML}   = $PreferHTML;
  $EmailUser{$EmailUserID}{CanSign}      = $CanSign;
  $EmailUser{$EmailUserID}{Verified}     = $Verified;
  $EmailUser{$EmailUserID}{AuthorID}     = $AuthorID;

  return $EmailUser{$EmailUserID}{EmailUserID};
}

sub ClearNotifications {
  $HaveAllNotifications = 0;
  %Notifications        = ();
}

sub DeleteNotifications ($) {
  my ($ArgRef) = @_;
  my $EmailUserID = exists $ArgRef->{-emailuserid} ? $ArgRef->{-emailuserid} : 0;

  if ($EmailUserID) { # FIXME: Don't do document specific?
    my $Delete = $dbh -> prepare("delete from Notification where EmailUserID=?");
    $Delete -> execute($EmailUserID);
  }

  return 0;
}

sub InsertNotifications ($) {
  my ($ArgRef) = @_;
  my $EmailUserID = exists $ArgRef->{-emailuserid} ?   $ArgRef->{-emailuserid} : 0;
  my $Period      = exists $ArgRef->{-period}      ?   $ArgRef->{-period}      : 0;
  my $Type        = exists $ArgRef->{-type}        ?   $ArgRef->{-type}        : 0;
  my @IDs         = exists $ArgRef->{-ids}         ? @{$ArgRef->{-ids}}        : ();
  my @TextKeys    = exists $ArgRef->{-textkeys}    ? @{$ArgRef->{-textkeys}}   : ();

  # FIXME: Need way to insert AllDocuments

  my $Count = 0;
  if ($EmailUserID && $Period && $Type && (@IDs || @TextKeys)) {
    my $Insert = $dbh -> prepare(
       "insert into Notification ".
       "(NotificationID,EmailUserID,Type,ForeignID,Period) values ".
       "(0,?,?,?,?)");
    my $TextInsert = $dbh -> prepare(
       "insert into Notification ".
       "(NotificationID,EmailUserID,Type,TextKey,Period) values ".
       "(0,?,?,?,?)");
    foreach my $ID (@IDs) {
      $Insert -> execute($EmailUserID,$Type,$ID,$Period);
      ++$Count;
    }
    foreach my $TextKey (@TextKeys) {
      $TextInsert -> execute($EmailUserID,$Type,$TextKey,$Period);
      ++$Count;
    }
  }
  return $Count;
}

sub FetchNotifications ($) {
  my ($ArgRef) = @_;
  my $EmailUserID = exists $ArgRef->{-emailuserid} ? $ArgRef->{-emailuserid} : 0;

  my $Count = 0;

  if ($EmailUserID) {
    %{$Notifications{$EmailUserID}} = (); # Erase notifications for user, not all users

    my ($Type,$ForeignID,$Period,$TextKey);
    my $Fetch = $dbh -> prepare("select Type,ForeignID,Period,TextKey from Notification where EmailUserID=?");
    $Fetch -> execute($EmailUserID);
    $Fetch -> bind_columns(undef,\($Type,$ForeignID,$Period,$TextKey));

    while ($Fetch -> fetch) {
      my $Key = $Type."_".$Period;
      if ($TextKey) {
        push @{$Notifications{$EmailUserID}{$Key}},$TextKey;
      } elsif ($ForeignID) {
        push @{$Notifications{$EmailUserID}{$Key}},$ForeignID;
      }
      ++$Count;
    }
  }

  return $Count;
}

sub InsertEmailDocumentImmediate (%) {
  my %Params = @_;

  my $EmailUserID = $Params{-emailuserid};
  my $DocumentID  = $Params{-docid};

  InsertNotifications({ -emailuserid => $EmailUserID, -period => "Immediate",
                        -type        => "Document", -ids => [$DocumentID] });
}


1;
