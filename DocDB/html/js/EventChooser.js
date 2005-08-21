// This script produces a menu for topics and another for relevant subtopics
// See TopicChooser.js for an explanation

// updateSelect  -> updateEventSelect
// merge_arrays  -> merge_event_arrays
// selectProduct -> selectEvent

function updateEventSelect( array, sel, target, sel_is_diff, single ) {
        
    var i, comp;

    // if single, even if it's a diff (happens when you have nothing
    // selected and select one item alone), skip this.
    if ( ! single ) {

        // array merging/sorting in the case of multiple selections
        if ( sel_is_diff ) {
        
            // merge in the current options with the first selection
            comp = merge_event_arrays( array[sel[0]], target.options, 1 );

            // merge the rest of the selection with the results
            for ( i = 1 ; i < sel.length ; i++ ) {
                comp = merge_event_arrays( array[sel[i]], comp, 0 );
            }
        } else {
            // here we micro-optimize for two arrays to avoid merging with a
            // null array 
            comp = merge_event_arrays( array[sel[0]],array[sel[1]], 0 );

            // merge the arrays. not very good for multiple selections.
            for ( i = 2; i < sel.length; i++ ) {
                comp = merge_event_arrays( comp, array[sel[i]], 0 );
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
        target.options[i] = new Option( event[comp[i]], comp[i] );
    }
}

// function fake_diff_array( a, b ) comes from TopicChooser.js

// takes two arrays and sorts them by string, returning a new, sorted
// array. the merge removes dupes, too.
//     - a, b: arrays to be merge.
//     - b_is_select: if true, then b is actually an optionitem and as
//       such we need to use item.value on it.

function merge_event_arrays( a, b, b_is_select ) { // merge_event_arrays
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
        if ( event[aitem.toLowerCase()] < event[bitem.toLowerCase()] ) {
            ret[ret.length] = aitem;
            pos_a++;
        } else {
            // smaller item in list b
            if ( event[aitem.toLowerCase()] > event[bitem.toLowerCase()] ) {
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

function selectEvent( f ) { //selectEvent

    // this is to avoid handling events that occur before the form
    // itself is ready, which happens in buggy browsers.

    if ( ( !f ) || ( ! f.eventgroups ) ) {
        return;
    }

    // if this is the first load and nothing is selected, no need to
    // merge and sort all components; perl gives it to us sorted.

    if ( ( first_load ) && ( f.events.selectedIndex == -1 ) ) {
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
    if ( f.eventgroups.selectedIndex == -1 ) {
        for ( var i = 0 ; i < f.eventgroups.length ; i++ ) {
            sel[sel.length] = f.eventgroups.options[i].value;
        }
        single = 0;
    } else {

        for ( i = 0 ; i < f.eventgroups.length ; i++ ) {
            if ( f.eventgroups.options[i].selected ) {
                sel[sel.length] = f.eventgroups.options[i].value;
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
    updateEventSelect( group, sel, f.events, is_diff, single );
}
