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
  my ($DocumentID,$Version) = @_;

  require "RevisionSQL.pm";
  require "SecuritySQL.pm";
  
  my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
  
  unless ($DocRevID) { # Document doesn't exist
    return 0;
  }
  if ($Documents{$DocumentID}{NVersions} eq "") { # Bad documents (no revisions)
    return 0;
  } 
  
  my @GroupIDs = &GetRevisionSecurityGroups($DocRevID);
  unless (@GroupIDs) {return 1;}             # Public documents

# See what group(s) current user belongs to

  my @UsersGroupIDs = &FindUsersGroups();
    
# See if current user is in the list of groups who can access this document

  my $access = 0;
  foreach my $UserGroupID (@UsersGroupIDs) {
    foreach my $GroupID (@GroupIDs) { 
      if ($UserGroupID == $GroupID) {
        $access = 1;                           # User checks out
        last;
      }  
    }
  }
  if ($access) {return $access;}

# See if current users child groups can access this document

  &GetSecurityGroups(); # Pull out the big guns
  my @HierarchyIDs = keys %GroupsHierarchy;
  foreach my $UserGroupID (@UsersGroupIDs) { # Groups user belongs to
    foreach my $ID (@HierarchyIDs) {         # All Hierarchy entries
      my $ParentID = $GroupsHierarchy{$ID}{Parent}; 
      my $ChildID  = $GroupsHierarchy{$ID}{Child}; 
      if ($ParentID == $UserGroupID) {    # We've found a "child" of one of our groups.   
        foreach my $GroupID (@GroupIDs) { # See if the child can access the document
          if ($GroupID == $ChildID) {
            $access = 1;
            last;                           
          }   
        }
      }  
    }
  }
  return $access;       
}

sub CanModify { # Can the user modify (with current security) this document
  require "DocumentSQL.pm";
  require "SecuritySQL.pm";

  my ($DocumentID,$Version) = @_;

  my $CanModify;
  if     ($Public)      {return 0;} # Public version of code, can't modify 
  unless (&CanCreate()) {return 0;} # User can't create documents, so can't modify
  
  &FetchDocument($DocumentID);
  unless (defined $Version) { # Last version is default  
    $Version = $Documents{$DocumentID}{NVersions};
  }   
  
# See what group(s) current user belongs to

  my @UsersGroupIDs = &FindUsersGroups();
    
  my @ModifyGroupIDs = ();
  if ($EnhancedSecurity) {
    my $DocRevID    = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    @ModifyGroupIDs = &GetRevisionModifyGroups($DocRevID);
  } 
  
  # In the enhanced security model, if no one is explictly listed as being 
  # able to modify the document, then anyone who can view it is allowed to.
  # This maintains backwards compatibility with DB entries from before.
  
  if (@ModifyGroupIDs && $EnhancedSecurity) {
    foreach my $UsersGroupID (@UsersGroupIDs) {
      foreach my $GroupID (@ModifyGroupIDs) { # Check auth. users vs. logged in user
        if ($UsersGroupID == $GroupID) {
          $CanModify = 1;                           # User checks out
          last;
        }  
      }  
    }
    
    if (!$CanModify && $SuperiorsCanModify) {    # We don't have a winner yet, but keep checking
      &GetSecurityGroups(); # Pull out the big guns
      my @HierarchyIDs = keys %GroupsHierarchy;  # See if current users children can modify this document
      foreach my $UserGroupID (@UsersGroupIDs) { # Groups user belongs to
        foreach my $ID (@HierarchyIDs) {         # All Hierarchy entries
          my $ParentID = $GroupsHierarchy{$ID}{Parent}; 
          my $ChildID  = $GroupsHierarchy{$ID}{Child}; 
          if ($ParentID == $UserGroupID) {          # We've found a "child" of one of our groups.   
            foreach my $GroupID (@ModifyGroupIDs) { # See if the child can access the document
              if ($GroupID == $ChildID) {
                $CanModify = 1;        
                last;                   
              }  
            }
          }
        }    
      }
    }
  } else { # No entries in the modify table or we're not using seperate view/modify lists 
    $CanModify = &CanAccess($DocumentID,$Version); 
  } 
  return $CanModify;
}

sub CanCreate { # Can the user create documents 
  require "SecuritySQL.pm";

# See what group(s) current user belongs to

  my @UsersGroupIDs = &FindUsersGroups();

  my $Create = 0;
  my @GroupIDs = keys %SecurityGroups; # FIXME use a hash for direct lookup
  foreach my $UserGroupID (@UsersGroupIDs) {
    foreach my $GroupID (@GroupIDs) { # Check auth. users vs. logged in user
      &FetchSecurityGroup($GroupID);
      if ($UserGroupID == $GroupID && $SecurityGroups{$GroupID}{CanCreate}) {
        $Create = 1;                           # User checks out
      }  
    }  
  }
  return $Create;
}

sub CanAdminister { # Can the user administer the database
  require "SecuritySQL.pm";
  
# See what group(s) current user belongs to

  my @UsersGroupIDs = &FindUsersGroups();

  my $Administer = 0;
  my @GroupIDs = keys %SecurityGroups; # FIXME use a hash for direct lookup
  foreach my $UserGroupID (@UsersGroupIDs) {
    foreach my $GroupID (@GroupIDs) { # Check auth. users vs. logged in user
      &FetchSecurityGroup($GroupID);
      if ($UserGroupID == $GroupID && $SecurityGroups{$GroupID}{CanAdminister}) {
        $Administer = 1;                           # User checks out
      }  
    }  
  }
  return $Administer;
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

sub FindUsersGroups () {
  my @UsersGroupIDs  = ();
  if ($UserValidation eq "certificate") {
    require "CertificateUtilities.pm";
    @UserGroupIDs = &FetchSecurityGroupsByCert();
  } elsif ($UserValidation eq "basic-user") {
# Coming (maybe)
  } else {
    @UsersGroupIDs = (&FetchSecurityGroupByName ($remote_user));
  }
  return @UsersGroupIDs;
}

1;
