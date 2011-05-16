function InsertSignature (name) {
  var value = opener.document.getElementsByName("signofflist")[0].value;
  if (value == '') {
    value = name;
  } else {
    value += '\n' +name;
  }
}
