
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

sub HTMLPrintEnv {
  print "<table>\n"; 
  foreach my $key (sort keys %ENV) {
    print "<tr><td>$key<td>$ENV{$key}\n";
  }  
  print "</table>\n"; 
}

sub HTMLPrintParams {
  print "<table>\n"; 
  foreach my $key (sort keys %params) {
    print "<tr><td>$key<td>$params{$key}\n";
  }  
  print "</table>\n"; 
}

sub HTMLPrintKeys {
  print "<table>\n"; 
  foreach my $key (sort keys %params) {
    print "<tr><td>$key\n";
  }  
  print "</table>\n"; 
}

1;
