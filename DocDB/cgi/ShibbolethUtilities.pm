# Description: Routines to deal with shibboleth as an authentication mechanism
#
#        Name: $RCSfile$
# Description: Generates HTML for things related to signoffs
#
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2009 Eric Vaandering, Lynn Garren, Adam Bryant

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


sub FetchSecurityGroupsForShib (%) {
  require "SecuritySQL.pm";

  my %ShibGroupMap = { "cms-members" => "cmspix", "cms-service-docdb" => "DocDBAdm" }; #FIXME move to ProjectGlobals
  my @ShibGroups = split /;/,$ENV{ADFS_GROUP};

  foreach my $ShibGroup (@ShibGroups) {
    push @DebugStack,"Checking $ShibGroup";
    if ($ShibGroupMap{ShibGroup}) {
      push @DebugStack,"Getting ID for ".$ShibGroupMap{ShibGroup};

      my $UsersGroupID = FetchSecurityGroupByName($ShibGroupMap{ShibGroup});
      if ($UsersGroupID) {
        push @DebugStack,"Got ID $UsersGroupID";
        push @UsersGroupIDs,$UsersGroupID;
      }
    }
  }

  return @UserGroupIDs;
}

sub FetchEmailUserIDForShib (%) {
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
#   push @DebugStack,"Finding EmailUserID by certificate $CertCN";
#
#   # If we do http basic with users, this routine will function with minor modifications
#
#   my $EmailUserSelect;
#   if ($IgnoreVerification) {
#     $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
#                                      "where Name=?");
#   } else {
#     $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
#                                      "where Verified=1 and Name=?");
#   }
#   $EmailUserSelect -> execute($CertCN);
#
#   my ($EmailUserID) = $EmailUserSelect -> fetchrow_array;
#   push @DebugStack,"Found e-mail user: $EmailUserID";
#
#   if ($EmailUserID) {
#     FetchEmailUser($EmailUserID)
#   }
#
#   return $EmailUserID;
}

1;
