
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

# The %Files hash has the following possible fields:

#  Filename    -- The name of the file, already on the file system to be inserted
#  File        -- Contains file handle from CGI
#  CopyFileID  -- Copy physical file from a previous version
#  FileID      -- Duplicate file id entry from a previous version
#  URL         -- URL of the file  
#  Pass        -- Password for wget 
#  User        -- Username for wget 
#  Description -- Description of the file
#  Main        -- Boolean, is it a "main" file

sub AddFiles (%) {
  require "FileSQL.pm";
  require "FSUtilities.pm";
  
  my %Params = @_;
  
  my $DocRevID   = $Params{-docrevid};   
  my $DateTime   = $Params{-datetime}; 
  my $ReplaceOld = $Params{-replaceold}; # Replace files of the same name  
  my $OldVersion = $Params{-oldversion}; # For copying files from old version  

  my %Files = %{$Params{-files}};
  
  push @DebugStack,"Adding files for DRI $DocRevID";
  
  my @FileIDs = (); my $FileID;
  unless ($DocRevID) {
    return @FileIDs;
  }  

  my @Files = sort keys %Files;
  
  &FetchDocRevisionByID($DocRevID);
  my $Version    = $DocRevisions{$DocRevID}{Version};
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  &MakeDirectory($DocumentID,$Version); 
  my $Directory = &GetDirectory($DocumentID,$Version); 

  foreach my $File (@Files) {
    my $ShortName = "";
    if ($Files{$File}{Filename} && (-e $Files{$File}{Filename})) {
      my @Parts = split /\//,$Files{$File}{Filename};
      $ShortName = pop @Parts;
      system ("cp",$Files{$File}{Filename},$Directory);
    } elsif ($Files{$File}{File}) {
      push @DebugStack,"Trying to upload $File $Files{$File}{File} Main: $Files{$File}{Main}";
      $ShortName = &ProcessUpload($Directory,$Files{$File}{File});
    } elsif ($Files{$File}{CopyFileID}) {
      push @DebugStack,"Trying to copy $File $Files{$File}{CopyFileID} Main: $Files{$File}{Main}";
      $ShortName = &FetchFile($Files{$File}{CopyFileID});
      &CopyFile($Directory,$ShortName,$DocumentID,$OldVersion);
    } elsif ($Files{$File}{FileID}) {
      push @DebugStack,"Trying to duplicate $File $Files{$File}{CopyFileID} Main: $Files{$File}{Main}";
      my $OldFileID = $Files{$File}{FileID};
      &FetchFile($OldFileID);
      $ShortName = $DocFiles{$OldFileID}{Name};
      $DateTime  = $DocFiles{$OldFileID}{Date};
    } # else other methods
    
    if ($ReplaceOld && $ShortName) {
      my $OldFileID = &ExistsFile($DocRevID,$ShortName);
      &DeleteFile(-fileid => $OldFileID);
    }
      
    if ($ShortName) {
      $FileID = &InsertFile(-docrevid    => $DocRevID, -datetime => $DateTime,
                            -filename    => $ShortName,
                            -main        => $Files{$File}{Main},
                            -description => $Files{$File}{Description});
      push @FileIDs,$FileID;
    }  
  } 
  return @FileIDs;   
}

sub AddArchive (%) {
  require "FileSQL.pm";
  require "FSUtilities.pm";
  
  my %Params = @_;
  
  my $DocRevID = $Params{-docrevid};   
  my $DateTime = $Params{-datetime}; 

  my %Archive = %{$Params{-archive}};

  push @DebugStack,"Adding archive for DRI $DocRevID";
  
  my @FileIDs = (); my $FileID;
  unless ($DocRevID) {
    return @FileIDs;
  }  

  &FetchDocRevisionByID($DocRevID);
  my $Version    = $DocRevisions{$DocRevID}{Version};
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  &MakeDirectory($DocumentID,$Version); 
  my $Directory = &GetDirectory($DocumentID,$Version); 

  $ShortName = &ProcessUpload($Directory,$Archive{File});
  my $Status = &ExtractArchive($Directory,$ShortName); # FIXME No status yet
  if ($ShortName) {
    $FileID = &InsertFile(-docrevid    => $DocRevID, -datetime => $DateTime,
                          -filename    => $ShortName,
                          -main        => 0,
                          -description => "Document Archive");
    push @FileIDs,$FileID;
    if (-s "$Directory/$Archive{MainFile}") {
      $FileID = &InsertFile(-docrevid    => $DocRevID, -datetime => $DateTime,
                            -filename    => $Archive{MainFile},
                            -main        => 1,
                            -description => $Archive{Description});
      push @FileIDs,$FileID;
    } else {
      push @WarnStack,"The main file $main_file did not exist or was blank.";
    }  
  } 
  return @FileIDs; 
}

1;
