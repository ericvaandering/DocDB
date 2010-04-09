#
#        Name: $RCSfile$
# Description: Routines to deal with shibboleth as an authentication mechanism
#
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2010 Eric Vaandering, Lynn Garren, Adam Bryant

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


sub FetchSecurityGroupsForShib (%) {

  my @UsersGroupIDs = ();

  # If user is in DocDB's database, give them those groups
  my $EmailUserID = FetchEmailUserIDForShib();
  @UsersGroupIDs = FetchUserGroupIDs($EmailUserID);

  if (@UsersGroupIDs) {
    return @UsersGroupIDs;
  }

  # Otherwise map shibboleth groups to DocDB groups

  push @DebugStack,"Setting DocDB groups from shibboleth groups";
  my %ShibGroupMap = ( "cms-members" => "cmspix", "cms-service-docdb" => "DocDBAdm" ); #FIXME move to ProjectGlobals
  my @ShibGroups = split /;/,$ENV{ADFS_GROUP};

  foreach my $ShibGroup (@ShibGroups) {
    if ($ShibGroupMap{$ShibGroup}) {
      my $UsersGroupID = FetchSecurityGroupByName($ShibGroupMap{$ShibGroup});
      if ($UsersGroupID) {
        push @UsersGroupIDs,$UsersGroupID;
      }
    }
  }
  return @UsersGroupIDs;
}

sub FetchEmailUserIDForShib () {
#   my %Params = @_;
#
#   my $IgnoreVerification = $Params{-ignoreverification};
#
#   require "SecuritySQL.pm";
#   require "NotificationSQL.pm";
#
#   my $CertEmail = $ENV{SSL_CLIENT_S_DN_Email};
#   my $CertCN    = $ENV{SSL_CLIENT_S_DN_CN};
#
#   $CertificateCN    = $CertCN;
#   $CertificateEmail = $CertEmail;
#
  my $ShibName = $ENV{ADFS_LOGIN};
  push @DebugStack,"Finding EmailUserID by shibboleth $ShibName";
#
#   # If we do http basic with users, this routine will function with minor modifications
#
  my $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                       "where Name=?");
#   } else {
#     $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
#                                      "where Verified=1 and Name=?");
#   }
  $EmailUserSelect -> execute($ShibName);
#
  my ($EmailUserID) = $EmailUserSelect -> fetchrow_array;
  push @DebugStack,"Found e-mail user: $EmailUserID";
#
  if ($EmailUserID) {
    FetchEmailUser($EmailUserID)
  }
#
  return $EmailUserID;
}

1;
