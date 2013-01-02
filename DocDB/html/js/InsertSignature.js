function InsertSignature (name) {
  elem = opener.document.getElementsByName('signofflist')[0];
  if (elem.value == '') {
    elem.value = name;
  } else {
    elem.value += '\n' + name;
  }
}
