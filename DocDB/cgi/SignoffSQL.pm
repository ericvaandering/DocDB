#        Name:SignoffSQL.pm
# Description: SQL interface routines for signoffs
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2018 Eric Vaandering, Lynn Garren, Adam Bryant

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

use HTML::Entities;

sub ProcessSignoffList ($) {
  my ($SignoffList) = @_;

  require "EmailSecurity.pm";

  # FIXME: Handle authors in Smith, John format too

  my $EmailUserID;
  my @EmailUserIDs = ();
  my @SignatoryEntries = split /\n/,$SignoffList;
  foreach my $Entry (@SignatoryEntries) {
    chomp $Entry;
    $Entry =~ s/^\s+//g;
    $Entry =~ s/\s+$//g;
    my $SafeEntry = $Entry;
    $Entry = HTML::Entities::decode_entities($Entry);

    unless ($Entry) {
      push @WarnStack,"A blank line was entered into the signoff list. It was ignored.";
      next;
    }

    if (grep /\,/, $Entry) {
      @Parts = split /\,\s+/, $Entry,2;
      $Entry = join ' ',@Parts[1],@Parts[0];
    }

    my $EmailUserList = $dbh -> prepare("select EmailUserID from EmailUser where Name rlike ?");

### Find exact match (initial or full name)
    my $RegExp = '^('.$Entry.'|'.$SafeEntry.')$';
    $EmailUserList -> execute($RegExp);
    $EmailUserList -> bind_columns(undef, \($EmailUserID));
    @Matches = ();
    while ($EmailUserList -> fetch) {
      push @Matches,$EmailUserID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      if (CanSign($EmailUserID)) {
        push @EmailUserIDs,$EmailUserID;
        next;
      } else {
        push @ErrorStack,"$SafeEntry is not allowed to sign documents. Contact an administrator to change the permissions or ".
                         "restrict your choices to those who can sign documents.";
      }
    }

    push @ErrorStack,"No unique match was found for the signoff $SafeEntry. Contact an administrator to restrict ".
        "signatures to a single account per person.";
  }
  return @EmailUserIDs;
}

sub InsertSignoffList (@) {
  my ($DocRevID,@EmailUserIDs) = @_;

  require "EmailSecurity.pm";

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
    unless (CanSign($EmailUserID)) {
      push @WarnStack,"$EmailUser{$EmailUserID}{Name} cannot sign documents. Not added to list.";
      next;
    }
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

sub CopyRevisionSignoffs { # CopySignoffs from one revision to another
                           # One mode to copy with signed Signatures,
                           # one without

  my ($OldDocRevID,$NewDocRevID,$CopySignatures) = @_;

  my $SignoffInsert    = $dbh -> prepare("insert into Signoff (SignoffID,DocRevID,Note) ".
                                         "values (0,?,?)");
  my $SignatureInsert  = $dbh -> prepare("insert into Signature (SignatureID,EmailUserID,SignoffID,Note,Signed,TimeStamp) ".
                                         "values (0,?,?,?,?,?)");

  my %SignoffMap   = ();

  my @OldSignoffIDs = GetAllSignoffsByDocRevID($OldDocRevID);
  foreach my $OldSignoffID (@OldSignoffIDs) {
    # Copy the signoff
    FetchSignoff($OldSignoffID);
    $SignoffInsert->execute($NewDocRevID,$Signoffs{$OldSignoffID}{Note});
    my $NewSignoffID = $SignoffInsert->{mysql_insertid}; # Works with MySQL only
    $SignoffMap{$OldSignoffID} = $NewSignoffID;

    my @OldSignatureIDs = GetSignatures($OldSignoffID);
    foreach my $OldSignatureID (@OldSignatureIDs) {
      FetchSignature($OldSignatureID);
      # Copy Signatures
      my $Signed = $Signatures{$OldSignatureID}{Signed};
      my $TimeStamp = $Signatures{$OldSignatureID}{TimeStamp};
      if (!$CopySignatures) {
        $Signed = $FALSE;
        $TimeStamp = 0;
      }
      $SignatureInsert->execute($Signatures{$OldSignatureID}{EmailUserID}, $NewSignoffID,
                                $Signatures{$OldSignatureID}{Note},        $Signed,
                                $TimeStamp);
    }
  }
  my $DependencyInsert = $dbh -> prepare("insert into SignoffDependency (SignoffDependencyID,PreSignoffID,SignoffID) ".
                                         "values (0,?,?)");
  foreach my $OldSignoffID (@OldSignoffIDs) {
    my @OldPreSignoffIDs = GetPreSignoffs($OldSignoffID);
    foreach my $OldPreSignoffID (@OldPreSignoffIDs) {
      my $NewSignoffID    = $SignoffMap{$OldSignoffID};
      my $NewPreSignoffID = $SignoffMap{$OldPreSignoffID};
      unless ($NewPreSignoffID) {
        $NewPreSignoffID = 0; # Default, not NULL
      }
      $DependencyInsert->execute($NewPreSignoffID,$NewSignoffID);
    }
  }
}

1;
