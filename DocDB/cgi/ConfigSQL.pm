#
# Description: SQL routines related to configuration
#
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

# The config table has the following structure:

#  ConfigSettingID int(11) 
#  Project varchar(32) 
#  ConfigGroup varchar(64) 
#  Sub1Group varchar(64)
#  Sub2Group varchar(64)
#  Sub3Group varchar(64)
#  Sub4Group varchar(64)
#  ForeignID int(11)  
#  Value varchar(64)  
#  Sub1Value varchar(64)
#  Sub2Value varchar(64)
#  Sub3Value varchar(64)
#  Sub4Value varchar(64)
#  Sub5Value varchar(64)
#  Description text 
#  Constrained int(11)  
#  TimeStamp timestamp(14) 

sub InsertConfig (%) {
  my %Params = @_;
  
  my $Project     =   $Params{-project}     || "";   
  my $ConfigGroup =   $Params{-configgroup} || "";   
  my $Sub1Group   =   $Params{-sub1group}   || "";   
  my $Sub2Group   =   $Params{-sub2group}   || "";   
  my $Sub3Group   =   $Params{-sub3group}   || "";   
  my $Sub4Group   =   $Params{-sub4group}   || "";   
  my $ForeignID   =   $Params{-foreignid}   || "";   
  my $Value       =   $Params{-value}       || "";   
  my $Sub1Value   =   $Params{-sub1value}   || ""; 
  my $Sub2Value   =   $Params{-sub2value}   || ""; 
  my $Sub3Value   =   $Params{-sub3value}   || ""; 
  my $Sub4Value   =   $Params{-sub4value}   || ""; 
  my $Sub5Value   =   $Params{-sub5value}   || ""; 
  my $Description =   $Params{-description} || "";   
  my $Constrained =   $Params{-constrained} || "";   

  my $Insert = $dbh -> prepare("insert into ConfigSetting (ConfigSettingID, 
      Project, ConfigGroup, Sub1Group, Sub2Group, Sub3Group, Sub4Group,
      ForeignID, Value, Sub1Value, Sub2Value, Sub3Value, Sub4Value, Sub5Value,
      Description, Constrained) values (0,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
                                
  $Insert -> execute($Project,$ConfigGroup,$Sub1Group,$Sub2Group,$Sub3Group,
                     $Sub4Group,$ForeignID,$Value,$Sub1Value,$Sub2Value,
                     $Sub3Value,$Sub4Value,$Sub5Value,$Description,$Constrained);
                                 
  my $ConfigSettingID = $Insert -> {mysql_insertid};
  push @DebugStack,"ConfigSettingID  $ConfigSettingID ";   
  return $ConfigSettingID;
}

sub FetchCustomFieldList (%) {
  my %Params = (@_);
  
  my $Default      = $Params{-default}      || "";   
  my $EventID      = $Params{-eventid}      || 0;
  my $EventGroupID = $Params{-eventgroupid} || 0;
  my $TopicID      = $Params{-topicid}      || 0;
  my $DocTypeID    = $Params{-doctypeid}    || 0;

  # Add ones for topic, document type, and groups?

  my ($ForeignKey,$ForeignID);
  if ($Default) {
    $ForeignKey = $Default;
    $ForeignID  = 0;
  } elsif ($EventID) {
    $ForeignKey = "EventID";
    $ForeignID  = $EventID;
  } elsif ($EventGroupID) {
    $ForeignKey = "EventGroupID";
    $ForeignID  = $EventGroupID;
  } elsif ($TopicID) {
    $ForeignKey = "TopicID";
    $ForeignID  = $TopicID;
  } elsif ($DocTypeID) {
    $ForeignKey = "DocTypeID";
    $ForeignID  = $DocTypeID;
  }  

  my $List = $dbh->prepare("select
      Value,Sub1Value,Sub2Value,Sub3Value,Sub4Value from ConfigSetting 
      where Project=? and ConfigGroup='CustomField' and Sub1Group=? 
      and ForeignID=?");
  $List -> execute($ShortProject,$ForeignKey,$ForeignID);
  
  my ($Field,$Row,$Column,$RowSpan,$ColSpan);
  my %FieldList = ();
  
  $List -> bind_columns(undef, \($Field,$Row,$Column,$RowSpan,$ColSpan));
  while ($List -> fetch) {
    $FieldList{$Field}{Row}     = $Row;
    $FieldList{$Field}{Column}  = $Column;
    $FieldList{$Field}{RowSpan} = $RowSpan;
    $FieldList{$Field}{ColSpan} = $ColSpan;
  }

  return %FieldList;
}

sub InsertCustomFieldList {
  my %Params = (@_);
  
  my $Default      = $Params{-default}      || "";   
  my $TopicID      = $Params{-topicid}      || 0;
  my $EventID      = $Params{-eventid}      || 0;
  my $EventGroupID = $Params{-eventgroupid} || 0;
  my $DocTypeID    = $Params{-doctypeid}    || 0;
  my $Description  = $Params{-description}  || "";
  my %FieldList    = %{$Params{-fieldlist}}; 
  
  my ($ForeignKey,$ForeignID);
  if ($Default) {
    $ForeignKey = $Default;
    $ForeignID  = 0;
  } elsif ($TopicID) {
    $ForeignKey = "TopicID";
    $ForeignID  = $TopicID;
  } elsif ($EventID) {
    $ForeignKey = "EventID";
    $ForeignID  = $EventID;
  } elsif ($EventGroupID) {
    $ForeignKey = "EventGroupID";
    $ForeignID  = $EventGroupID;
  } elsif ($DocTypeID) {
    $ForeignKey = "DocTypeID";
    $ForeignID  = $DocTypeID;
  }  

  my $Delete = $dbh->prepare("delete from ConfigSetting 
      where Project=? and ConfigGroup='CustomField' and Sub1Group=? 
      and ForeignID=?");
  $Delete -> execute($ShortProject,$ForeignKey,$ForeignID);
  my $Count = 0;
  foreach my $Field (keys %FieldList ) {
    InsertConfig(-project     => $ShortProject, -configgroup => "CustomField",
                 -sub1group   => $ForeignKey,   -foreignid   => $ForeignID, 
                 -value       => $Field, 
                 -sub1value   => $FieldList{$Field}{Row}, 
                 -sub2value   => $FieldList{$Field}{Column},  
                 -sub3value   => $FieldList{$Field}{RowSpan},
                 -sub4value   => $FieldList{$Field}{ColSpan}, 
                 -description => $Description);
    ++$Count;
  }
  return $Count;
}

1;
