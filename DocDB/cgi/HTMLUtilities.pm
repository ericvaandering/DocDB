#
# Description: Routines to output headers, footers, navigation bars, etc. 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
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


require "ProjectRoutines.pm";

sub DocDBHeader { 
  my ($Title,$PageTitle,%Params) = @_;
  
  my $Search  = $Params{-search}; # Fix search page!
  my $NoBody  = $Params{-nobody};
  my $Refresh = $Params{-refresh} || "";
  my @Scripts = @{$Params{-scripts}};

  my @ScriptParts = split /\//,$ENV{SCRIPT_NAME};
  my $ScriptName  = pop @ScriptParts;

  unless ($PageTitle) { 
    $PageTitle = $Title;
  }  
  
  # FIXME: Do Hash lookup for scripts as they are certified XHTML?
  if ($DOCTYPE) {
    print $DOCTYPE;
  } else {
    print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"
          \"http://www.w3.org/TR/html4/loose.dtd\">\n";
  }
  print "<html>\n";
  print "<head>\n";
  if ($Refresh) {
    print "<meta http-equiv=\"refresh\" content=\"$Refresh\" />\n";
  }  
  print '<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />',"\n";
  print "<title>$Title</title>\n";

  # Include DocDB style sheets
  
  my @PublicCSS = ("");
  if ($Public) {
    @PublicCSS = ("","Public");
  }
  
  foreach my $ScriptCSS ("",$ScriptName) {
    foreach my $ProjectCSS ("",$ShortProject) {
      foreach my $PublicCSS (@PublicCSS) {
        foreach my $BrowserCSS ("","_IE") {
          my $CSSFile = $CSSDirectory."/".$ProjectCSS.$PublicCSS."DocDB".$ScriptCSS.$BrowserCSS.".css";
          my $CSSURL  =   $CSSURLPath."/".$ProjectCSS.$PublicCSS."DocDB".$ScriptCSS.$BrowserCSS.".css";
          if (-e $CSSFile) {
            if ($BrowserCSS eq "_IE") { # Use IE format for including. Hopefully we can not give these to IE7
              print "<!--[if IE]>\n";
              print "<link rel=\"stylesheet\" href=\"$CSSURL\" type=\"text/css\" />\n";
              print "<![endif]-->\n"; 
            } else {
              print "<link rel=\"stylesheet\" href=\"$CSSURL\" type=\"text/css\" />\n";
            }
          }
        }
      }
    }
  }

  # Include javascript links

  foreach my $Script (@Scripts) {
    if ($Script eq "TopicChooser") { # Get global variables in right place
      require "Scripts.pm";
      &TopicSearchScript;
    } elsif  ($Script eq "EventChooser") { # Get global variables in right place
      require "Scripts.pm";
      &EventSearchScript;
    }
    print "<script type=\"text/javascript\" src=\"$JSURLPath/$Script.js\"></script>\n";
  }  

  if (defined &ProjectHeader) {
    &ProjectHeader($Title,$PageTitle); 
  }

  print "</head>\n";

  if ($Search) {
    print "<body class=\"Normal\" onload=\"selectProduct(document.forms[\'queryform\']);\">\n";
  } else {
    if ($NoBody) {
      print "<body class=\"PopUp\">\n";
    } else {  
      print "<body class=\"Normal\">\n";
    }  
  }  
  
  if (defined &ProjectBodyStart && !$NoBody) {
    &ProjectBodyStart($Title,$PageTitle); 
  }
}

sub DocDBFooter ($$;%) {
  require "ResponseElements.pm";
  
  my ($WebMasterEmail,$WebMasterName,%Params) = @_;
  
  my $NoBody = $Params{-nobody};

  &DebugPage("At DocDBFooter");
  
  unless ($NoBody) { 
    if (defined &ProjectFooter) {
      &ProjectFooter($WebMasterEmail,$WebMasterName); 
    }
  }  
  print "</body></html>\n";
}

1;
