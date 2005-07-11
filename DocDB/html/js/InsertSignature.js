function InsertSignature (name) {
  if (opener.document.forms[0].signofflist.value == '') {
    opener.document.forms[0].signofflist.value = name;
  } else {
    opener.document.forms[0].signofflist.value += '\n' + name;
  }
}
