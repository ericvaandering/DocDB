
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

sub PrintEmailUserInfo ($) {
  my ($EmailUserID) = @_;
  
  require "NotificationSQL.pm";
  require "SecuritySQL.pm";
  require "MailNotification.pm";
 
  FetchEmailUser($EmailUserID);  
  
  print "<tr>\n";
  print "<td>\n";

  print "<table class=\"LowPaddedTable LeftHeader\">\n";
  print "<tr>\n";
  print "<th>Username:</th><td>$EmailUser{$EmailUserID}{Username}</td>\n"; 
  print "</tr><tr>\n";
  print "<th>Name:</th><td>$EmailUser{$EmailUserID}{Name}</td>\n"; 
  print "</tr><tr>\n";
  print "<th>E-mail:</th><td>$EmailUser{$EmailUserID}{EmailAddress}</td>\n"; 
  print "</tr><tr>\n";
  print "<th>Verified:</th>";
  print "<td>".("No","Yes")[$EmailUser{$EmailUserID}{Verified}]."</td>\n"; 
  print "</tr><tr>\n";
  print "<th>HTML:</th>";
  print "<td>".("No","Yes")[$EmailUser{$EmailUserID}{PreferHTML}]."</td>\n"; 
  print "</tr><tr>\n";
  print "<th>Can Sign:</th>";
  print "<td>".("No","Yes")[$EmailUser{$EmailUserID}{CanSign}]."</td>\n"; 
  print "</tr><tr>\n";
  
  # Groups user belongs (or wants to belong to)
  
  print "<th>Groups:</th>";
  print "<td>\n"; 
  my @UserGroupIDs = FetchUserGroupIDs($EmailUserID);
  if (@UserGroupIDs) {
    print "<ul>\n";
    foreach my $UserGroupID (@UserGroupIDs) {
      FetchSecurityGroup($UserGroupID);
      print "<li>$SecurityGroups{$UserGroupID}{NAME}</li>\n";
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

  print "</tr>\n";
}

1;
