#
# Description: Subroutines to provide various parts of HTML about documents
#              and linking to other docs, etc.
#
#              THIS FILE IS DEPRECATED. DO NOT PUT NEW ROUTINES HERE, USE *HTML
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

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

require "AuthorHTML.pm"; #FIXME: Remove, move references to correct place
require "TopicHTML.pm";  #FIXME: Remove, move references to correct place
require "FileHTML.pm";   #FIXME: Remove, move references to correct place
require "RevisionHTML.pm";   #FIXME: Remove, move references to correct place

sub PrintTitle {
  my ($Title) = @_;
  if ($Title) {
    print "<h1>$Title</h1>\n";
  } else {
    print "<h1><b>Title:</b> none<br></h1>\n";
  }
}

sub WarnPage { # Non-fatal errors
  my @errors = @_;
  if (@errors) {
    print "<dl class=\"warning\">\n";
    if ($#errors) {
      print "<dt class=\"Warning\">There were non-fatal errors processing your
             request: </dt>\n";
    } else {
      print "<dt class=\"Warning\">There was a non-fatal error processing your
             request: </dt>\n";
    } 
    foreach $message (@errors) {
      print "<dd>$message</dd>\n";
    }
    print "</dl>\n"; 
  }   
}

sub DebugPage (;$) { # Debugging output
  my ($CheckPoint) = @_; 
  if (@DebugStack && $DebugOutput) {
    print "<dl class=\"debug\">\n";
    print "<dt class=\"Warning\">Debugging messages: $CheckPoint</dt>\n";
    foreach my $Message (@DebugStack) {
      print "<dd>$Message</dd>\n";
    } 
    print "</dl>\n";
  } elsif ($CheckPoint && $DebugOutput) {
    print "<div>No Debugging messages: $CheckPoint<br/></div>\n";
  }  
  @DebugStack = ();
  return @DebugStack;
}

sub EndPage {  # Fatal errors, aborts page if present
  my @Errors = @_;
  if (@Errors) { 
    &ErrorPage(@Errors);
    &DocDBNavBar();
    &DocDBFooter($DBWebMasterEmail,$DBWebMasterName);
    exit;
  }  
}

sub ErrorPage { # Fatal errors, continues page
  my @errors = @_;
  if (@errors) {
    print "<dl class=\"error\">\n";
    if ($#errors) {
      print "<dt class=\"Error\">There were fatal errors processing your
             request:</dt>\n";
    } else {
      print "<dt class=\"Error\">There was a fatal error processing your
             request:</dt>\n";
    } 
    foreach $message (@errors) {
      print "<dd>$message</dd>\n";
    }  
    print "</dl>\n";
    print "<p/>\n";
  }  
}

sub ActionReport { 
  my @Actions = @_;
  if (@Actions) {
    print "<dl class=\"Action\">\n";
    print "<dt class=\"Action\">Action taken:</dt>\n";
    foreach $Message (@Actions) {
      print "<dd>$Message</dd>\n";
    }  
    print "</dl>\n";
  }  
}

sub FullDocumentID ($;$) {
  my ($DocumentID,$Version) = @_;
  if (defined $Version) {
    return "$ShortProject-doc-$DocumentID-v$Version";
  } else {  
    return "$ShortProject-doc-$DocumentID";
  }  
}  

sub DocumentLink { #FIXME: Move to NewerDocumentLink 
  my ($DocumentID,$Version,$Title) = @_;
  my $DocNumber = &FullDocumentID($DocumentID,$Version);
  my $Link = "<a title=\"$DocNumber\" href=\"$ShowDocument\?docid=$DocumentID\&amp;version=$Version\">";
  if ($Title) {
    $Link .= $Title;
  } else {
    $Link .= $DocNumber;
  }
  $Link .=  "</a>";
}         

sub DocumentURL {
  my ($DocumentID,$Version) = @_;
  my $URL;
  if (defined $Version) {
    $URL =  "$ShowDocument\?docid=$DocumentID\&amp;version=$Version";
  } else {  
    $URL =  "$ShowDocument\?docid=$DocumentID";
  }  
  return $URL
}

sub EuroDate {
  my ($sql_datetime) = @_;
  unless ($sql_datetime) {return "";}
  
  my ($date,$time) = split /\s+/,$sql_datetime;
  my ($year,$month,$day) = split /\-/,$date;
  $return_date = "$day ".("Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec")[$month-1].
                 " $year"; 
  return $return_date;
}

sub EuroDateTime {
  my ($sql_datetime) = @_;
  unless ($sql_datetime) {return "";}
  
  my ($date,$time) = split /\s+/,$sql_datetime;
  my ($year,$month,$day) = split /\-/,$date;
  $return_date = "$time ".
                 "$day ".("Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec")[$month-1].
                 " $year"; 
  return $return_date;
}

sub EuroDateHM($) {
  my ($SQLDatetime) = @_;
  unless ($SQLDatetime) {return "";}
  
  my ($Date,$Time) = split /\s+/,$SQLDatetime;
  my ($Year,$Month,$Day) = split /\-/,$Date;
  my ($Hour,$Min,$Sec) = split /:/,$Time;
  $ReturnDate = "$Day ".("Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec")[$Month-1].
                " $Year, $Hour:$Min"; 
  return $ReturnDate;
}

sub TypesTable {
  my $NCols = 3;
  my @TypeIDs = keys %DocumentTypes;

  my $Col   = 0;
  print "<table cellpadding=10>\n";
  foreach my $TypeID (@TypeIDs) {
    unless ($Col % $NCols) {
      print "<tr valign=top>\n";
    }
    $link = &TypeLink($TypeID,"short");
    print "<td>$link\n";
    ++$Col;
  }  

  print "</table>\n";
}

sub TypeLink {
  my ($TypeID,$mode) = @_;
  
  require "MiscSQL.pm";
  
  &FetchDocType($TypeID);
  my $link = "";
  unless ($Public) {
    $link .= "<a href=\"$ListBy?typeid=$TypeID\">";
  }
  if ($mode eq "short") {
    $link .= $DocumentTypes{$TypeID}{SHORT};
  } else {
    $link .= $DocumentTypes{$TypeID}{LONG};
  }
  unless ($Public) {
    $link .= "</a>";
  }
  
  return $link;
}

1;
