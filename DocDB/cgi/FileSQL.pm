# FIXME: Should grab stuff from MiscSQL.pm

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

sub InsertFile (%) {
  my %Params = @_;
  
  my $DocRevID    = $Params{-docrevid}    || 0;  
  my $DateTime    = $Params{-datetime};    
  my $Filename    = $Params{-filename}    || "";  
  my $Main        = $Params{-main}        || 0;  
  my $Description = $Params{-description} || "";  

  unless ($DateTime) {
    my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
    $Year += 1900;
    ++$Mon;
    $DateTime = "$Year-$Mon-$Day $Hour:$Min:$Sec";
  } 
  
  my $Insert = $dbh -> prepare("insert into DocumentFile ".
     "(DocFileID, DocRevID, FileName, Date, RootFile, Description) ".
     "values (0,?,?,?,?,?)");
  
  $Insert -> execute($DocRevID,$Filename,$DateTime,$Main,$Description);
  my $FileID = $Insert -> {mysql_insertid}; # Works with MySQL only
  return $FileID;
}

sub DeleteFile (%) {
  my %Params = @_;
  
  my $FileID    = $Params{-fileid} || 0;
  
  if ($FileID) {
    my $Delete = $dbh -> prepare("delete from DocumentFile where DocFileID=?");
    $Delete -> execute($FileID);
  }
}
    
1;
