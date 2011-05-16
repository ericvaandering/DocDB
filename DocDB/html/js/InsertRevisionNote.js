function InsertRevisionNote (note) {
  var value = document.getElementsByName("revisionnote")[0].value;
  if (value == '') {
    value = note;
  } else {
    value += note;
  }
}
