// Adapted from code by Shawn Olson
// http://www.shawnolson.net/a/639/select-all-checkboxes-in-a-form-with-javascript.html

String.prototype.startsWith = function(str) {
  return (this.match('^'+str)==str)
}

function checkUncheckAll(theElement,startName) {
  var theForm = theElement.form, z = 0;
  for (z=0; z<theForm.length;z++) {
    if (theForm[z].type == 'checkbox' && theForm[z].name.startsWith(startName)) {
      theForm[z].checked = theElement.checked;
    }
  }
}
