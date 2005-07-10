function disabler_minortopic() {
  if (document.minortopic.admaction[0].checked == true) {
    document.minortopic.topics.disabled = true;
    document.minortopic.shortdesc.disabled = false;
    document.minortopic.longdesc.disabled = false;
    document.minortopic.majortopic.disabled = false;
  }
  if (document.minortopic.admaction[1].checked == true) {
    document.minortopic.topics.disabled = false;
    document.minortopic.shortdesc.disabled = true;
    document.minortopic.longdesc.disabled = true;
    document.minortopic.majortopic.disabled = true;
  }
  if (document.minortopic.admaction[2].checked == true) {
    document.minortopic.topics.disabled = false;
    document.minortopic.shortdesc.disabled = false;
    document.minortopic.longdesc.disabled = false;
    document.minortopic.majortopic.disabled = false;
  }
}

function disabler_majortopic() {
 if (document.majortopic.admaction[0].checked == true) {
   document.majortopic.shortdesc.disabled = false;
   document.majortopic.longdesc.disabled = false;
   document.majortopic.majortopic.disabled = true;
 }
 if (document.majortopic.admaction[1].checked == true) {
   document.majortopic.shortdesc.disabled = true;
   document.majortopic.longdesc.disabled = true;
   document.majortopic.majortopic.disabled = false;
 }
 if (document.majortopic.admaction[2].checked == true) {
   document.majortopic.shortdesc.disabled = false;
   document.majortopic.longdesc.disabled = false;
   document.majortopic.majortopic.disabled = false;
 }
}
