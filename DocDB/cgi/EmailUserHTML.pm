#        Name: EmailUserHTML.pm
# Description: HTML routines related to EmailUsers (personal accounts)
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2017 Eric Vaandering, Lynn Garren, Adam Bryant

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

require "DocumentHTML.pm";
require "DocumentUtilities.pm";

sub PrintEmailUserInfo ($) {
  my ($EmailUserID, $ShowWatchedDocs) = @_;

  require "NotificationSQL.pm";
  require "SecuritySQL.pm";
  require "MailNotification.pm";

  FetchEmailUser($EmailUserID);

  print "<tr>\n";
  print "<td>\n";

  print "<table class=\"LowPaddedTable LeftHeader\">\n";
  print "<tr>\n";
  print "<th>Username:</th><td>".SmartHTML({-text => $EmailUser{$EmailUserID}{Username}})."</td>\n";
  print "</tr><tr>\n";
  print "<th>Name:</th><td>".SmartHTML({-text => $EmailUser{$EmailUserID}{Name}})."</td>\n";
  print "</tr><tr>\n";
  print "<th>E-mail:</th><td>".SmartHTML({-text => $EmailUser{$EmailUserID}{EmailAddress}})."</td>\n";
  print "</tr><tr>\n";
  print "<th>Verified:</th>";
  print "<td>".("No","Yes")[$EmailUser{$EmailUserID}{Verified}]."</td>\n";
  print "</tr><tr>\n";
  print "<th>HTML:</th>";
  print "<td>".("No","Yes")[$EmailUser{$EmailUserID}{PreferHTML}]."</td>\n";
  print "</tr><tr>\n";
  print "<th>Can Sign:</th>";
  my $CanSignText  = ("No","Yes")[$EmailUser{$EmailUserID}{CanSign}];
  my $CanSign = '<a href="'.$SignatureReport."?emailuserid=$EmailUserID\">".SmartHTML({-text => $CanSignText}).'</a>';
  print "<td>$CanSign</td>\n";
  print "</tr><tr>\n";

  # Groups user belongs (or wants to belong to)

  print "<th>Groups:</th>";
  print "<td>\n";
  my @UserGroupIDs = FetchUserGroupIDs($EmailUserID);
  if (@UserGroupIDs) {
    print "<ul>\n";
    foreach my $UserGroupID (@UserGroupIDs) {
      FetchSecurityGroup($UserGroupID);
      print "<li>".SmartHTML({-text => $SecurityGroups{$UserGroupID}{NAME}})."</li>\n";
    }
    print "</ul>\n";
  } else {
    print "&nbsp;\n";
  }
  print "</td>\n";
  print "</tr>\n";
  print "</table>\n";
  print "</td>\n";

  print "<td>\n";
  DisplayNotification($EmailUserID,"Immediate");
  print "</td>\n";

  print "<td>\n";
  DisplayNotification($EmailUserID,"Daily");
  print "</td>\n";

  print "<td>\n";
  DisplayNotification($EmailUserID,"Weekly");
  print "</td>\n";

  # Display a table of individually watched documents
  if ($ShowWatchedDocs) {
    my @WatchDocumentIDs = @{$Notifications{$EmailUserID}{Document_Immediate}};
    if (@WatchDocumentIDs) {
      print '<tr><td colspan="4">';
      print "<h4>Individually watched documents:</h4>\n";
      my %FieldList = PrepareFieldList(-default => "Default");
      my $NDocs = DocumentTable(-fieldlist => \%FieldList, -docids => \@WatchDocumentIDs, -sortby => 'docid');
      print '</td></tr>';
    }
  }

  print "</tr>\n";
}

1;
