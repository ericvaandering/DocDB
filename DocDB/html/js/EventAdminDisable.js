function disabler_event() {
  if (document.event.admaction[0].checked == true) {
    document.event.events.disabled = true;
  }
  if (document.event.admaction[1].checked == true) {
    document.event.events.disabled = false;
  }
  if (document.event.admaction[2].checked == true) {
    document.event.events.disabled = true;
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
