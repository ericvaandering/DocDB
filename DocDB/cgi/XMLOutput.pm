#
# Author Eric Vaandering (ewv@fnal.gov)
#

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

use XML::Twig;

sub NewXMLOutput {
  $XMLTwig = XML::Twig -> new();
  $DocDBXML = XML::Twig::Elt -> new(docdb => {version => $DocDBVersion, href => $web_root} );
  return $DocDBXML;
}

sub XMLHeader {
  my $Header;
  $Header .= "Content-Type: text/xml\n";
  $Header .= "\n";
  $Header .= '<?xml version="1.0" encoding="ISO-8859-1"?>'."\n";
  return $Header;
}

sub GetXMLOutput {
  $XMLTwig -> set_pretty_print('indented');
  my $XMLText = $DocDBXML -> sprint();
  return $XMLText;
}

1;
