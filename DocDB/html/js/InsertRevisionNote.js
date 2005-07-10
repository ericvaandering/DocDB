function InsertRevisionNote (note) {
  if (document.forms[0].revisionnote.value == '') {
    document.forms[0].revisionnote.value = note;
  } else {
    document.forms[0].revisionnote.value += note;
  }
}
