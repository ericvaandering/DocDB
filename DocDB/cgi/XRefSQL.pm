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
      push @DebugStack,"Checking part $Part";
      if (grep /^v\d+$/,$Part) {
        $Version = $Part;
        $Version =~ s/v//;
        push @DebugStack,"Set version $Version";
      } elsif (int($Part) && !$DocID) { # Only take first one as DocID
        $DocID = $Part;
        push @DebugStack,"Set docid $DocID";
      } else {
        $ExtProject = $Part;
        push @DebugStack,"Set project $ExtProject";
      }
    }
    
    if (!$ExtProject || $ExtProject eq $ShortProject) { # Check if it exists
      my $OK = 0;
      if ($DocRevID && $DocID && $Version) {
        unless (&FetchRevisionByDocumentAndVersion($DocID,$Version)) {
          push @WarnStack,"Document $DocID, version $Version does not exist. No cross-reference created.";
          next;
        }
        $OK = 1;
      } elsif ($DocRevID && $DocID && &FetchDocument($DocID)) {
        $OK = 1;
      } else {
        push @WarnStack,"Unable to Cross-reference to $Document: Does not exist or format is not 1234-v56";
        next;
      }  
    }          
    
    my $DocXRefID = 0;
    if ($DocID) {
      $Insert -> execute($DocRevID,$DocID);
      $DocXRefID = $Insert -> {mysql_insertid};
    }
    push @DebugStack,"DXI: $DocXRefID V: $Version EP: $ExtProject";
    if ($DocXRefID && $Version) {
      push @DebugStack,"Add V: $Version";
      my $Update = $dbh -> prepare("update DocXRef set Version=? where DocXRefID=?");
      $Update -> execute($Version,$DocXRefID);
    }  
    if ($DocXRefID && $ExtProject) {
      push @DebugStack,"Add EP: $ExtProject";
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

sub GetAllExternalDocDBs () {
  if ($HaveAllExternalDocDBs) {
    my @ExternalDocDBIDs = keys %ExternalDocDBs;
    return @ExternalDocDBIDs;
  }
  my @ExternalDocDBIDs = (); 
  my ($ExternalDocDBID);
  
  my $List = $dbh -> prepare("select ExternalDocDBID from ExternalDocDB");
  $List -> execute();  
  $List-> bind_columns(undef, \($ExternalDocDBID));
  while ($List -> fetch) {
    my $ID = FetchExternalDocDB($ExternalDocDBID);
    push @ExternalDocDBIDs,$ID;
  }
  $HaveAllExternalDocDBs = $TRUE;
  return @ExternalDocDBIDs;
}

sub FetchExternalDocDB ($) {
  my ($ExternalDocDBID) = @_;
  unless ($ExternalDocDBID) {
    return;
  }

  my $Fetch = $dbh->prepare("select Project,Description,PrivateURL,PublicURL,TimeStamp from ExternalDocDB where ExternalDocDBID=?");
  $Fetch -> execute($ExternalDocDBID);

  my ($Project,$Description,$PrivateURL,$PublicURL,$TimeStamp) = $Fetch -> fetchrow_array;
  if ($TimeStamp) {
    $ExternalDocDBs{$EventGroupID}{Project}     = $Project;
    $ExternalDocDBs{$EventGroupID}{Description} = $Description;
    $ExternalDocDBs{$EventGroupID}{PrivateURL}  = $PrivateURL;
    $ExternalDocDBs{$EventGroupID}{PublicURL}   = $PublicURL; 
    $ExternalDocDBs{$EventGroupID}{TimeStamp}   = $TimeStamp;
    return $ExternalDocDBID;
  } else {
    return;
  }  
}

sub FetchExternalDocDBByName ($) {
  my ($Name) = @_;
  unless ($Name) {
    return;
  }

  my $Fetch = $dbh->prepare("select ExternalDocDBID from ExternalDocDB where Project=?");
  $Fetch -> execute($Name);

  my ($ExternalDocDBID) = $Fetch -> fetchrow_array;
  if ($ExternalDocDBID) {
    my $ExternalDocDBID = FetchExternalDocDB($ExternalDocDBID);
    return $ExternalDocDBID;
  } else {
    return;
  }  
}
1;
