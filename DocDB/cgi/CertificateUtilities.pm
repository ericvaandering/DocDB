# Description: Various routines to deal with certificates 
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

sub FetchSecurityGroupsByCert (%) {
  require "SecuritySQL.pm"; 
  my %Params = @_;
  my $EmailUserID  = FetchEmailUserIDByCert(%Params);
  if ($EmailUser{$EmailUserID}{Verified} != 1) {
    push @DebugStack,"User is not verified";
    push @WarnStack,"You have a valid certificate, but have are not yet allowed to access to DocDB. 
                   <a href=\"$CertificateApplyForm\">Apply for access.</a>";
    return;
  }  
  my @UserGroupIDs = FetchUserGroupIDs($EmailUserID);
  return @UserGroupIDs;
}

sub FetchEmailUserIDByCert (%) {
  my %Params = @_;

  my $IgnoreVerification = $Params{-ignoreverification};
 
  require "SecuritySQL.pm"; 
  require "NotificationSQL.pm"; 

  my $CertEmail = $ENV{SSL_CLIENT_S_DN_Email};
  my $CertCN    = $ENV{SSL_CLIENT_S_DN_CN};

  $CertificateCN    = $CertCN; 
  $CertificateEmail = $CertEmail; 

  push @DebugStack,"Finding EmailUserID by certificate $CertCN";

  # If we do http basic with users, this routine will function with minor modifications

  my $EmailUserSelect;
  if ($IgnoreVerification) {
    $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                     "where Name=?");
  } else {                                   
    $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                     "where Verified=1 and Name=?");
  }
  $EmailUserSelect -> execute($CertCN);

  my ($EmailUserID) = $EmailUserSelect -> fetchrow_array; 
  push @DebugStack,"Found e-mail user: $EmailUserID";

  if ($EmailUserID) {
    FetchEmailUser($EmailUserID)
  }
  
  return $EmailUserID;
}

sub CertificateStatus () {

  # This routine returns the status of the certificate the user presents. It can have
  # one of several values:
  #
  # verified   --  certificate is valid and user has been given access to DocDB by admin
  # unverified --  certificate is valid and unique, but user has not been given access
  # noapp      --  certificate is valid, but has never requested access
  # nocert     --  no certificate was presented (not sure if this can work)

  my $CertificateStatus = "";
 
  my $CertEmail = $ENV{SSL_CLIENT_S_DN_Email};
  my $CertCN    = $ENV{SSL_CLIENT_S_DN_CN};
  
  push @DebugStack,"Finding Status by certificate";
  
  unless ($CertCN) {
    $CertificateStatus = "nocert";
    push @DebugStack,"Certificate Status: $CertificateStatus";
    return $CertificateStatus;
  } 
    
  my $EmailUserSelect;
  $EmailUserSelect = $dbh->prepare("select EmailUserID,Verified from EmailUser ".
                                     "where Name=?");
  $EmailUserSelect -> execute($CertCN);
  my ($EmailUserID,$Verified) = $EmailUserSelect -> fetchrow_array; 
  push @DebugStack,"Checking user $CertCN by CN";
  
  if ($Verified) {
    $CertificateStatus = "verified";
    push @DebugStack,"Certificate Status: $CertificateStatus";
    return $CertificateStatus;
  } 
  
  if ($EmailUserID) {
    $CertificateStatus = "unverified";
    push @DebugStack,"Certificate Status: $CertificateStatus";
    return $CertificateStatus;
  } 
  
  $CertificateStatus = "noapp";
  push @DebugStack,"Certificate Status: $CertificateStatus";
  return $CertificateStatus;
}

1;
