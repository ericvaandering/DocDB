
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


sub HelpPopupScript {
  print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
  print "<!-- \n";

  print "function helppopupwindow(page){\n";
  print "window.open(page,\"docdbhelp\",\"width=450,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0\");\n";
  print "}\n";

  print "//-->\n";
  print "</script>\n";
}

sub HelpLink { # Change this, change FormElementTitle
               # Eventually, replace with  FormElementTitle
  my ($helpterm) = @_;
  print " style=\"color: red\" href=\"Javascript:helppopupwindow(\'$DocDBHelp?term=$helpterm\');\">";
}

sub TalkNotePopupScript {
  print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
  print "<!-- \n";

  print "function notepopupwindow(page){\n";
  print "window.open(page,\"docdbnote\",\"width=800,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0\");\n";
  print "}\n";

  print "//-->\n";
  print "</script>\n";
}

sub TalkNoteLink {
  my ($SessionTalkID) = @_;
  return "<a href=\"Javascript:notepopupwindow(\'$ShowTalkNote?sessiontalkid=$SessionTalkID\');\">Note</a>";
}

sub GroupLimitPopupScript {
  print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
  print "<!-- \n";

  print "function grouplimitpopupwindow(page){\n";
  print "window.open(page,\"grouplimit\",\"width=450,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0\");\n";
  print "}\n";

  print "//-->\n";
  print "</script>\n";
}

sub GroupLimitLink {
  return "<a href=\"Javascript:grouplimitpopupwindow(\'$SelectGroups\');\">Limit Groups</a>";
}

sub ConfirmTalkPopupScript {
  print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
  print "<!-- \n";

  print "function confirmtalkpopupwindow(theForm){\n";
  print "var oUrl=\"$ConfirmTalkHint?documentid=\"+theForm.documentid.value+\"&sessiontalkid=\"+theForm.sessiontalkid.value;\n";
  print "window.open(oUrl,\"confirmtalk\",\"width=400,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0\");\n";
  print "}\n";

  print "//-->\n";
  print "</script>\n";
}

sub ConfirmTalkLink ($$) { #FIXME: Make onclick optional, use in DocumentTable
  my ($SessionTalkID,$DocumentID) = @_;
  my $HTML  = "<form>";
     $HTML .= $query -> hidden(-name => 'documentid',   -default => $DocumentID);
     $HTML .= $query -> hidden(-name => 'sessiontalkid',-default => $SessionTalkID);
     $HTML .= $query -> button(-value => "Confirm Match", 
                               -onclick => "confirmtalkpopupwindow(this.form,\"$ConfirmTalkHint\")");
     $HTML .= "</form>";
  return $HTML;
}

sub TopicSearchScript {

# This script produces a menu for topics and another for relevant subtopics
# (i.e. selecting a topic reduces the set of subtopics). This code is 
# adapted from Bugzilla, produced by mozilla.org.

# There are two major changes:
#  1. seperate labels and values
#  2. sort by label instead of by value

  print <<PREAMBLE;

<script language="JavaScript" type="text/javascript">
<!--

var first_load = 1; // is this the first time we load the page?
var last_sel = []; // caches last selection

var major = new Array();
var label = new Array();

PREAMBLE

  foreach $MajorID (sort byMajorTopic keys %MajorTopics) {
    print "major[\'$MajorID\'] = [";
    $first = 1;
    foreach $MinorID (sort byTopic keys %MinorTopics) { #FIXME use join
      if ($MinorTopics{$MinorID}{MAJOR} == $MajorID) {
        unless ($first) { 
          print ", ";
        }
        $first = 0;
        print "\'$MinorID\'";
      }
    }
    print "];\n";  
  }

  foreach $MinorID (sort byTopic keys %MinorTopics) { #FIXME use join
    my $label = $MinorTopics{$MinorID}{Full};
    $label =~ s/\'/\\\'/; # Escape single quotes
    print "label[\'$MinorID\'] = \'$label\';\n"; 
  }   

  print "//-->\n</script>\n";
} 

sub KeywordChooserPopupScript {
  print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
  print "<!-- \n";

  print "function keywordchooserwindow(page){\n";
  print "window.open(page,\"KeywordChooser\",\"width=800,height=600,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0\");\n";
  print "}\n";

  print "//-->\n";
  print "</script>\n";
}

sub KeywordInsertScript {
  
  # Adapted from KochSuite, a German-authored Cookbook by 
  # Michael Lestinsky <michael@zaphod.rhein-neckar.de>
  
  print <<ENDSCRIPT;

  <script language="JavaScript1.2">
  <!--
    function InsertKeyword ( name ) {
      if ( opener.document.forms[0].keywords.value == '' ) {
        opener.document.forms[0].keywords.value = name;
      } else {
        opener.document.forms[0].keywords.value += ' ' + name;
      }
    }
  //-->
  </script>

ENDSCRIPT

}

sub RevisionNoteInsertScript {
  
  # Adapted from KochSuite, a German-authored Cookbook by 
  # Michael Lestinsky <michael@zaphod.rhein-neckar.de>
  
  print <<ENDSCRIPT;

  <script language="JavaScript1.2">
  <!--
    function InsertRevisionNote ( note ) {
      if ( document.forms[0].revisionnote.value == '' ) {
        document.forms[0].revisionnote.value = note;
      } else {
        document.forms[0].revisionnote.value += note;
      }
    }
  //-->
  </script>

ENDSCRIPT

}

sub SignatureInsertScript {
  
  # Adapted from KochSuite, a German-authored Cookbook by 
  # Michael Lestinsky <michael@zaphod.rhein-neckar.de>
  
  print <<ENDSCRIPT;

  <script language="JavaScript1.2">
  <!--
    function InsertSignature ( name ) {
      if ( opener.document.forms[0].signofflist.value == '' ) {
        opener.document.forms[0].signofflist.value = name;
      } else {
        opener.document.forms[0].signofflist.value += '\\n' + name;
      }
    }
  //-->
  </script>

ENDSCRIPT

}

sub SignoffChooserPopupScript {
  print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
  print "<!-- \n";

  print "function signoffchooserwindow(page){\n";
  print "window.open(page,\"SignoffChooser\",\"width=400,height=500,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0\");\n";
  print "}\n";

  print "//-->\n";
  print "</script>\n";
}

sub AdminDisableScripts (%) {

# Adapted from CellarTracker

  my (%Params) = @_;
  
  my $Form       =   $Params{-form}  || "";
  my %Matrix     = %{$Params{-matrix}};
  my %Positions  = %{$Params{-positions}};
 
 
  print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
  print "<!-- \n";

  print "function disabler_",$Form,"() {\n";
#  print "function disabler() {\n";
  
  foreach my $Position (keys %Positions) {
    print " if (document.$Form.admaction[$Positions{$Position}].checked == true) {\n";
    foreach my $Element (keys %Matrix) {
      if ($Matrix{$Element}{$Position}) {
        print "  document.$Form.$Element.disabled = false;\n";
      } else {  
        print "  document.$Form.$Element.disabled = true;\n";
      }
    }
    print " }\n";    
  }
  
  
  
  print "}\n";
  
  print "//-->\n";
  print "</script>\n";
}


1;
