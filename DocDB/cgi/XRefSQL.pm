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
  my @Documents   = @{$Params{-documents}};
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
  
  foreach my $Document (@Documents) {
    my $ExtProject = "";
    my $Version    = 0;
    my $DocID      = 0; 
    my @Parts = split /\-/,$Document;
    foreach my $Part (@Parts) {
      if (grep /^v\d$/,$Part) {
        $Version = $Part;
        $Version =~ s/v//;
      } elsif (grep /^\d+$/,$Part) {
        $DocID = $Part;
      } else {
        $ExtProject = $Part;
      }
    }
    
    my $DocXRefID = 0;
    if ($DocID) {
      $Insert -> execute($DocRevID,$DocID);
      $DocXRefID = $Insert -> {mysql_insertid};
    }
    if ($DocXRefID && $Version) {
      my $Update = $dbh -> prepare("update DocXRef set Version=? where DocXRefID=?");
      $Update -> execute($Version,$DocXRefID);
    }  
    if ($DocXRefID && $ExtProject) {
      my $Update = $dbh -> prepare("update DocXRef set Project=? where DocXRefID=?");
      $Update -> execute($ExtProject,$DocXRefID);
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
    $List = $dbh -> prepare("select DocXRefID,DocRevID,DocumentID,Project,Version,TimeStamp ".
             "from DocXRef where DocRevID=?");
    $List -> execute($DocRevID);  
  } elsif ($DocumentID) {
    $List = $dbh -> prepare("select DocXRef.DocXRefID,DocXRef.DocRevID,DocXRef.DocumentID,".
             "DocXRef.Project,DocXRef.Version,DocXRef.TimeStamp ".
             "from DocXRef,DocumentRevision where DocXRef.DocumentID=? and ".
             "DocumentRevision.DocRevID=DocXRef.DocRevID and DocumentRevision.Obsolete=0");
    $List -> execute($DocumentID);  
  }        
  if ($List) {
    my ($DocXRefID,$DocRevID,$DocumentID,$ExtProject,$Version,$TimeStamp);
    $List-> bind_columns(undef, \($DocXRefID,$DocRevID,$DocumentID,$ExtProject,$Version,$TimeStamp));

    while ($List -> fetch) {
      push @DocXRefIDs,$DocXRefID;
      $DocXRefs{$DocXRefID}{DocRevID}   = $DocRevID;
      $DocXRefs{$DocXRefID}{DocumentID} = $DocumentID;
      $DocXRefs{$DocXRefID}{Project}    = $ExtProject;
      $DocXRefs{$DocXRefID}{Version}    = $Version;
      $DocXRefs{$DocXRefID}{TimeStamp}  = $TimeStamp;
    }
  }
   
  return @DocXRefIDs;
}  

1;
