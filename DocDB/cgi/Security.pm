#
#        Name: Security.pm
# Description: Routines to determine various levels of access to documents
#              and the database based on usernames, doc numbers, etc.
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2017 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub CanAccess ($;$$) { # Can the user access (with current security) this version
  my ($DocumentID,$Version,$EmailUserID) = @_;

  require "RevisionSQL.pm";
  require "SecuritySQL.pm";

## FIXME: Allow -docrevid, or -docid and -version, same for other routines

  GetSecurityGroups();

  my $DocRevID = FetchRevisionByDocumentAndVersion($DocumentID,$Version);

  unless ($DocRevID) { # Document doesn't exist
    return 0;
  }
  if ($Documents{$DocumentID}{NVersions} eq "") { # Bad documents (no revisions)
    return 0;
  }

  my @GroupIDs = GetRevisionSecurityGroups($DocRevID);
  unless (@GroupIDs) {return 1;}             # Public documents

# See what group(s) current (or assumed) user belongs to

  my @UsersGroupIDs = ();

  if ($EmailUserID) {
    @UsersGroupIDs = FetchUserGroupIDs($EmailUserID);
  } else {
    @UsersGroupIDs = FindUsersGroups();
  }

# See if current user is in the list of groups who can access this document

  my $access = 0;
  foreach my $UserGroupID (@UsersGroupIDs) {
    unless ($SecurityGroups{$UserGroupID}{CanView}) {
      next;
    }

    foreach my $GroupID (@GroupIDs) {
      if ($UserGroupID == $GroupID) {
        $access = 1;                           # User checks out
        last;
      }
    }
  }
  if ($access) {return $access;}

# See if current users child groups can access this document

  my @HierarchyIDs = keys %GroupsHierarchy;
  foreach my $UserGroupID (@UsersGroupIDs) { # Groups user belongs to
    unless ($SecurityGroups{$UserGroupID}{CanView}) {
      next;
    }
    foreach my $ID (@HierarchyIDs) {         # All Hierarchy entries
      my $ParentID = $GroupsHierarchy{$ID}{Parent};
      my $ChildID  = $GroupsHierarchy{$ID}{Child};
      unless ($SecurityGroups{$ChildID}{CanView}) {
        next;
      }
      if ($ParentID == $UserGroupID) {    # We've found a valid "child" of one of our groups.
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
  require "RevisionSQL.pm";
  require "SecuritySQL.pm";

  GetSecurityGroups();
  my ($DocumentID,$Version) = @_;

  my $CanModify;
  if     ($Public)     {return 0;} # Public version of code, can't modify
  unless (CanCreate()) {return 0;} # User can't create documents, so can't modify

  FetchDocument($DocumentID);
  unless (defined $Version) { # Last version is default
    $Version = $Documents{$DocumentID}{NVersions};
  }

# See what group(s) current user belongs to

  my @UsersGroupIDs = FindUsersGroups();

  my @ModifyGroupIDs = ();
  if ($EnhancedSecurity) {
    my $DocRevID    = FetchRevisionByDocumentAndVersion($DocumentID,$Version);
    @ModifyGroupIDs = GetRevisionModifyGroups($DocRevID);
  }

  # In the enhanced security model, if no one is explictly listed as being
  # able to modify the document, then anyone who can view it is allowed to.
  # This maintains backwards compatibility with DB entries from before.

  if (@ModifyGroupIDs && $EnhancedSecurity) {
    foreach my $UsersGroupID (@UsersGroupIDs) {
      foreach my $GroupID (@ModifyGroupIDs) { # Check auth. users vs. logged in user
        if ($UsersGroupID == $GroupID && $SecurityGroups{$GroupID}{CanCreate}) {
          $CanModify = 1;                           # User checks out
          last;
        }
      }
    }

    if (!$CanModify && $SuperiorsCanModify) {    # We don't have a winner yet, but keep checking
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
    $CanModify = CanAccess($DocumentID,$Version);
  }
  return $CanModify;
}

sub CanCreate { # Can the user create documents
  require "SecuritySQL.pm";

  my $Create = 0;

  if ($Public || $ReadOnly) {
    return $Create;
  }

# See what group(s) current user belongs to

  my @UsersGroupIDs = FindUsersGroups();
  push @DebugStack,"User belongs to groups ".join ', ',@UsersGroupIDs;

  my @GroupIDs = keys %SecurityGroups; # FIXME use a hash for direct lookup
  foreach my $UserGroupID (@UsersGroupIDs) {
    FetchSecurityGroup($UserGroupID);
    if ($SecurityGroups{$UserGroupID}{CanCreate} && $SecurityGroups{$UserGroupID}{CanView}) {
      $Create = 1;                           # User checks out
    }
  }
  push @DebugStack,"User can create: $Create";
  return $Create;
}

sub GroupCan { # Could be used in above, but we need to know without $Public and
               # such if the specified user is allowed to create or view documents
  my ($ArgRef) = @_;
  my $GroupID = exists $ArgRef->{-groupid} ? $ArgRef->{-groupid} : 0;
  my $Action  = exists $ArgRef->{-action}  ? $ArgRef->{-action}  : "view";

  if ($Action eq "view") {
    return $SecurityGroups{$GroupID}{CanView};
  } elsif ($Action eq "create") {
    return $SecurityGroups{$GroupID}{CanCreate};
  }

  return $FALSE;
}

sub CanAdminister { # Can the user administer the database
  require "SecuritySQL.pm";

# See what group(s) current user belongs to

  my @UsersGroupIDs = &FindUsersGroups();

  my $Administer = 0;

  if ($Public || ($ReadOnly && !$ReadOnlyAdmin)) {
    return $Administer;
  }


  my @GroupIDs = keys %SecurityGroups; # FIXME use a hash for direct lookup
  foreach my $UserGroupID (@UsersGroupIDs) {
    &FetchSecurityGroup($UserGroupID);
    if ($SecurityGroups{$UserGroupID}{CanAdminister}) {
      $Administer = 1;                           # User checks out
    }
  }
  return $Administer;
}

sub CanPreserveSigs { # Can the user preserve signatures during document modifications?
  # FIXME: Currently a hack, will change in version 9
  require "SecuritySQL.pm";

  my ($Mode) = @_;

  # One group is allowed to preserve signoffs for document updates, the others only for metadata updates
  my @AllowedGroups = ();
  if ($Mode eq "update") {
    @AllowedGroups = @HackDocsPreserveSignoffGroups;
    push @AllowedGroups, @HackPreserveSignoffGroups;
  } else {
    @AllowedGroups = @HackPreserveSignoffGroups;
  }

  my $CanPreserveSigs = $FALSE;
  if ($Public || $ReadOnly) {
    return $CanPreserveSigs;
  }
  my @UsersGroupIDs = FindUsersGroups();

  foreach my $UserGroupID (@UsersGroupIDs) {
    FetchSecurityGroup($UserGroupID);
    foreach my $PreserveName (@AllowedGroups) {
      if ($PreserveName eq $SecurityGroups{$UserGroupID}{NAME}) {
        $CanPreserveSigs = $TRUE; # User checks out
      }
    }
  }
  return $CanPreserveSigs;
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

sub FindUsersGroups (;%) {
  require "Utilities.pm";
  require "Cookies.pm";

  my (%Params) = @_;
  my $IgnoreCookie = $Params{-ignorecookie} || $FALSE;

  my @UsersGroupIDs  = ();
  if ($UserValidation eq "certificate") {
    require "CertificateUtilities.pm";
    @UsersGroupIDs = &FetchSecurityGroupsByCert();
  } elsif ($UserValidation eq "shibboleth") {
    require "ShibbolethUtilities.pm";
    @UsersGroupIDs = FetchSecurityGroupsForShib();
  } elsif ($UserValidation eq "FNALSSO") {
    require "FNALSSOUtilities.pm";
    @UsersGroupIDs = FetchSecurityGroupsForFSSO();
  } elsif ($UserValidation eq "basic-user") {
    # Coming (maybe)
  } else {
    @UsersGroupIDs = (&FetchSecurityGroupByName ($remote_user));
  }

  push @DebugStack,"Before limiting, user belongs to groups ".join ', ',@UsersGroupIDs;

  unless (@UsersGroupIDs) {
    $Public = 1;
  }

  @UsersGroupIDs = &Unique(@UsersGroupIDs);

  unless ($IgnoreCookie) {
    my @LimitedGroupIDs = &GetGroupsCookie();
    if (@LimitedGroupIDs) {
      @UsersGroupIDs = &Union(\@LimitedGroupIDs,@UsersGroupIDs);
    }
  }
  
  push @DebugStack,"After limiting, user belongs to unique groups ".join ', ',@UsersGroupIDs;
  return @UsersGroupIDs;
}

sub FetchEmailUserID (;%) {
  my %Params = @_;

  my $EmailUserID;
  if ($UserValidation eq "certificate") {
    require "CertificateUtilities.pm";
    $EmailUserID  = FetchEmailUserIDByCert(%Params);
  } elsif ($UserValidation eq "shibboleth") {
    require "ShibbolethUtilities.pm";
    $EmailUserID  = FetchEmailUserIDForShib(%Params);
  } elsif ($UserValidation eq "FNALSSO") {
    require "FNALSSOUtilities.pm";
    $EmailUserID  = FetchEmailUserIDForFSSO();
  }

  return $EmailUserID;
}

1;
