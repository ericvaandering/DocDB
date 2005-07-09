
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

# Embed script with 
# <script>
# <!--
# <![CDATA[
#  source
# ]]>
# //-->
# </script>


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

  print <<ENDSCRIPT;

// Adds to the target select object all elements in array that
// correspond to the elements selected in source.
//     - array should be a array of arrays, indexed by product name. the
//       array should contain the elements that correspont to that
//       product. Example:
//         var array = Array();
//         array['ProductOne'] = [ 'ComponentA', 'ComponentB' ];
//         updateSelect(array, source, target);
//     - sel is a list of selected items, either whole or a diff
//       depending on sel_is_diff.
//     - sel_is_diff determines if we are sending in just a diff or the
//       whole selection. a diff is used to optimize adding selections.
//     - target should be the target select object.
//     - single specifies if we selected a single item. if we did, no
//       need to merge.
//     - label is used for human-readable labels on the options (EWV)

function updateSelect( array, sel, target, sel_is_diff, single ) {
        
    var i, comp;

    // if single, even if it's a diff (happens when you have nothing
    // selected and select one item alone), skip this.
    if ( ! single ) {

        // array merging/sorting in the case of multiple selections
        if ( sel_is_diff ) {
        
            // merge in the current options with the first selection
            comp = merge_arrays( array[sel[0]], target.options, 1 );

            // merge the rest of the selection with the results
            for ( i = 1 ; i < sel.length ; i++ ) {
                comp = merge_arrays( array[sel[i]], comp, 0 );
            }
        } else {
            // here we micro-optimize for two arrays to avoid merging with a
            // null array 
            comp = merge_arrays( array[sel[0]],array[sel[1]], 0 );

            // merge the arrays. not very good for multiple selections.
            for ( i = 2; i < sel.length; i++ ) {
                comp = merge_arrays( comp, array[sel[i]], 0 );
            }
        }
    } else {
        // single item in selection, just get me the list
        comp = array[sel[0]];
    }

    // clear select
    target.options.length = 0;

    // load elements of list into select
    for ( i = 0; i < comp.length; i++ ) {
        target.options[i] = new Option( label[comp[i]], comp[i] );
    }
}

// Returns elements in a that are not in b.
// NOT A REAL DIFF: does not check the reverse.
//     - a,b: arrays of values to be compare.

function fake_diff_array( a, b ) {
    var newsel = new Array();

    // do a boring array diff to see who's new
    for ( var ia in a ) {
        var found = 0;
        for ( var ib in b ) {
            if ( a[ia] == b[ib] ) {
                found = 1;
            }
        }
        if ( ! found ) {
            newsel[newsel.length] = a[ia];
        }
        found = 0;
    }
    return newsel;
}

// takes two arrays and sorts them by string, returning a new, sorted
// array. the merge removes dupes, too.
//     - a, b: arrays to be merge.
//     - b_is_select: if true, then b is actually an optionitem and as
//       such we need to use item.value on it.

function merge_arrays( a, b, b_is_select ) {
    var pos_a = 0;
    var pos_b = 0;
    var ret = new Array();
    var bitem, aitem;

    // iterate through both arrays and add the larger item to the return
    // list. remove dupes, too. Use toLowerCase to provide
    // case-insensitivity.

    while ( ( pos_a < a.length ) && ( pos_b < b.length ) ) {

        if ( b_is_select ) {
            bitem = b[pos_b].value;
        } else {
            bitem = b[pos_b];
        }
        aitem = a[pos_a];

        // smaller item in list a
        if ( label[aitem.toLowerCase()] < label[bitem.toLowerCase()] ) {
            ret[ret.length] = aitem;
            pos_a++;
        } else {
            // smaller item in list b
            if ( label[aitem.toLowerCase()] > label[bitem.toLowerCase()] ) {
                ret[ret.length] = bitem;
                pos_b++;
            } else {
                // list contents are equal, inc both counters. 
                ret[ret.length] = aitem;
                pos_a++;
                pos_b++;
            }
        }
    }

    // catch leftovers here. these sections are ugly code-copying.
    if ( pos_a < a.length ) {
        for ( ; pos_a < a.length ; pos_a++ ) {
            ret[ret.length] = a[pos_a];
        }
    }

    if ( pos_b < b.length ) {
        for ( ; pos_b < b.length; pos_b++ ) {
            if ( b_is_select ) {
                bitem = b[pos_b].value;
            } else {
                bitem = b[pos_b];
            }
            ret[ret.length] = bitem;
        }
    }
    return ret;
}

// selectProduct reads the selection from f.majortopic and updates
// f.minortopic accordingly.
//     - f: a form containing majortopic and minortopic select boxes. 
// globals (3vil!):
//     - major: array of arrays, indexed by major topic. the
//       subarrays contain a list of names to be fed to the respective
//       selectboxes. For bugzilla, these are generated with perl code
//       at page start.
//     - first_load: boolean, specifying if it's the first time we load
//       the query page.
//     - last_sel: saves our last selection list so we know what has
//       changed, and optimize for additions.

function selectProduct( f ) {

    // this is to avoid handling events that occur before the form
    // itself is ready, which happens in buggy browsers.

    if ( ( !f ) || ( ! f.majortopic ) ) {
        return;
    }

    // if this is the first load and nothing is selected, no need to
    // merge and sort all components; perl gives it to us sorted.

    if ( ( first_load ) && ( f.majortopic.selectedIndex == -1 ) ) {
            first_load = 0;
            return;
    }
    
    // turn first_load off. this is tricky, since it seems to be
    // redundant with the above clause. It's not: if when we first load
    // the page there is _one_ element selected, it won't fall into that
    // clause, and first_load will remain 1. Then, if we unselect that
    // item, selectProduct will be called but the clause will be valid
    // (since selectedIndex == -1), and we will return - incorrectly -
    // without merge/sorting.

    first_load = 0;

    // - sel keeps the array of products we are selected. 
    // - is_diff says if it's a full list or just a list of products that
    //   were added to the current selection. 
    // - single indicates if a single item was selected
    var sel = Array();
    var is_diff = 0;
    var single;

    // if nothing selected, pick all
    if ( f.majortopic.selectedIndex == -1 ) {
        for ( var i = 0 ; i < f.majortopic.length ; i++ ) {
            sel[sel.length] = f.majortopic.options[i].value;
        }
        single = 0;
    } else {

        for ( i = 0 ; i < f.majortopic.length ; i++ ) {
            if ( f.majortopic.options[i].selected ) {
                sel[sel.length] = f.majortopic.options[i].value;
            }
        }

        single = ( sel.length == 1 );

        // save last_sel before we kill it
        var tmp = last_sel;
        last_sel = sel;
    
        // this is an optimization: if we've added components, no need
        // to remerge them; just merge the new ones with the existing
        // options.

        if ( ( tmp ) && ( tmp.length < sel.length ) ) {
            sel = fake_diff_array(sel, tmp);
            is_diff = 1;
        }
    }

    // do the actual fill/update
    updateSelect( major, sel, f.minortopic, is_diff, single );
}

// -->
</script>


ENDSCRIPT

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
