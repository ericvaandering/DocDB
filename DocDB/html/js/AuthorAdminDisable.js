function disabler_author() {
  if (document.author.admaction[0].checked == true) {
    document.author.middle.disabled = false;
    document.author.authors.disabled = true;
    document.author.first.disabled = false;
    document.author.inst.disabled = false;
    document.author.lastname.disabled = false;
  }
  if (document.author.admaction[1].checked == true) {
    document.author.middle.disabled = true;
    document.author.authors.disabled = false;
    document.author.first.disabled = true;
    document.author.inst.disabled = true;
    document.author.lastname.disabled = true;
  }
  if (document.author.admaction[2].checked == true) {
    document.author.middle.disabled = false;
    document.author.authors.disabled = false;
    document.author.first.disabled = false;
    document.author.inst.disabled = false;
    document.author.lastname.disabled = false;
  }
}

function disabler_institution() {
 if (document.institution.admaction[0].checked == true) {
  document.institution.shortdesc.disabled = false;
  document.institution.longdesc.disabled = false;
  document.institution.inst.disabled = true;
 }
 if (document.institution.admaction[1].checked == true) {
  document.institution.shortdesc.disabled = true;
  document.institution.longdesc.disabled = true;
  document.institution.inst.disabled = false;
 }
 if (document.institution.admaction[2].checked == true) {
  document.institution.shortdesc.disabled = false;
  document.institution.longdesc.disabled = false;
  document.institution.inst.disabled = false;
 }
}
