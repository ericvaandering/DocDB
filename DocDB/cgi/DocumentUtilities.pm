#
# Description: Routines to deal with documents
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

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

sub AddDocument {
  require "FileUtilities.pm";
  require "FSUtilities.pm";

  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  require "TopicSQL.pm";
  require "AuthorSQL.pm";
  require "MeetingSQL.pm";
  require "SecuritySQL.pm";
  require "SignoffSQL.pm";
  
  my %Params = @_;
  
  my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);

  my $DocumentID    = $Params{-docid}         || 0;
  my $Title         = $Params{-title}         || "";
  my $Abstract      = $Params{-abstract}      || "";
  my $Keywords      = $Params{-keywords}      || "";
  my $TypeID        = $Params{-typeid}        || 0;
  my $RequesterID   = $Params{-requesterid}   || 0;
  my $Note          = $Params{-note}          || "";
  my $PubInfo       = $Params{-pubinfo}       || "";
  my $DateTime      = $Params{-datetime};
  my $SessionTalkID = $Params{-sessiontalkid} || 0; # Not used yet
  
  my @AuthorIDs  = @{$Params{-authorids}} ;
  my @TopicIDs   = @{$Params{-topicids}}  ;
  my @EventIDs   = @{$Params{-eventids}}  ;
  my @ViewIDs    = @{$Params{-viewids}}   ;
  my @ModifyIDs  = @{$Params{-modifyids}} ;
  my @SignOffIDs = @{$Params{-signoffids}}; # For simple signoff list, may be deprecated
  
  my %Files      = %{$Params{-files}};
  my %References = %{$Params{-references}}; # Not used yet
  my %Signoffs   = %{$Params{-signoffs}};   # Not used yet

  unless ($DateTime) {
    my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
    $Year += 1900;
    ++$Mon;
    $DateTime = "$Year-$Mon-$Day $Hour:$Min:$Sec";
  } 

  my ($DocRevID,$Count,@FileIDs);

  $DocumentID = &InsertDocument(
                 -docid    => $DocumentID, -requesterid => $RequesterID, 
                 -datetime => $DateTime);
                 
  if ($DocumentID) {                                 
    $DocRevID = &InsertRevision(
                 -docid       => $DocumentID,  -doctypeid => $TypeID, 
                 -submitterid => $RequesterID, -title     => $Title,
                 -pubinfo     => $PubInfo,     -abstract  => $Abstract,
                 -version     => 'bump',       -datetime  => $DateTime,
                 -keywords    => $Keywords,    -note      => $Note);

    # Deal with SessionTalkID

  }
  
  my $Count;
  if ($DocRevID) { 
    &FetchDocRevisionByID($DocRevID);
    my $Version    = $DocRevisions{$DocRevID}{Version};
    &MakeDirectory($DocumentID,$Version); 
    &ProtectDirectory($DocumentID,$Version,@ViewIDs); 
    $Count = &InsertAuthors(-docrevid   => $DocRevID, -authorids => \@AuthorIDs);
    $Count = &InsertTopics(-docrevid    => $DocRevID, -topicids  => \@TopicIDs);
    $Count = &InsertEvents(-docrevid    => $DocRevID, -eventids  => \@EventIDs);
    $Count = &InsertSecurity(-docrevid  => $DocRevID, -viewids   => \@ViewIDs, -modifyids => \@ModifyIDs);
    @FileIDs = &AddFiles(-docrevid  => $DocRevID, -datetime => $DateTime, -files => \%Files);
    if (@SignOffIDs) {
      &InsertSignoffList($DocRevID,@SignOffIDs);
    }  
  }
  
  return ($DocumentID,$DocRevID);                                 

}

1;
