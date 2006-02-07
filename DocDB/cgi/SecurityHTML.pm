#
#        Name: SecurityHTML.pm
# Description: Routines which supply HTML and form elements related to security
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

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
  require "Sorts.pm";
  require "Scripts.pm";
  require "FormElements.pm";
  
  my (%Params) = @_;
  
  my $AddPublic =   $Params{-addpublic} || $FALSE;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Groups";
  my $Multiple  =   $Params{-multiple}; 
  my $Name      =   $Params{-name}      || "groups";
  my $Format    =   $Params{-format}    || "short";
  my $Size      =   $Params{-size}      || 10;
  my $Disabled  =   $Params{-disabled}  || $FALSE;
  my @GroupIDs  = @{$Params{-groupids}};
  my @Default   = @{$Params{-default}};

  my %Options = ();
 
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }  

  &GetSecurityGroups;
  
  unless (@GroupIDs) {
    @GroupIDs = keys %SecurityGroups;
  }
    
  my %GroupLabels = ();

  foreach my $GroupID (@GroupIDs) {
    $GroupLabels{$GroupID} = $SecurityGroups{$GroupID}{NAME};
    if ($Format eq "full") {
      $GroupLabels{$GroupID} .= " [".$SecurityGroups{$GroupID}{Description}."]";
    }
  }  
  
  if ($AddPublic) { # Add dummy security code for "Public"
    my $ID = 0; 
    push @GroupIDs,$ID; 
    $GroupLabels{$ID} = "Public";
  }
      
  @GroupIDs = sort numerically @GroupIDs;

  if ($HelpLink) {  
    my $BoxTitle = &FormElementTitle(-helplink => $HelpLink, -helptext => $HelpText);
    print $BoxTitle;
  }
  
  print $query -> scrolling_list(-name => $Name, -values => \@GroupIDs, 
                                 -labels => \%GroupLabels, 
                                 -size => $Size, -multiple => $Multiple,
                                 -default => \@Default, %Options);
};

sub SecurityListByID {
  my (@GroupIDs) = @_;
  
  print "<div id=\"Viewable\">\n";
  if ($EnhancedSecurity) {
    print "<b>Viewable by:</b><br/>\n";
  } else {  
    print "<b>Accessible by:</b><br/>\n";
  }  
  
  print "<ul>\n";
  if (@GroupIDs) {
    foreach $GroupID (@GroupIDs) {
      print "<li>$SecurityGroups{$GroupID}{NAME}</li>\n";
    }
  } else {
    print "<li>Public document</li>\n";
  }
  print "</ul>\n";
  print "</div>\n";
}

sub ModifyListByID {
  my (@GroupIDs) = @_;
  
  unless ($EnhancedSecurity) {
    return;
  }
    
  print "<div id=\"Modifiable\">\n";
  print "<b>Modifiable by:</b><br/>\n";
  print "<ul>\n";
  if (@GroupIDs) {
    foreach $GroupID (@GroupIDs) {
      print "<li>$SecurityGroups{$GroupID}{NAME}</li>\n";
    }
  } else {
    print "<li>Same as Viewable by</li>\n";
  }
  print "</ul>\n";
  print "</div>\n";
}

sub PersonalAccountLink () {
  my $PersonalAccountLink = "<a href=\"$EmailLogin\">Your Account</a>";
  if ($UserValidation eq "certificate") {
    require "CertificateUtilities.pm";
    my $CertificateStatus = &CertificateStatus();
    if ($CertificateStatus eq "verified") {
      $PersonalAccountLink = "<a href=\"$SelectEmailPrefs\">Your Account</a>";
    } else {
      $PersonalAccountLink = "";
    }
  }
  if ($Public) {
    $PersonalAccountLink = "";
  }
  return $PersonalAccountLink;
}

1;
