function InsertKeyword (name) {
  var value = opener.document.getElementsByName("keywords")[0].value;
  if (value == '') {
    opener.document.getElementsByName("keywords")[0].value = name;
  } else {
    opener.document.getElementsByName("keywords")[0].value += ' ' + name;
  }
}
