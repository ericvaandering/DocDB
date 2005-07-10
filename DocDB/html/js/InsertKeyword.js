function InsertKeyword (name) {
  if (opener.document.forms[0].keywords.value == '') {
    opener.document.forms[0].keywords.value = name;
  } else {
    opener.document.forms[0].keywords.value += ' ' + name;
  }
}
