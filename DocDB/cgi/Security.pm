#
# Description: Routines to determine various levels of access to documents 
#              and the database based on usernames, doc numbers, etc.
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

sub CanAccess { # Can the user access (with current security) this version
  my ($documentID,$version) = @_;

  require "RevisionSQL.pm";
  require "SecuritySQL.pm";
  
## FIXME: Use SecurityLookup  
  
  unless (keys %SecurityGroups) {
    &GetSecurityGroups;
  }  

  my $DocRevID = &FetchRevisionByDocumentAndVersion($documentID,$version);
  
  unless ($DocRevID) { # Document doesn't exist
    return 0;
  }
  if ($Documents{$documentID}{NVersions} eq "") { # Bad documents (no revisions)
    return 0;
  } 
  
  my @GroupIDs = &GetRevisionSecurityGroups($DocRevID);
  unless (@GroupIDs) {return 1;}             # Public documents

# See if current user is in the list of users who can access this document
  
  my $access = 0;

  foreach my $GroupID (@GroupIDs) { # Check auth. users vs. logged in user
    my $ok_user = $SecurityGroups{$GroupID}{NAME};
       $ok_user =~ tr/[A-Z]/[a-z]/; 
    if ($ok_user eq $remote_user) {
      $access = 1;                           # User checks out
    }  
  }
  if ($access) {return $access;}

# See if current users children can access this document

  my @HierarchyIDs = keys %GroupsHierarchy;
  foreach $ID (@HierarchyIDs) {
    $Parent = $SecurityGroups{$GroupsHierarchy{$ID}{Parent}}{NAME}; 
    $Child  = $SecurityGroups{$GroupsHierarchy{$ID}{Child}}{NAME}; 
    $Parent =~ tr/[A-Z]/[a-z]/;
    $Child  =~ tr/[A-Z]/[a-z]/;
    if ($Parent eq $remote_user) {
      foreach my $GroupID (@GroupIDs) { 
        my $ok_user = $SecurityGroups{$GroupID}{NAME};
           $ok_user =~ tr/[A-Z]/[a-z]/; 
        if ($ok_user eq $Child) {
          $access = 1;                           
        }  
      }
    }  
  }
  return $access;       
}

sub CanModify { # Can the user modify (with current security) this document
  require "DocumentSQL.pm";
  require "SecuritySQL.pm";

## FIXME: Use SecurityLookup  

  unless (keys %SecurityGroups) {
    &GetSecurityGroups;
  }  

  my ($DocumentID,$Version) = @_;
  my $CanModify;
  if     ($Public)      {return 0;} # Public version of code, can't modify 
  unless ($remote_user) {return 0;} # No user logged in, can't modify 

  &FetchDocument($DocumentID);
  unless (defined $Version) { # Last version is default  
    $Version = $Documents{$DocumentID}{NVersions};
  }   
  
  # In the enhanced security model, if no one is explictly listed as being 
  # able to modify the document, then anyone who can view it is allowed to.
  # This maintains backwards compatibility.
  
  my @ModifyGroupIDs;
  if ($EnhancedSecurity) {
    my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    @ModifyGroupIDs = &GetRevisionModifyGroups($DocRevID);
  } 
  if (@ModifyGroupIDs && $EnhancedSecurity) {
    foreach my $GroupID (@ModifyGroupIDs) { # Check auth. users vs. logged in user
      my $ok_user = $SecurityGroups{$GroupID}{NAME};
         $ok_user =~ tr/[A-Z]/[a-z]/; 
      if ($ok_user eq $remote_user) {
        $CanModify = 1;                           # User checks out
      }  
    }
    
    if (!$CanModify && $SuperiorsCanModify) { # We don't have a winner yet, but keep checking

# See if current users children can modify this document

      my @HierarchyIDs = keys %GroupsHierarchy;
      foreach $ID (@HierarchyIDs) {
        $Parent = $SecurityGroups{$GroupsHierarchy{$ID}{Parent}}{NAME}; 
        $Child  = $SecurityGroups{$GroupsHierarchy{$ID}{Child}}{NAME}; 
        $Parent =~ tr/[A-Z]/[a-z]/;
        $Child  =~ tr/[A-Z]/[a-z]/;
        if ($Parent eq $remote_user) {
          foreach my $GroupID (@ModifyGroupIDs) { 
            my $ok_user = $SecurityGroups{$GroupID}{NAME};
               $ok_user =~ tr/[A-Z]/[a-z]/; 
            if ($ok_user eq $Child) {
              $CanModify = 1;                           
            }  
          }
        }  
      }
    }
  } else {
    my $Access  = &CanAccess($DocumentID,$Version); 
    my $Create  = &CanCreate();
    $CanModify = $Access && $Create;
  } 
  return $CanModify;
}

sub CanCreate { # Can the user create documents 

  require "SecuritySQL.pm";

## FIXME: Use SecurityLookup  

  unless (keys %SecurityGroups) {
    &GetSecurityGroups;
  }  

  my $Create = 0;
  my @GroupIDs = keys %SecurityGroups; # FIXME use a hash for direct lookup
  foreach my $GroupID (@GroupIDs) { # Check auth. users vs. logged in user
    $OkUser = $SecurityGroups{$GroupID}{NAME};
    $OkUser =~ tr/[A-Z]/[a-z]/; 
    if ($OkUser eq $remote_user && $SecurityGroups{$GroupID}{CanCreate}) {
      $Create = 1;                           # User checks out
    }  
  }
  return $Create;
}

sub CanAdminister { # Can the user administer the database
## FIXME: Use SecurityLookup  
  require "SecuritySQL.pm";
  
  &GetSecurityGroups;
  my $Administer = 0;
  my @GroupIDs = keys %SecurityGroups; # FIXME use a hash for direct lookup
  foreach my $GroupID (@GroupIDs) { # Check auth. users vs. logged in user
    $OkUser = $SecurityGroups{$GroupID}{NAME};
    $OkUser =~ tr/[A-Z]/[a-z]/; 
    if ($OkUser eq $remote_user && $SecurityGroups{$GroupID}{CanAdminister}) {
      $Administer = 1;                           # User checks out
    }  
  }
  return $Administer;
}

# The Meeting security routines are very simple for the time being

sub CanAccessMeeting ($) {
  my ($ConferenceID) = @_;
  
#  print "CAM: $ConferenceID<br>\n";
  my $CanAccess = 0;
  
  unless ($Public) {
    $CanAccess = 1;
  }
  
  unless ($ConferenceID) {
    $CanAccess = 0;
  }
  
#  print "CA: $CanAccess<br>\n";
  return $CanAccess;
}

sub CanModifyMeeting ($) {
  my ($ConferenceID) = @_;
  
#  print "CMM: $ConferenceID<br>\n";
  
  my $CanModify = 0;
  
  if (&CanCreate && $ConferenceID) {
    $CanModify = 1;
  }
  
  if ($Public) {
    $CanModify = 0;
  }
  
  return $CanModify;
}  

sub CanCreateMeeting {

  my $CanCreate = 0;
  
  if (&CanCreate) {
    $CanCreate = 1;
  }
  
  if ($Public) {
    $CanCreate = 0;
  }
  
  return $CanCreate;
}  

sub LastAccess { # Highest version user can access (with current security)
  require "DocumentSQL.pm";
  my ($DocumentID) = @_;
  my $Version = -1;
  &FetchDocument($DocumentID);
  my $tryver = $Documents{$DocumentID}{NVersions};
  while ($Version == -1 && $tryver <=> -1) {
    if (&CanAccess($DocumentID,$tryver)) {$Version = $tryver;}
    --$tryver;
  }
  return $Version;    
}

1;
