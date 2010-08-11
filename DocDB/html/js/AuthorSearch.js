
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

			var remove_button = jQuery('<a class="remove_button"><img src="' + imgURL + '/stop_icon.gif" /></a>');

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
