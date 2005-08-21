# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

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
    chomp $Entry;
    $Entry =~ s/^\s+//g;
    $Entry =~ s/\s+$//g;
    
    if (grep /\,/, $Entry) {
      @Parts = split /\,\s+/, $Entry,2;
      $Entry = join ' ',@Parts[1],@Parts[0];
    }  

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
                        
sub GetAllSignoffsByDocRevID ($) {
  my ($DocRevID) = @_;
  
  my @SignoffIDs = ();
  
  my $SignoffList = $dbh -> prepare("select SignoffID from Signoff ".
                                     "where DocRevID=?");
                        
  $SignoffList -> execute($DocRevID);
  $SignoffList -> bind_columns(undef, \($SignoffID));
  while ($SignoffList -> fetch) {
    push @SignoffIDs,$SignoffID;
  }
  
  return @SignoffIDs;  
}

sub GetSignoffDocumentIDs (%) {
  my %Params = @_;
  
  my $EmailUserID = $Params{-emailuserid} || 0;
  
  my @DocumentIDs = ();
  my $List;

  if ($EmailUserID) {
    $List = $dbh -> prepare("select DISTINCT(DocumentRevision.DocumentID) from Signature,Signoff,DocumentRevision
            where Signature.EmailUserID=? and Signoff.SignoffID=Signature.SignoffID and
            Signoff.DocRevID=DocumentRevision.DocRevID");
    $List -> execute($EmailUserID);
  }  

  if ($List) {
    my $DocumentID;
    $List -> bind_columns(undef, \($DocumentID));
    while ($List -> fetch) {
      push @DocumentIDs,$DocumentID;
    }
  }  
  
  return @DocumentIDs;
}

sub GetSignoffDocRevIDs (%) {
  my %Params = @_;
  
  my $EmailUserID = $Params{-emailuserid} || 0;
  
  my @DocRevIDs = ();
  my $List;

  if ($EmailUserID) {
    $List = $dbh -> prepare("select DISTINCT(Signoff.DocRevID) from Signature,Signoff
            where Signature.EmailUserID=? and Signoff.SignoffID=Signature.SignoffID");
    $List -> execute($EmailUserID);
  }  

  if ($List) {
    my $DocRevID;
    $List -> bind_columns(undef, \($DocRevID));
    while ($List -> fetch) {
      push @DocRevIDs,$DocRevID;
    }
  }  
  
  return @DocRevIDs;
}

sub GetSignoffIDs (%) {
  my %Params = @_;
  
  my $EmailUserID = $Params{-emailuserid} || 0;
  
  my @SignoffIDs = ();
  my $List;

  if ($EmailUserID) {
    $List = $dbh -> prepare("select DISTINCT(Signature.SignoffID) from Signature
            where Signature.EmailUserID=?");
    $List -> execute($EmailUserID);
  }  

  if ($List) {
    my $SignoffID;
    $List -> bind_columns(undef, \($SignoffID));
    while ($List -> fetch) {
      push @SignoffIDs,$SignoffID;
    }
  }  
  
  return @SignoffIDs;
}

sub FetchSignoff ($) {
  my ($SignoffID) = @_;

  my ($DocRevID,$Note,$TimeStamp);
  my $SignoffFetch = $dbh -> prepare("select DocRevID,Note,TimeStamp from Signoff ".
                                     "where SignoffID=?");

  if ($Signoffs{$SignoffID}{TimeStamp}) {
    return $SignoffID;
  }
  
  $SignoffFetch -> execute($SignoffID);
  ($DocRevID,$Note,$TimeStamp) = $SignoffFetch -> fetchrow_array;
  
  if ($TimeStamp) {
    $Signoffs{$SignoffID}{DocRevID}    = $DocRevID   ;
    $Signoffs{$SignoffID}{Note}        = $Note       ;
    $Signoffs{$SignoffID}{TimeStamp}   = $TimeStamp  ;
    return $SignoffID;
  } else {
    return 0;
  }  
}
                        
sub GetSubSignoffs ($) {
  my ($PreSignoffID) = @_;
  
  my $SignoffID;
  my @SubSignoffIDs = ();
  
  my $SignoffList = $dbh -> prepare("select SignoffID from SignoffDependency ".
                                     "where PreSignoffID=?");
                        
  $SignoffList -> execute($PreSignoffID);
  $SignoffList -> bind_columns(undef, \($SignoffID));
  while ($SignoffList -> fetch) {
    push @SubSignoffIDs,$SignoffID;
  }
  
  return @SubSignoffIDs;  
}
                        
sub GetPreSignoffs ($) {
  my ($SignoffID) = @_;
  
  my $PreSignoffID;
  my @PreSignoffIDs = ();
  
  my $SignoffList = $dbh -> prepare("select PreSignoffID from SignoffDependency ".
                                     "where SignoffID=?");
                        
  $SignoffList -> execute($SignoffID);
  $SignoffList -> bind_columns(undef, \($PreSignoffID));
  while ($SignoffList -> fetch) {
    push @PreSignoffIDs,$PreSignoffID;
  }
  
  return @PreSignoffIDs;  
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
    &FetchSignature($SignatureID);
    push @SignatureIDs,$SignatureID;
  }
  
  return @SignatureIDs;  
}

sub ClearSignatures {
  $HaveAllSignatures = 0;
  %Signatures = ();
}

sub FetchSignature ($) {
  my ($SignatureID) = @_;
  
  my ($EmailUserID,$SignoffID,$Note,$Signed,$TimeStamp);
  my $SignatureFetch = $dbh -> prepare("select EmailUserID,SignoffID,Note,Signed,TimeStamp from Signature ".
                                     "where SignatureID=?");

  if ($Signatures{$SignatureID}{TimeStamp}) {
    return $SignatureID;
  }
  
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
