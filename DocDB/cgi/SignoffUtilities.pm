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
  
  my ($DocRevID) = @_;
  &FetchDocRevisionByID($DocRevID);
  
  my $Status      = "Approved";
  my $LastVersion = undef;
  
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

  return ($Status,$LastVersion);
}

1;
