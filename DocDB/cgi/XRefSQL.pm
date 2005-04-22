#
# Description: SQL routines related to cross-referencing documents
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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

sub InsertXRefs (%) {
  require "DocumentSQL.pm";
  my %Params = @_;
  
  my $DocRevID    =   $Params{-docrevid} || 0;   
  my @DocumentIDs = @{$Params{-docids}};

  my $Count = 0;

  my $Insert = $dbh -> prepare("insert into DocXRef (DocXRefID, DocRevID, DocumentID) values (0,?,?)");
                                 
  foreach my $DocID (@DocumentIDs) {
    if (&FetchDocument($DocID) && $DocRevID) {
      $Insert -> execute($DocRevID,$DocID);
      ++$Count;
    } else {
      require "ResponseElements.pm";
      my $DocumentString = &FullDocumentID($DocID);
      push @WarnStack,"Unable to Cross-reference to $DocumentString: Does not exist";
    }  
  }  
      
  return $Count;
}

sub FetchXRefs (%) { # For now, no single version
  my %Params = (@_);
  
  my $DocRevID   = $Params{-docrevid} || 0;   
  my $DocumentID = $Params{-docid}    || 0;
  
  my @DocXRefIDs = ();
     %DocXRefs   = ();
  
  my $List;

  if ($DocRevID) {
    $List = $dbh -> prepare("select DocXRefID,DocRevID,DocumentID,TimeStamp ".
             "from DocXRef where DocRevID=?");
    $List -> execute($DocRevID);  
  } elsif ($DocumentID) {
    $List = $dbh -> prepare("select DocXRef.DocXRefID,DocXRef.DocRevID,DocXRef.DocumentID,DocXRef.TimeStamp ".
             "from DocXRef,DocumentRevision where DocXRef.DocumentID=? and ".
             "DocumentRevision.DocumentID=DocXRef.DocumentID and DocumentRevision.Obsolete=0");
    $List -> execute($DocumentID);  
  }        
  if ($List) {
    my ($DocXRefID,$DocRevID,$DocumentID,$TimeStamp);
    $List-> bind_columns(undef, \($DocXRefID,$DocRevID,$DocumentID,$TimeStamp));

    while ($List -> fetch) {
      push @DocXRefIDs,$DocXRefID;
      $DocXRefs{$DocXRefID}{DocRevID}   = $DocRevID;
      $DocXRefs{$DocXRefID}{DocumentID} = $DocumentID;
      $DocXRefs{$DocXRefID}{TimeStamp}  = $TimeStamp;
    }
  }
   
  return @DocXRefIDs;
}  

1;
