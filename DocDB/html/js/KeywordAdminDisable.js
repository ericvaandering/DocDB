function disabler_keywords() {
  if (document.keywords.admaction[0].checked == true) {
    document.keywords.shortdesc.disabled = false;
    document.keywords.longdesc.disabled = false;
    document.keywords.keywordgroup.disabled = false;
    document.keywords.keywordlist.disabled = true;
  }
  if (document.keywords.admaction[1].checked == true) {
    document.keywords.shortdesc.disabled = true;
    document.keywords.longdesc.disabled = true;
    document.keywords.keywordgroup.disabled = true;
    document.keywords.keywordlist.disabled = false;
  }
  if (document.keywords.admaction[2].checked == true) {
    document.keywords.shortdesc.disabled = false;
    document.keywords.longdesc.disabled = false;
    document.keywords.keywordgroup.disabled = false;
    document.keywords.keywordlist.disabled = false;
  }
}

function disabler_keygroups() {
  if (document.keygroups.admaction[0].checked == true) {
    document.keygroups.shortdesc.disabled = false;
    document.keygroups.longdesc.disabled = false;
    document.keygroups.keywordgroup.disabled = true;
  }
  if (document.keygroups.admaction[1].checked == true) {
    document.keygroups.shortdesc.disabled = true;
    document.keygroups.longdesc.disabled = true;
    document.keygroups.keywordgroup.disabled = false;
  }
  if (document.keygroups.admaction[2].checked == true) {
    document.keygroups.shortdesc.disabled = false;
    document.keygroups.longdesc.disabled = false;
    document.keygroups.keywordgroup.disabled = false;
  }
}
