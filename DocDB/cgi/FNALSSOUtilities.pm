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
  # And finally from their cert as well
  
  $CertEmailUserID = FetchEmailUserIDByCert();
  if ($CertEmailUserID) {
    @CertGroupIDs = FetchUserGroupIDs($CertEmailUserID);
    foreach my $CertGroupID (@CertGroupIDs) {
      push @UsersGroupIDs, $CertGroupID;
    }
  }
  push @DebugStack,"After Cert groups, DocDB groups for user: ".join ', ',@UsersGroupIDs;
  @UsersGroupIDs = Unique(@UsersGroupIDs);
  push @DebugStack,"Final unique DocDB groups for user: ".join ', ',@UsersGroupIDs;
  return @UsersGroupIDs;
}

sub FetchEmailUserIDForFSSO () {
  my $SSOName = $ENV{SSO_EPPN};
  push @DebugStack,"Finding EmailUserID by FNAL SSO name $SSOName";

  my $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                      "where Username=?");
  $EmailUserSelect -> execute('Mellon:'.$SSOName);

  my ($EmailUserID) = $EmailUserSelect -> fetchrow_array;

  # If we don't find them by their name, try the certificate pattern
  
  if (!$EmailUserID) {
    $SSOShortName = $SSOName;
    $SSOShortName =~ s/\@fnal\.gov//gi;

    my $SSOPattern = "%/DC=org/DC=cilogon/C=US/O=Fermi National Accelerator Laboratory/OU=People/%CN=UID:$SSOShortName";
    my $EmailUserSearch = $dbh->prepare("select EmailUserID from EmailUser where Username LIKE ?");
    $EmailUserSearch -> execute($SSOPattern);
    $EmailUserID = $EmailUserSearch -> fetchrow_array;
    push @DebugStack, "Determined user ID from cert to be $EmailUserID";
  }
  if ($EmailUserID) {
    FetchEmailUser($EmailUserID)
  }
  push @DebugStack, "Determined user ID to be $EmailUserID";

  return $EmailUserID;
}

sub GetUserInfoFSSO () {

  $Username = "Unknown";
  $EmailAddress = "Unknown";
  $Name = "Unknown";

  if (exists $ENV{'SSO_Session_ID'}) {
    $Name = $ENV{SSO_NAME_FIRST}.' '.$ENV{SSO_NAME_LAST};
    $EmailAddress = $ENV{SSO_EMAIL};
    $Username = $ENV{SSO_EPPN};
  }

  return ($Username, $EmailAddress, $Name);
}


sub FetchEmailUserIDByCert() {
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

1;

