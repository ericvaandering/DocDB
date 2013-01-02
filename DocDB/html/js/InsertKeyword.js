function InsertKeyword (name) {
  elem = opener.document.getElementsByName('keywords')[0];
  if (elem.value == '') {
    elem.value = name;
  } else {
    elem.value += ' ' + name;
  }
}
