# Description: Various routines to deal with certificates 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2004 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

sub FetchSecurityGroupsByCert () {
 
  my $CertEmail = $ENV{whatever};

  my $EmailUserSelect = $dbh->prepare("select EmailUserID from SecurityGroup where Verified = 1 and EmailAddress = ?");
  $EmailUserSelect -> execute($CertEmail);

  my ($EmailUserID) = $EmailUserSelect -> fetchrow_array; 
  
  my @UserGroupIDs = ();
  my $UserGroupID;
  
  if ($EmailUserID) {
    my $GroupList = $dbh->prepare("select GroupID from UsersGroup where EmailUserID=?");
    $GroupList -> execute($EmailUserID);
    $GroupList -> bind_columns(undef, \($UserGroupID));
    while ($GroupList -> fetch) {
      push @UserGroupIDs,$UserGroupID;
    }
  }
  
  return @UserGroupIDs;
}


1;
