#
#        Name: SecurityHTML.pm
# Description: Routines which supply HTML and form elements related to security
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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

sub SecurityScroll (%) {
  require "SecuritySQL.pm";
  
  my (%Params) = @_;
  
  my $AddPublic =   $Params{-addpublic} || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Groups";
  my $Multiple  =   $Params{-multiple}; # FIXME: May not be able to set false
  my $Name      =   $Params{-name}      || "groups";
  my $Size      =   $Params{-size}      || 10;
  my $Disabled  =   $Params{-disabled}  || "0";
  my @Default   = @{$Params{-default}};

  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  &GetSecurityGroups;
  
  my @GroupIDs = keys %SecurityGroups;
  my %GroupLabels = ();

  foreach my $GroupID (@GroupIDs) {
    $GroupLabels{$GroupID} = $SecurityGroups{$GroupID}{NAME};
  }  
  
  if ($AddPublic) { # Add dummy security code for "Public"
    my $ID = 0; 
    push @GroupIDs,$ID; 
    $GroupLabels{$ID} = "Public";
  }
      
  @GroupIDs = sort numerically @GroupIDs;

  if ($HelpLink) {
    print "<b><a ";
    &HelpLink($HelpLink);
    print "$HelpText:</a></b><br> \n";
  }
  
  print $query -> scrolling_list(-name => $Name, -values => \@GroupIDs, 
                                 -labels => \%GroupLabels, 
                                 -size => $Size, -multiple => $Multiple, 
                                 -default => \@Default, $Booleans);
};

1;
