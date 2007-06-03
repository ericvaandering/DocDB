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

sub AllRootTopics {
  require "TopicSQL.pm";

  GetTopics();
  
  my @TopicIDs = keys %Topics;
  my @RootIDs  = ();
  
  foreach my $TopicID (@TopicIDs) {
    unless (@{$TopicParents{$TopicID}}) {
      push @RootIDs,$TopicID;
    }  
  }
  
  return @RootIDs;
}

sub TopicAndSubTopics {
  my ($ArgRef) = @_;
  my $TopicID = exists $ArgRef->{-topicid} ? $ArgRef->{-topicid} : 0;
  
  require "TopicSQL.pm";
  require "Utilities.pm";

  GetTopics();
  
  my @TopicIDs = ($TopicID);
  
  foreach my $ChildID (@{$TopicChildren{$TopicID}}) {
    my @ChildIDs = TopicAndSubTopics({ -topicid => $ChildID });
    push @TopicIDs,@ChildIDs;
  }
  
  return Unique(@TopicIDs);  
}

sub BuildTopicProvenance {
  %TopicProvenance = ();
  
  # When finished, @{$TopicProvenance{$TopicID}} is an array for every $TopicID, 
  # which has that TopicID as its first element, its parent as its second, 
  # grandparent as the third, etc.
  
  foreach my $TopicID (keys %Topics) {
    push @{$TopicProvenance{$TopicID}},$TopicID;
  }
  
  # Check each provenance entry to see if we can append to the list
  # FIXME: Cannot deal with multiple parents.
  
  my $Found = $TRUE;
  while ($Found) {
    $Found = $FALSE;
    foreach my $TopicID (keys %Topics) {
      my @IDs = @{$TopicProvenance{$TopicID}};
      my $LastID = pop @IDs;
      if (@{$TopicParents{$LastID}}) {
        $Found = $TRUE;
        my @ParentIDs = @{$TopicParents{$LastID}};
        my $FirstParentID = pop @ParentIDs;
        push @{$TopicProvenance{$TopicID}},$FirstParentID;
      }  
    }
  }
  
  return;
}

1;
