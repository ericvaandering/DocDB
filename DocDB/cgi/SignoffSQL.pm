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

sub ProcessSignoffList ($) {
  my ($SignoffList) = @_;
  
  # FIXME: Handle authors in Smith, John format too
  
  my $EmailUserID;
  my @EmailUserIDs = ();
  my @SignatoryEntries = split /\n/,$SignoffList;
  foreach my $Entry (@SignatoryEntries) {
    $Entry =~ s/^\s+//g;
    $Entry =~ s/\s+$//g;
    
    my $EmailUserList = $dbh -> prepare("select EmailUserID from EmailUser where Name=?"); 

### Find exact match (initial or full name)

    $EmailUserList -> execute($Entry);
    $EmailUserList -> bind_columns(undef, \($EmailUserID));
    @Matches = ();
    while ($EmailUserList -> fetch) {
      push @Matches,$EmailUserID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      push @EmailUserIDs,$EmailUserID;
      next;
    }
    
    push @ErrorStack,"No unique match was found for the signoff $Entry. Please go 
                      back and try again.";   
  }
  return @EmailUserIDs;
}

sub InsertSignoffList (@) {
  my ($DocRevID,@EmailUserIDs) = @_;
  
  my $SignoffInsert    = $dbh -> prepare("insert into Signoff (SignoffID,DocRevID) ".
                                         "values (0,?)");
  my $SignatureInsert  = $dbh -> prepare("insert into Signature (SignatureID,EmailUserID,SignoffID) ".
                                         "values (0,?,?)");
  my $DependencyInsert = $dbh -> prepare("insert into SignoffDependency (SignoffDependencyID,PreSignoffID,SignoffID) ".
                                         "values (0,?,?)");
  
  # For now, we just do something simple. Insert the first with one signature,
  # the second depends on it, etc.
  
  my $PreSignoffID = 0;
  my $FirstSignoffID = 0;
  foreach $EmailUserID (@EmailUserIDs) {
    $SignoffInsert    -> execute($DocRevID);
    my $SignoffID = $SignoffInsert -> {mysql_insertid}; # Works with MySQL only
    unless ($FirstSignoffID) {
      $FirstSignoffID = $SignoffID;
    }  
    $SignatureInsert  -> execute($EmailUserID,$SignoffID);
    $DependencyInsert -> execute($PreSignoffID,$SignoffID);
    $PreSignoffID = $SignoffID;
  }                                       
  return $FirstSignoffID;                                       
}

sub GetRootSignoffs ($) {
  my ($DocRevID) = @_;
  
  my @RootSignoffs = ();
  
  my $SignoffList = $dbh -> prepare("select Signoff.SignoffID from Signoff,SignoffDependency ".
                                     "where SignoffDependency.PreSignoffID=0 ".
                                      "and SignoffDependency.SignoffID=Signoff.SignoffID ".
                                      "and Signoff.DocRevID=?");
                        
  $SignoffList -> execute($DocRevID);
  $SignoffList -> bind_columns(undef, \($SignoffID));
  while ($SignoffList -> fetch) {
    push @RootSignoffs,$SignoffID;
  }
  
  return @RootSignoffs;  
}
                        
sub GetSubSignoffs ($) {
  my ($PreSignoffID) = @_;
  
  my $SignoffID;
  my @SubSignoffIDs = ();
  
  my $SignoffList = $dbh -> prepare("select Signoff.SignoffID from Signoff,SignoffDependency ".
                                     "where SignoffDependency.PreSignoffID=? ".
                                      "and SignoffDependency.SignoffID=Signoff.SignoffID");
                        
  $SignoffList -> execute($PreSignoffID);
  $SignoffList -> bind_columns(undef, \($SignoffID));
  while ($SignoffList -> fetch) {
    push @SubSignoffIDs,$SignoffID;
  }
  
  return @SubSignoffIDs;  
}
                        
sub GetSignatures ($) {
  my ($SignoffID) = @_;
  
  my $SignatureID;
  my @SignatureIDs = ();
  
  my $SignatureList = $dbh -> prepare("select SignatureID from Signature ".
                                     "where SignoffID=?");
                        
  $SignatureList -> execute($SignoffID);
  $SignatureList -> bind_columns(undef, \($SignatureID));
  while ($SignatureList -> fetch) {
    push @SignatureIDs,$SignatureID;
  }
  
  return @SignatureIDs;  
}

sub FetchSignature ($) {
  my ($SignatureID) = @_;
  
  my ($EmailUserID,$SignoffID,$Note,$Signed,$TimeStamp);
  my $SignatureFetch = $dbh -> prepare("select EmailUserID,SignoffID,Note,Signed,TimeStamp from Signature ".
                                     "where SignatureID=?");

  $SignatureFetch -> execute($SignatureID);
  ($EmailUserID,$SignoffID,$Note,$Signed,$TimeStamp) = $SignatureFetch -> fetchrow_array;
  
  if ($TimeStamp) {
    $Signatures{$SignatureID}{EmailUserID} = $EmailUserID;
    $Signatures{$SignatureID}{SignoffID}   = $SignoffID  ;
    $Signatures{$SignatureID}{Note}        = $Note       ;
    $Signatures{$SignatureID}{Signed}      = $Signed     ;
    $Signatures{$SignatureID}{TimeStamp}   = $TimeStamp  ;
    return $SignatureID;
  } else {
    return 0;
  }  
}
                        
1;
