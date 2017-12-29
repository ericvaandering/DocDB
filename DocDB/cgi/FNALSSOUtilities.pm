#
#        Name: FNALSSOUtilities.pm
# Description: Routines to deal with Mellon SSO used at FNAL 
#              as an authentication mechanism
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2017 Eric Vaandering, Lynn Garren, Adam Bryant

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

require "DocDBGlobals.pm";

require "SecuritySQL.pm";
require "NotificationSQL.pm";
require "Utilities.pm";

sub FetchSecurityGroupsForFSSO (%) {

  my @UsersGroupIDs = ();

  # If user is in DocDB's database, give them those groups
  my $EmailUserID = FetchEmailUserIDForFSSO();
  @UsersGroupIDs = FetchUserGroupIDs($EmailUserID);
  push @DebugStack,"User explicity has groups ".join ' ',@UsersGroupIDs;

  # Also map FNAL SSO groups to DocDB groups
  if (exists $ENV{'SSO_Session_ID'} && exists $ENV{$Preferences{Security}{SSOGroupVariables}}) {
    foreach my $GroupVariable ($Preferences{Security}{SSOGroupVariables}) {
      my @SsoGroups = split /;/,$ENV{$GroupVariable};
      foreach my $SsoGroup (@SsoGroups) {
        if ($SsoGroupMap{$SsoGroup}) {
          foreach my $DocDBGroup (@{ $SsoGroupMap{$SsoGroup} }) {
            my $UsersGroupID = FetchSecurityGroupByName($DocDBGroup);
            if ($UsersGroupID) {
              push @UsersGroupIDs,$UsersGroupID;
            }
          }
        }
      }
    }
  }
  push @DebugStack,"After SSO groups, DocDB groups for user: ".join ', ',@UsersGroupIDs;

  # And finally from their cert as well if we are not copying
  if (!$Preferences{Security}{TransferCertToSSO}) {
    $CertEmailUserID = FetchEmailUserIDByCertForSSO();
    if ($CertEmailUserID) {
      @CertGroupIDs = FetchUserGroupIDs($CertEmailUserID);
      push @UsersGroupIDs, @CertGroupIDs;
    }
    push @DebugStack, "After Cert groups, DocDB groups for user: " . join ', ', @UsersGroupIDs;
  }

  @UsersGroupIDs = Unique(@UsersGroupIDs);
  push @DebugStack,"Final unique DocDB groups for user: ".join ', ',@UsersGroupIDs;
  return @UsersGroupIDs;
}

sub FetchEmailUserIDForFSSO () {
  my $SSOName = $ENV{SSO_EPPN};
  push @DebugStack,"Finding EmailUserID by FNAL SSO name $SSOName";

  my $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser where Username=?");
  $EmailUserSelect -> execute('Mellon:'.$SSOName);

  my ($EmailUserID) = $EmailUserSelect -> fetchrow_array;
  my ($CertUserID, $SSOShortName);

  # If we don't find them by their name, try the certificate pattern
  if (!$EmailUserID) {
    $CertUserID = FetchEmailUserIDByCertForSSO();
  }

  if (!$EmailUserID and $Preferences{Security}{TransferCertToSSO}) {
    # If the preference is set, create the user and transfer certificate information
    $EmailUserID = CreateSSOUser();
    if ($CertUserID and $EmailUserID) {
       TransferEmailUserSettings( {-oldemailuserid => $CertUserID, -newemailuserid => $EmailUserID} );
    }
  } elsif (!$EmailUserID and $CertUserID) {
    # Just use the certificate info if it
    push @DebugStack, "Could not find SSO information for $SSOName, using EmailUserID $CertUserID from certificate.";
    $EmailUserID = $CertUserID;
  }

  if ($EmailUserID) {
    FetchEmailUser($EmailUserID)
  } else {
    push @DebugStack, "Could not find any user information for $SSOName";
  }
  push @DebugStack, "Determined user ID to be $EmailUserID";

  return $EmailUserID;
}

sub GetUserInfoFSSO() {
  $Username = "Unknown";
  $EmailAddress = "Unknown";
  $Name = "Unknown";

  if (exists $ENV{'SSO_Session_ID'}) {
    $Name = $ENV{SSO_NAME_FIRST}.' '.$ENV{SSO_NAME_LAST};
    $EmailAddress = $ENV{SSO_EMAIL};
    $Username = $ENV{SSO_EPPN};
  }

  return ('Mellon:'.$Username, $Username, $EmailAddress, $Name);
}

sub FetchEmailUserIDByCertForSSO() {
  # We have to handle this separately because a user can only have one ID which should be 
  # SSO if it exists, but this is used to grant more groups to a user. This can be made 
  # optional if required.
  
  my $SSOName = $ENV{SSO_EPPN};

  $SSOName =~ s/\@fnal\.gov//gi;
  my $SSOPattern = "%/DC=org/DC=cilogon/C=US/O=Fermi National Accelerator Laboratory/OU=People/%CN=UID:$SSOName";
  my $EmailUserSearch = $dbh->prepare("select EmailUserID from EmailUser where Username LIKE ?");
  $EmailUserSearch -> execute($SSOPattern);
  $EmailUserID = $EmailUserSearch -> fetchrow_array;
  push @DebugStack, "Determined user ID from cert to be $EmailUserID";

  return $EmailUserID;
}

sub CreateSSOUser() {
  my ($FQUN, $UserName, $Email, $Name) = GetUserInfoFSSO();
  push @DebugStack, "Creating FNAL SSO user in EmailUser with Username=$FQUN, Email=$Email, Name=$Name ";
  my $UserInsert = $dbh->prepare(
      "insert into EmailUser (EmailUserID,Username,Name,EmailAddress,Password,Verified) " .
      "values                (0,          ?,       ?,   ?,           ?,       1)");
  $UserInsert->execute($FQUN, $Name, $Email, 'x');
  $EmailUserID = FetchEmailUserIDForShib();
  return $EmailUserID;
}

1;
