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

sub SignoffStatus ($) {
  require "SignoffSQL.pm";
  
  my ($SignoffID) = @_;
  
  my $Status = "Ready";
  
  # Check to see if there is already a signature for this signoff
  
  my @SignatureIDs = &GetSignatures($SignoffID);
  foreach my $SignatureID (@SignatureIDs) {  # Loop over signatures
    &FetchSignature($SignatureID);
    if ($Signatures{$SignatureID}{Signed}) { # See if signed
      $Status = "Signed";
      return $Status;
    }
  }    
    
  # Now check to see if all prerequisites are signed?  
    
  my @PreSignoffIDs = &GetPreSignoffs($SignoffID);
  foreach my $PreSignoffID (@PreSignoffIDs) { # Loop over PreSignoffs
    if (!$PreSignoffID) { # Is zero for root signatures
      $SignedOff = 1;
    } else {  
      $SignedOff = 0;
      my @SignatureIDs = &GetSignatures($PreSignoffID);
      foreach my $SignatureID (@SignatureIDs) {  # Loop over signatures
        &FetchSignature($SignatureID);
        if ($Signatures{$SignatureID}{Signed}) { # See if signed
          $SignedOff = 1;
        }
      }
    }  
    unless ($SignedOff) { # All signatures of signoff unsigned
      $Status = "NotReady";
      return $Status;
    }
  }
  
  return $Status;        
  
}

sub RecurseSignoffStatus ($) {
  require "SignoffSQL.pm";
  
  my ($SignoffID) = @_;
  
  my $Status = "Approved";
 
  my $SignoffStatus = &SignoffStatus($SignoffID);
  if ($SignoffStatus eq "Signed") { # Check status of this signoff

# Find signoffs that depend on this, if any

    my @SubSignoffIDs = &GetSubSignoffs($SignoffID);
    foreach my $SubSignoffID (@SubSignoffIDs) { # Check these
      my $SignoffStatus =  &RecurseSignoffStatus($SubSignoffID);
      unless ($SignoffStatus eq "Approved") {
        $Status = "Unapproved";
        last;
      }
    }    
  } else {
    $Status = "Unapproved";
  }  
  return $Status; 
}

sub RevisionStatus ($) { # Return the approval status of a revision
                         # and the last approved version (if exists)
                         # Status can be approved, unapproved, unmanaged, demanaged
  require "SignoffSQL.pm";
  require "RevisionSQL.pm";
  require "Sorts.pm";
  
  my ($DocRevID) = @_;
  &FetchDocRevisionByID($DocRevID);
  
  my $Status       = "Approved";
  my $LastDocRevID = undef;
  
  my @RootSignoffIDs = &GetRootSignoffs($DocRevID);
  if (@RootSignoffIDs) {
    foreach my $SignoffID (@RootSignoffIDs) {
      my $SignoffStatus = &RecurseSignoffStatus($SignoffID);
      unless ($SignoffStatus eq "Approved") {
        $Status = "Unapproved";
        last;
      }  
    }
  } else {
    $Status = "Unmanaged";
  }  

  if ($DocRevisions{$DocRevID}{Demanaged}) {
    $Status = "Demanaged";
  }

  # Find last approved version
  if ($Status eq "Approved") {
    $LastDocRevID = $DocRevID;
  } elsif ($Status eq "Unapproved") {
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    my @DocRevIDs   = reverse sort RevisionByVersion &FetchRevisionsByDocument($DocumentID);
    foreach my $CheckRevID (@DocRevIDs) {
      &FetchDocRevisionByID($CheckRevID);
      my $Status         = "Approved";
      my @RootSignoffIDs = &GetRootSignoffs($CheckRevID);
      if (@RootSignoffIDs) {
        foreach my $SignoffID (@RootSignoffIDs) {
          my $SignoffStatus = &RecurseSignoffStatus($SignoffID);
          unless ($SignoffStatus eq "Approved") {
            $Status = "Unapproved";
            last;
          }  
        }
      } else {
        $Status = "Unmanaged";
      }  

      if ($DocRevisions{$CheckRevID}{Demanaged}) {
        $Status = "Demanaged";
      }
      if ($Status eq "Approved") {
        $LastDocRevID = $CheckRevID;
        last;
      }  
    } 
  }  
  return ($Status,$LastDocRevID);
}

sub BuildSignoffDefault ($) {
  require "SignoffSQL.pm";
  require "NotificationSQL.pm";
  
  my ($DocRevID) = @_;
 
  # Can only handle sequential list. 
  # Will probably convert more complicated signoffs to this
 
  my @EmailUserIDs = ();
 
  my ($SignoffID) = &GetRootSignoffs($DocRevID);
  
  while ($SignoffID) {
    my ($SignatureID) = &GetSignatures($SignoffID);
    &FetchSignature($SignatureID);
    push @EmailUserIDs,$Signatures{$SignatureID}{EmailUserID};
    my ($NewSignoffID) = &GetSubSignoffs($SignoffID);
    $SignoffID = $NewSignoffID; 
  }
  
  my $Default = "";
  
  foreach my $EmailUserID (@EmailUserIDs) {
    &FetchEmailUser($EmailUserID);
    $Default .= $EmailUser{$EmailUserID}{Name} . "\n";
  }

  return $Default;
}

sub UnsignRevision { # Remove all signatures from a revision
                     # (Called when files are added to a revision)
  require "SignoffSQL.pm";
  
  my ($DocRevID) = @_;
  
  my $SignatureUpdate = $dbh -> prepare("update Signature set Signed=0 where SignatureID=?");
  
  my @SignoffIDs = &GetAllSignoffsByDocRevID($DocRevID);
  
  foreach my $SignoffID (@SignoffIDs) {
    my @SignatureIDs = &GetSignatures($SignoffID);
    foreach my $SignatureID (@SignatureIDs) {
      $SignatureUpdate -> execute($SignatureID); 
    }  
  }
  
  my $Status = "";
  if (@SignoffIDs) {
    $Status = "Unsigned";
  } else {
    $Status = "NoAction";
  }
  
  return $Status;    
}

sub NotifySignees ($) {
  require "SignoffSQL.pm";
  require "MailNotification.pm";
  
  my ($DocRevID) = @_;

  my @SignoffIDs   = &GetAllSignoffsByDocRevID($DocRevID);
  my @EmailUserIDs = ();
  foreach my $SignoffID (@SignoffIDs) {
    if (&SignoffStatus($SignoffID) eq "Ready") {
      my @SignatureIDs = &GetSignatures($SignoffID);
      foreach my $SignatureID (@SignatureIDs) {
        push @EmailUserIDs,$Signatures{$SignatureID}{EmailUserID};
#        print "Notifying $Signatures{$SignatureID}{EmailUserID}<br>\n";
      }
    } 
  }
  &MailNotices(-docrevid => $DocRevID, -type => "sign", -emailids => \@EmailUserIDs);
}

sub CopyRevisionSignoffs { # CopySignoffs from one revision to another
                           # One mode to copy with signed Signatures, 
                           # one without

  my ($OldDocRevID,$NewDocRevID,$CopySignatures) = @_;

}

1;
