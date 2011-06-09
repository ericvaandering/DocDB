function InsertRevisionNote (note) {
  var value = document.getElementsByName("revisionnote")[0].value;
  if (value == '') {
    document.getElementsByName("revisionnote")[0].value = note;
  } else {
    document.getElementsByName("revisionnote")[0].value += note;
  }
}
