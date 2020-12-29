#
#        Name: SecurityHTML.pm
# Description: Routines which supply HTML and form elements related to security
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:

# Copyright 2001-2018 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub SecurityScroll (%) {
  require "SecuritySQL.pm";
  require "Sorts.pm";
  require "Scripts.pm";
  require "FormElements.pm";
  require "HTMLUtilities.pm";

  my (%Params) = @_;

  my $AddPublic =   $Params{-addpublic} || $FALSE;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Groups";
  my $Multiple  =   $Params{-multiple};
  my $Name      =   $Params{-name}      || "groups";
  my $Format    =   $Params{-format}    || "short";
  my $Size      =   $Params{-size}      || 10;
  my $Disabled  =   $Params{-disabled}  || $FALSE;
  my $Permission=   $Params{-permission}|| "";
  my @GroupIDs  = @{$Params{-groupids}};
  my @Default   = @{$Params{-default}};

  my %Options = ();

  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }

  &GetSecurityGroups;

  unless (@GroupIDs) {
    if($Permission){
      @GroupIDs = ();
      foreach my $ID (keys %SecurityGroups) {
        if($SecurityGroups{$ID}{$Permission}){
          push @GroupIDs,$ID;
        }
      }
    }
    else{
      @GroupIDs = keys %SecurityGroups;
    }
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
      print "<li>",SecurityLink({ -groupid => $GroupID, -check => "view", }),"</li>\n";
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
      print "<li>",SecurityLink( {-groupid => $GroupID, -check => "create", } ),"</li>\n";
    }
  } else {
    print "<li>Same as Viewable by</li>\n";
  }
  print "</ul>\n";
  print "</div>\n";
}

sub PersonalAccountLink () {
  my $PersonalAccountLink = "<a href=\"$EmailLogin\">Your Account</a>";
  if ($UserValidation eq "shibboleth" || $UserValidation eq "FNALSSO") {
    $PersonalAccountLink = "<a href=\"$SelectEmailPrefs\">Your Account</a>";
  } elsif ($UserValidation eq "certificate") {
    require "CertificateUtilities.pm";
    my $CertificateStatus = &CertificateStatus();
    if ($CertificateStatus eq "verified") {
      $PersonalAccountLink = "<a href=\"$SelectEmailPrefs\">Your Account</a>";
    } else {
      $PersonalAccountLink = "";
    }
  }

  if ($Public && $UserValidation ne "FNALSSO") {
    $PersonalAccountLink = "";
  }
  return $PersonalAccountLink;
}

sub SecurityLink ($) {
  my ($ArgRef) = @_;
  my $GroupID = exists $ArgRef->{-groupid} ? $ArgRef->{-groupid} : 0;
  my $Check   = exists $ArgRef->{-check}   ? $ArgRef->{-check}   : "";

  require "Security.pm";

  my %Message = ("view" => "Can't view now", "create" => "Can't modify now");

  unless ($GroupID) {
    return;
  }

  my $Link = "<a href=\"$ListBy?groupid=$GroupID\"";
  $Link .= ' title="';
  $Link .= SmartHTML({-text => $SecurityGroups{$GroupID}{Description}},);
  $Link .= '">';
  $Link .= SmartHTML({-text => $SecurityGroups{$GroupID}{NAME}},);
  $Link .= "</a>";
  if ($Check && !GroupCan({ -groupid => $GroupID, -action => $Check }) ) {
    $Link .= "<br/>(".$Message{$Check}.")";
  }

  return $Link;
}

1;
