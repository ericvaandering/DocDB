// This code was in the CMS DocDB but was preventing the author fields from being pre-filled. It was removed as it doesn't
// seem to provide real value. Originally written by Vidmantis


      var docDB_temp_hacks = 0;


	  function extended_author_search(){
            jQuery.extend(jQuery.expr[':'], {
              'containsi': function(elem, i, match, array)
              {
                return (elem.textContent || elem.innerText || '').toLowerCase()
                .indexOf((match[3] || "").toLowerCase()) >= 0;
              }
            });
            jQuery.extend({URLEncode:function(c){var o='';var x=0;c=c.toString();var r=/(^[a-zA-Z0-9_.]*)/;
              while(x<c.length){var m=r.exec(c.substr(x));
                if(m!=null && m.length>1 && m[1]!=''){o+=m[1];x+=m[1].length;
                }else{if(c[x]==' ')o+='+';else{var d=c.charCodeAt(x);var h=d.toString(16);
                o+='%'+(h.length<2?'0':'')+h.toUpperCase();}x++;}}return o;},
            URLDecode:function(s){var o=s;var binVal,t;var r=/(%[^%]{2})/;
              while((m=r.exec(o))!=null && m.length>1 && m[1]!=''){b=parseInt(m[1].substr(1),16);
              t=String.fromCharCode(b);o=o.replace(m[1],t);}return o;}
            });


            // extract url parameter
            jQuery.extend({
              getUrlVars: function(){
                var vars = [], hash;
                var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
                for(var i = 0; i < hashes.length; i++)
                {
                  hash = hashes[i].split('=');
                  vars.push(hash[0]);
                  vars[hash[0]] = hash[1];
                }
                return vars;
              },
              getUrlVar: function(name){
                return jQuery.getUrlVars()[name];
              }
            });
                    
            var author_search = jQuery.getUrlVar('author');


            if (author_search){
                jQuery('h3').html(jQuery('<a href="#">show all authors</a>').click(function(){jQuery('table tr td ul li, table tr td a, table tr th').show(); })).show();


                jQuery('table tr td ul li, table tr td a, table tr th').hide();

                params = author_search.replace('.', ' ').replace('+', ' ').replace(',', ' ').split(' ')

                filtered = jQuery('table tr td ul li a')

                jQuery(params).each(function(i, param){
                    //TODO: handle special chars and international names
                    //console.log(param);

            		//clean up the string, leave only letters
            		param = param.replace(/[^a-zA-Z]/g, '');
            		if (!param)
            			return;

                    filtered = filtered.filter(':containsi('+param+')');
                });
                items = filtered.show().parent().show().addClass('search_matched')


            	//console.log(items)

            	/* If there was only one result, point to the documents by the author */
            	if (items.length == 1){
            		    var target = items.find("a").first().attr('href');
                        //console.log("Blah:"+target);
                        location.href = target;
            	}
            }

	  }


      function apply_cms_styles(){
            /* watermark the search */
			var searchField = jQuery('div#header-search-container input[type=text][name=simpletext]');
			/* we take the value of watermark from title attribute */
            searchField.watermark(searchField.attr('title'),  {className: 'watermark-search'});

            jQuery('div#header-search-container form').submit(function(e){
                //check if value has an ID
                var value =jQuery('input#header-search-input').val();
                //alert(value);
                var regexp = /id:(\\d+)/i;
                if (regexp.test(value)){
                    //alert('ID');
                    e.preventDefault();
                    value.match(regexp);
                    docid = RegExp.\$1;
                    window.location.href = 'ShowDocument?docid=' + docid
                }
            });


                /* hide keywords */
                if (jQuery('form#documentadd input[name=keywords]')) {
                    jQuery('form#documentadd input[name=keywords]').parents("tr").first().hide(); 
                }

                /* fix styles */
                for (i=1; i<1000; i=i+2){ 
                    if (!jQuery('input[name=upload'+i+']'))
                       break;
                   jQuery('input[name=upload'+i+']').parents('tr').first().addClass('FileUpload');
                   jQuery('input[name=filedesc'+i+']').parents('tr').first().addClass('FileUpload');
                   jQuery('input[name=fileid'+i+']').parents('tr').first().addClass('FileUpload');
                }




            if (docDB_temp_hacks){
                /* TODO: (temporaly) set up file input coloring */
                for (i=1; i<1000; i=i+2){
                    if (!jQuery('input[name=upload'+i+']'))
                       break;
                   jQuery('input[name=upload'+i+']').parents('tr').first().addClass('file-upload-row-odd');
                   jQuery('input[name=filedesc'+i+']').parents('tr').first().addClass('file-upload-row-odd');
                   jQuery('input[name=fileid'+i+']').parents('tr').first().addClass('file-upload-row-odd');
                }

                /* add select all button */
                if (jQuery('form#documentadd input[name=copyfile1]')){
                    jQuery('form#documentadd input[name=copyfile1]').parents("td").first().append('   <a>copy all files<a>').toggle(function(evt){evt.preventDefault();jQuery('[name^="copyfile"]').val(["on"])}, function(evt){evt.preventDefault();jQuery('[name^="copyfile"]').val([""])})
                }

           }


      }

		/*  ==========  set up the validation  =========== */
	  function form_add_validation(){

		jQuery.validator.messages.required = "";

		/* pre-validate the form */
		jQuery("form#documentadd").validate({onfocusout: true, onkeyup: true});
	  }


	  if (!(typeof jQuery === 'undefined') && !(typeof jQuery.validator === 'undefined')){
          jQuery(document).ready(function() {
                /* Here we could customize the validation (again) */
				form_add_validation();
          });
	  }

	  if (!(typeof jQuery === 'undefined')){
          jQuery(document).ready(function() {
                apply_cms_styles();
                extended_author_search();
                if (jQuery('form#documentadd select[name=security]').length == 1) { CmsTransformPermissions(); }
          });
      }


