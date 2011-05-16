function InsertKeyword (name) {
  var value = opener.document.getElementsByName("keywords")[0].value;
  if (value == '') {
    value = name;
  } else {
    value += ' ' + name;
  }
}
