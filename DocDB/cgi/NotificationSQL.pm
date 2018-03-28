#        Name: NotificationSQL.pm
# Description: SQL for document notifications
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2018 Eric Vaandering, Lynn Garren, Adam Bryant

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

require "SecuritySQL.pm";
require "DBUtilities.pm";

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

sub TransferEmailUserSettings {

  # Copy group membership and transfer notification and signoffs from one account to another

  my ($ArgRef) = @_;
  my $EmailUserID = exists $ArgRef->{-oldemailuserid} ? $ArgRef->{-oldemailuserid} : 0;
  my $NewCertID = exists $ArgRef->{-newemailuserid} ? $ArgRef->{-newemailuserid} : 0;

  push @DebugStack, "Transferring settings from EmailUserID $EmailUserID to $NewCertID";
  unless ($EmailUser{$EmailUserID}{Verified}) {
    push @DebugStack, "Cowardly refusing to transfer settings from an unverified user.";
    return;
  }

  push @DebugStack, "Checking for transfer from ID $EmailUserID to $NewCertID";
  if ($NewCertID && $EmailUserID && $NewCertID != $EmailUserID) {
    FetchEmailUser($EmailUserID);
    FetchEmailUser($NewCertID);
    CreateConnection(-type => "rw");   # Can't rely on connection setup by top script, may be read-only

    if ($EmailUser{$EmailUserID}{Name} && !$EmailUser{$NewCertID}{Name}) {
      my $UserUpdate = $dbh_rw->prepare("update EmailUser set Name=? where EmailUserID=?");
      $UserUpdate->execute($EmailUser{$EmailUserID}{Name}, $NewCertID);
    }
    if ($EmailUser{$EmailUserID}{EmailAddress} && !$EmailUser{$NewCertID}{EmailAddress}) {
      my $UserUpdate = $dbh_rw->prepare("update EmailUser set EmailAddress=? where EmailUserID=?");
      $UserUpdate->execute($EmailUser{$EmailUserID}{EmailAddress}, $NewCertID);
    }
    if ($EmailUser{$EmailUserID}{AuthorID} && !$EmailUser{$NewCertID}{AuthorID}) {
      my $UserUpdate = $dbh_rw->prepare("update EmailUser set AuthorID=? where EmailUserID=?");
      $UserUpdate->execute($EmailUser{$EmailUserID}{AuthorID}, $NewCertID);
    }
    if ($EmailUser{$EmailUserID}{CanSign} && !$EmailUser{$NewCertID}{CanSign}) {
      my $UserUpdate = $dbh_rw->prepare("update EmailUser set CanSign=1 where EmailUserID=?");
      $UserUpdate->execute($NewCertID);
    }
    if ($EmailUser{$EmailUserID}{Verified} && !$EmailUser{$NewCertID}{Verified}) {
      my $UserUpdate = $dbh_rw->prepare("update EmailUser set Verified=1 where EmailUserID=?");
      $UserUpdate->execute($NewCertID);
    }

    # Update all notifications
    my $NotificationUpdate = $dbh_rw->prepare("update Notification set EmailUserID=? where EmailUserID=?");
    $NotificationUpdate->execute($NewCertID, $EmailUserID);

    # Copy all groups
    my @UsersGroupIDs = FetchUserGroupIDs($EmailUserID);
    foreach my $UsersGroupID (@UsersGroupIDs) {
      my $UsersGroupSelect = $dbh_rw->prepare("select UsersGroupID from UsersGroup where EmailUserID=? and GroupID=?");
      $UsersGroupSelect->execute($NewCertID, $UsersGroupID);
      my ($ComboExists) = $UsersGroupSelect->fetchrow_array;
      unless ($ComboExists) {
        my $UsersGroupUpdate = $dbh_rw->prepare("insert into UsersGroup (UsersGroupID,EmailUserID,GroupID) " .
            " values (0,?,?)");
        $UsersGroupUpdate->execute($NewCertID, $UsersGroupID);
        FetchSecurityGroup($UsersGroupID);
        push @ActionStack, "Added user to $SecurityGroups{$UsersGroupID}{NAME}";
      }
    }

    # Update signed signatures
    my $SignatureUpdate = $dbh_rw->prepare("update Signature set EmailUserID=? where EmailUserID=?");
    $SignatureUpdate->execute($NewCertID, $EmailUserID);

    # Remove signature authority from the old account
    my $UserUpdate = $dbh_rw->prepare("update EmailUser set CanSign=0 where EmailUserID=?");
    $UserUpdate->execute($EmailUserID);
    DestroyConnection($dbh_rw);
  }
}

1;
