#
# Description: Routines to deal with documents
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

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

sub AddDocument {
  require "DocumentSQL.pm";
  my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);

  my %Params = @_;
  
  my $Title       = $Params{-title}       || "";
  my $Abstract    = $Params{-abstract}    || "";
  my $Keywords    = $Params{-keywords}    || "";
  my $TypeID      = $Params{-typeid}      || 0;
  my $RequesterID = $Params{-requesterid} || 0;
  my $Note        = $Params{-note}        || "";
  my $PubInfo     = $Params{-pubinfo}     || "";
  my $DateTime    = $Params{-datetime}    || "$Year-$Mon-$Day $Hour:$Min:$Sec";
  
  my @AuthorIDs = @{$Params{-authorids}};
  my @TopicIDs  = @{$Params{-topicids}};
  my @ViewIDs   = @{$Params{-viewids}};
  my @ModifyIDs = @{$Params{-modifyids}};
  
  my %Files      = %{$Params{-files}};
  my %References = %{$Params{-references}};
  my %Signoffs   = %{$Params{-signoffs}};

  

}

1;
