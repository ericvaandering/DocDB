function InsertSignature (name) {
  var value = opener.document.getElementsByName("signofflist")[0].value;
  if (value == '') {
    opener.document.getElementsByName("signofflist")[0].value = name;
  } else {
    opener.document.getElementsByName("signofflist")[0].value += '\n' +name;
  }
}
