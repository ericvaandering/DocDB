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

sub FetchSecurityGroupsByCert (%) {
  require "SecuritySQL.pm"; 
  my %Params = @_;
  my $EmailUserID  = &FetchEmailUserIDByCert(%Params);
  my @UserGroupIDs = &FetchUserGroupIDs($EmailUserID);
  return @UserGroupIDs;
}

sub FetchEmailUserIDByCert (%) {
  require "SecuritySQL.pm"; 
  my %Params = @_;

  my $IgnoreVerification = $Params{-ignoreverification};
 
  my $CertEmail = $ENV{SSL_CLIENT_S_DN_Email};
  my $CertCN    = $ENV{SSL_CLIENT_S_DN_CN};

  # If we do http basic with users, this routine will function with minor modifications

  my $EmailUserSelect;
  if ($Preferences{Security}{Certificates}{UseCNOnly}) {  
    if ($IgnoreVerification) {
      $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                       "where Name=?");
    } else {                                   
      $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                       "where Verified=1 and Name=?");
    }
    $EmailUserSelect -> execute($CertCN);
  } else {
    if ($IgnoreVerification) {
      $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                       "where EmailAddress=? and Name=?");
    } else {                                   
      $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                       "where Verified=1 and EmailAddress=? and Name=?");
    }
    $EmailUserSelect -> execute($CertEmail,$CertCN);
  }                                    

  my ($EmailUserID) = $EmailUserSelect -> fetchrow_array; 
  push @DebugStack,"Found e-mail user: $EmailUserID";
  
  return $EmailUserID;
}

sub CertificateStatus () {

  # This routine returns the status of the certificate the user presents. It can have
  # one of several values:
  #
  # verified   --  certificate is valid and user has been given access to DocDB by admin
  # unverified --  certificate is valid and unique, but user has not been given access
  # mismatch   --  certificate is valid, but e-mail or CN conflicts with existing user
  # noapp      --  certificate is valid, but has never requested access
  # nocert     --  no certificate was presented (not sure if this can work)

  my $CertificateStatus = "";
 
  my $CertEmail = $ENV{SSL_CLIENT_S_DN_Email};
  my $CertCN    = $ENV{SSL_CLIENT_S_DN_CN};
  
  unless (($CertEmail && $CertCN) || ($CertCN && $Preferences{Security}{Certificates}{UseCNOnly}) {
    $CertificateStatus = "nocert";
    return $CertificateStatus;
  } 
    
  my $EmailUserSelect;
  if ($Preferences{Security}{Certificates}{UseCNOnly}) {  
    $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                       "where Name=?");
    $EmailUserSelect -> execute($CertCN);
    push @DebugStack,"Checking user $CertCN";
  } else {
    $EmailUserSelect = $dbh->prepare("select EmailUserID from EmailUser ".
                                       "where EmailAddress=? and Name=?");
    $EmailUserSelect -> execute($CertEmail,$CertCN);
  }                                    

  my ($EmailUserID,$Verified) = $EmailUserSelect -> fetchrow_array; 
  
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
  
  if ($Preferences{Security}{Certificates}{UseCNOnly}) { # Can't do mismatch check
    $CertificateStatus = "noapp";
    push @DebugStack,"Certificate Status: $CertificateStatus";
    return $CertificateStatus;
  } 
   
  my $AddressSelect = $dbh->prepare("select EmailUserID from EmailUser where EmailAddress=?");
     $AddressSelect -> execute($CertEmail);
  my ($AddressID) = $AddressSelect -> fetchrow_array; 

  my $NameSelect = $dbh->prepare("select EmailUserID from EmailUser where Name=?");
     $NameSelect -> execute($CertCN);
  my ($NameID) = $NameSelect -> fetchrow_array; 
    
  if ($NameID || $AddressID) {
    $CertificateStatus = "mismatch";
  } else {
    $CertificateStatus = "noapp";
  }
  push @DebugStack,"Certificate Status: $CertificateStatus";
  return $CertificateStatus;
}

1;
