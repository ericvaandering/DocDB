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

require "SecuritySQL.pm";
require "NotificationSQL.pm";
require "Utilities.pm";

# TODO:  Write instructions? Use Shibboleth instructions?

sub FetchSecurityGroupsForFSSO (%) {

  my @UsersGroupIDs = ();

  # If user is in DocDB's database, give them those groups
  my $EmailUserID = FetchEmailUserIDForFSSO();
  @UsersGroupIDs = FetchUserGroupIDs($EmailUserID);
  
  push @DebugStack,"User explicity has groups ".join ' ',@UsersGroupIDs;

  # Also map FNAL SSO groups to DocDB groups

  if (exists $ENV{'SSO_Session_ID'}) {
    my @SsoGroups = split /;/,$ENV{SSO_FNAL_GROUPS};

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
  
  @UsersGroupIDs = Unique(@UsersGroupIDs);
  push @DebugStack,"After SSO groups, DocDB groups for user: ".join ', ',@UsersGroupIDs;
  return @UsersGroupIDs;
}

sub FetchEmailUserIDForFSSO () {
  my $SSOName = $ENV{SSO_USERID};
  push @DebugStack,"Finding EmailUserID by FNAL SSO name $SSOName";

  my $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                      "where Username=?");
  $EmailUserSelect -> execute($SSOName);

  my ($EmailUserID) = $EmailUserSelect -> fetchrow_array;

  # If we don't find them by their name, try the certificate pattern
  
  if (!$EmailUserID) { 
    $SSOPattern = "%cilogon%CN=UID:$SSOName";
    my $EmailUserSearch = $dbh->prepare("select EmailUserID from EmailUser where Username LIKE ?");
    $EmailUserSearch -> execute($SSOPattern);
    $EmailUserID = $EmailUserSearch -> fetchrow_array;
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
    $Username = $ENV{SSO_USERID};
  }

  return ($Username, $EmailAddress, $Name);
}

1;

