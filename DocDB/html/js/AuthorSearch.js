
		function addAuthorList(item){
			if (!item)
				return false;

			var auth_id = item[0];
			var auth_title = item[1];

			$('#sel_authors_box').show();

			/* prevent multiple additions of same author */
			$('#auth_li_'+ auth_id).remove();

			/* create the author item in the list - it's stored as hidden checkbox */

			var new_auth_list_item = $('<li id="auth_li_'+ auth_id +'">\
							<input name="authors" value="' + auth_id + '" type="checkbox" checked="checked" id="auth_item_' + auth_id + '" class="hidden">\
							<label for=""auth_item_' + auth_id + '"">&nbsp;'+auth_title +'</label>\
						</li>');

                        var remove_button = $('<span class="remove_button"><img src="' + imgURL + '/stop_icon.gif" /></span>');

			// remove handler
			$(remove_button).click( function(){
					$('#auth_li_'+ auth_id).remove();
					//return false;
				});

			$(new_auth_list_item).append(remove_button);

			$("#authors_id_span").append(new_auth_list_item);


		}




$().ready(function() {

	$('#sel_authors_box').hide();

	/* set up autocompleate plugin for author and creator selection */

	$("#requester-submitter").autocomplete(auth_ids, {
		minChars: 0,
		max: 50,
		autoFill: false,
		mustMatch: true,
		matchContains: true,
		scrollHeight: 220,

		/* temporarly: this is a little bad - as it automatically selects one of the entries without user pressing up-down, but allows to avoid form submition after Return */
		selectFirst: true,

		formatItem: function(item) {
			return item[1];
		}
		}).result(function(event, item) {
		  if (item)
			  $("#requester-submitter-id").val(item[0]);
		  else $("#requester-submitter-id").val("");
		}
	);


	/* Authors */
	$("#authors_selector").autocomplete(auth_ids, {
		minChars: 0,
		max: 50,
		autoFill: false,
		mustMatch: true,
		matchContains: true,
		scrollHeight: 220,

		/* temporarly: this is a little bad - as it automatically selects one of the entries without user pressing up-down, but allows to avoid form submition after Return */
		selectFirst: true,

		formatItem: function(item) {
			return item[1];
		}
	}).result(function(event, item) {
			addAuthorList(item);
			$(this).val("");
			return false;
		});

});

