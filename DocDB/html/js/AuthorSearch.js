
		function addAuthorList(item){
			if (!item)
				return false;

			var auth_id = item[0];
			var auth_title = item[1];

			jQuery('#sel_authors_box').show();

			/* prevent multiple additions of same author */
			jQuery('#auth_li_'+ auth_id).remove();

			/* create the author item in the list - it's stored as hidden checkbox */

			var new_auth_list_item = jQuery('<li id="auth_li_'+ auth_id +'">\
							<input name="authors" value="' + auth_id + '" type="checkbox" checked="checked" id="auth_item_' + auth_id + '" class="hidden">\
							<label for=""auth_item_' + auth_id + '"">&nbsp;'+auth_title +'</label>\
						</li>');

			var remove_button = jQuery('<a class="remove_button"><img src="' + imgURL + '/delete.png" /></a>');

			// remove handler
			jQuery(remove_button).click( function(event){
					event.preventDefault();
					jQuery('#auth_li_'+ auth_id).remove();

					return false;
				});

			jQuery(new_auth_list_item).append(remove_button);

			jQuery("#authors_id_span").append(new_auth_list_item);


		}




jQuery().ready(function() {

	jQuery('#sel_authors_box').hide();


    /* Modify the search behaviour so that matching of different parts of name would be assigned different priorities:
            o) matches the beginning of complete string [same as "last name, first name"]
            1) beginning of last name matches
            2) beginning of first name matches
            3) matches part of lastname
            4) matches part of firstname

            Source adapted from: Jquery autocomplete plugin v1.1 
            http://plugins.jquery.com/files/issues/jquery.autocomplete.js__7.txt (MIT/GPL license)
     */
    $.Autocompleter.Cache = function(options) {

        var data = {};
        var length = 0;

        function matchSubset(s, sub) {
            if (!options.matchCase)
                s = s.toLowerCase();
            var i = s.indexOf(sub);
            if (options.matchContains == "word") {
                i = s.toLowerCase().search("\\b" + sub.toLowerCase());
            }
            if (i == -1) return false;
            return i == 0 || options.matchContains;
        };

        function matchSubset_starts(s, sub) {
            if (s === undefined || s === null)
                return false;
            if (!options.matchCase)
                s = s.toLowerCase();
            var i = s.indexOf(sub);
            if (options.matchContains == "word") {
                i = s.toLowerCase().search("\\b" + sub.toLowerCase());
            }
            if (i == -1) return false;
            return i == 0;
        };


        function add(q, value) {
            if (length > options.cacheLength) {
                flush();
            }
            if (!data[q]) {
                length++;
            }
            data[q] = value;
        }

        function populate() {
            if (!options.data) return false;
            // track the matches
            var stMatchSets = {},
			nullData = 0;

            // no url was specified, we need to adjust the cache length to make sure it fits the local data store
            if (!options.url) options.cacheLength = 1;

            // track all options for minChars = 0
            stMatchSets[""] = [];

            // loop through the array and create a lookup structure
            for (var i = 0, ol = options.data.length; i < ol; i++) {
                var rawValue = options.data[i];
                // if rawValue is a string, make an array otherwise just reference the array
                rawValue = (typeof rawValue == "string") ? [rawValue] : rawValue;

                var value = options.formatMatch(rawValue, i + 1, options.data.length);
                if (value === false)
                    continue;

                var firstChar = value.charAt(0).toLowerCase();
                // if no lookup array for this character exists, look it up now
                if (!stMatchSets[firstChar])
                    stMatchSets[firstChar] = [];

                // if the match is a string
                var row = {
                    value: value,
                    data: rawValue,
                    result: options.formatResult && options.formatResult(rawValue) || value
                };

                // push the current match into the set list
                stMatchSets[firstChar].push(row);

                // keep track of minChars zero items
                if (nullData++ < options.max) {
                    stMatchSets[""].push(row);
                }
            };

            // add the data items to the cache
            $.each(stMatchSets, function(i, value) {
                // increase the cache size
                options.cacheLength++;
                // add to the cache
                add(i, value);
            });
        }

        // populate any existing data
        setTimeout(populate, 25);

        function flush() {
            data = {};
            length = 0;
        }

        return {
            flush: flush,
            add: add,
            populate: populate,
            load: function(q) {
                if (!options.cacheLength || !length)
                    return null;
                /* 
                * if dealing w/local data and matchContains than we must make sure
                * to loop through all the data collections looking for matches
                */


                if (!options.url && options.matchContains) {

                    // =========== CMS MODIFICATION STARTS ============
                    // track all matches
                    var csub = [];
                    var value_starts = [];
                    var lastname_starts = [];
                    var lastname_contains = [];
                    var firstname_contains = [];
                    var firstname_starts = [];
                    var value_contains = [];

                    /* Match second name with highest priority, first name with lower, and other with lowest */
                    function parse_first_last_names(s){
                        if (s.indexOf(",") == -1)
                           return {first:"", last:s};
                        first = s.split(",")[1];
                        last = s.split(",")[0];
                        /* TODO: is always comma available ? */ 
                        return { first: first, last: last };
                    }

                    // loop through all the data grids for matches
                    for (var k in data) {
                        if (k.length > 0) {
                            var c = data[k];
                            /*
                               */
                            $.each(c, function(i, x) {
                                r = parse_first_last_names(x.value);

                                if (matchSubset_starts(x.value, q))
                                   value_starts.push(x);
                                else if (matchSubset_starts(r.last, q))
                                    lastname_starts.push(x);                                
                                else if (matchSubset_starts(r.first, q))
                                    firstname_starts.push(x);
                                else if (matchSubset(r.last, q))
                                    lastname_contains.push(x);
                                else if (matchSubset(r.first, q))
                                    firstname_contains.push(x)
                                else  if (matchSubset(x.value, q))
                                   value_contains.push(x);
                            });
                        }
                    }
                    /* Concatenate the results by priority order */
                    var results = [];
                    var append_f = function(i, x) { results.push(x); };

                    $.each(value_starts, append_f);
                    $.each(lastname_starts, append_f);
                    $.each(firstname_starts, append_f);
                    $.each(lastname_contains, append_f);
                    $.each(firstname_contains, append_f);
                    $.each(value_contains, append_f);
                    return results;
                    // =========== CMS MODIFICATION ENDS ============
                } else {
                // if the exact item exists, use it
                    if (data[q]) {
                        return data[q];
                    } else
                        if (options.matchSubset) {
                        for (var i = q.length - 1; i >= options.minChars; i--) {
                            var c = data[q.substr(0, i)];
                            if (c) {
                                var csub = [];
                                $.each(c, function(i, x) {
                                    if (matchSubset(x.value, q)) {
                                        csub[csub.length] = x;
                                    }
                                });
                                return csub;
                            }
                        }
                    }
                }
                return null;
            }
        };
    };


	/* set up autocompleate plugin for author and creator selection */

	if (jQuery("#requester").length){
    	jQuery("#requester").autocomplete(auth_ids, {
    		minChars: 0,
    		max: 50,
    		autoFill: false,
    		mustMatch: false,
    		matchContains: true,
    		scrollHeight: 220,


    		/* temporarly: this is a little bad - as it automatically selects one of the entries without user pressing up-down, but allows to avoid form submition after Return */
    		selectFirst: true,

    		formatItem: function(item) {
                        if (!item)
                                return false;
    			return item[1];
    		}
    		});
   		jQuery("#requester").result(function(event, item, formatted) {
    		  if (item){
    			  jQuery("#requester-id").val(item[0]);
        		  jQuery(this).removeClass("error");
        	  }
    		  else {
        		  jQuery("#requester-id").val("");
        		  jQuery(this).addClass("error");
    		  }
    		}
    	);
    	jQuery("#requester").bind('blur keypress', function(){
		    jQuery(this).search(); //trigger result() on blur, even if autocomplete wasn't used
		});
	}


	/* Authors */
	if (jQuery("#authors_selector").length){
    	jQuery("#authors_selector").autocomplete(auth_ids, {
    		minChars: 0,
    		max: 50,
    		autoFill: false,
    		mustMatch: false,
    		matchContains: true,
    		scrollHeight: 220,

    		/* temporarly: this is a little bad - as it automatically selects one of the entries without user pressing up-down, but allows to avoid form submition after Return */
    		selectFirst: true,

    		formatItem: function(item) {
                        if (!item)
                                return false;
    			return item[1];
    		}
    	})
    	jQuery("#authors_selector").result(function(event, item, formatted) {
    		  if (item){
    			  addAuthorList(item);
        		  jQuery(this).removeClass("error");
                  jQuery(this).val("");
        	  }
    		  else {
        		  if (jQuery(this).val() != '')
        		  	jQuery(this).addClass("error");
    		  }
    		  //return false;
    	});
    	jQuery("#authors_selector").bind('blur keypress', function(){
		    jQuery(this).search(); //trigger result() on blur, even if autocomplete wasn't used
		});

	}

});
