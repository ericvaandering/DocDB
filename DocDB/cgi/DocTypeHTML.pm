#
#        Name: DocTypeHTML.pm
# Description: Routines with form elements and other HTML generating
#              code pertaining to DocumentTypes.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub DocTypeSelect (;%) { # Scrolling selectable list for doc type search
  my ($ArgRef) = @_;
  my $Disabled = exists $ArgRef->{-disabled} ?   $ArgRef->{-disabled} : 0;
  my $Multiple = exists $ArgRef->{-multiple} ?   $ArgRef->{-multiple} : 0;
  my $Format   = exists $ArgRef->{-format}   ?   $ArgRef->{-format}   : "full";
#  my $HelpLink = exists $ArgRef->{-helplink} ?   $ArgRef->{-helplink} : "";
#  my $HelpText = exists $ArgRef->{-helptext} ?   $ArgRef->{-helptext} : "  my (%Params) = @_;

  my $Booleans = "";

  if ($Disabled) {
    $Booleans .= "-disabled";
  }

  my %DocTypeLabels = ();
  foreach my $DocTypeID (keys %DocumentTypes) {
    my $LongName = SmartHTML({-text => $DocumentTypes{$DocTypeID}{LONG}},);
    my $ShortName = SmartHTML({-text => $DocumentTypes{$DocTypeID}{SHORT}},);
    if ($Format eq "short") {
      $DocTypeLabels{$DocTypeID} = $ShortName;
    } elsif ($Format eq "full") {
      $DocTypeLabels{$DocTypeID} = "$ShortName [$LongName]";
    }
  }
  print FormElementTitle(-helplink => "doctype", -helptext => "Document type");
  print $query -> scrolling_list(-size => 10, -name => "doctype", -multiple => $Multiple,
                              -values => \%DocTypeLabels, $Booleans);
};


sub DocTypeEntryBox (;%) {
  my (%Params) = @_;

  my $Disabled = $Params{-disabled}  || "0";

  my $Booleans = "";

  if ($Disabled) {
    $Booleans .= "-disabled";
  }

  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "doctypeentry", -helptext => "Short Description");
  print $query -> textfield (-name => 'name',
                             -size => 20, -maxlength => 32, $Booleans);
  print "</td>\n";
  print "</tr><tr>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "doctypeentry", -helptext => "Long Description");
  print $query -> textfield (-name => 'longdesc',
                             -size => 40, -maxlength => 255, $Booleans);
  print "</td></tr>\n";

  print "</table>\n";

}

1;
