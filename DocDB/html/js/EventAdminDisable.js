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

function disabler_eventgroup() {
 if (document.eventgroup.admaction[0].checked == true) {
   document.eventgroup.shortdesc.disabled = false;
   document.eventgroup.longdesc.disabled = false;
   document.eventgroup.eventgroups.disabled = true;
 }
 if (document.eventgroup.admaction[1].checked == true) {
   document.eventgroup.shortdesc.disabled = true;
   document.eventgroup.longdesc.disabled = true;
   document.eventgroup.eventgroups.disabled = false;
 }
 if (document.eventgroup.admaction[2].checked == true) {
   document.eventgroup.shortdesc.disabled = false;
   document.eventgroup.longdesc.disabled = false;
   document.eventgroup.eventgroups.disabled = false;
 }
}
