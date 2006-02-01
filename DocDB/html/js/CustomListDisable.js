function disabler_customlist(AllowEvent,AllowAll) {
  document.customlist.events.disabled       = true;
  document.customlist.eventgroups.disabled  = true;
  document.customlist.topics.disabled       = true;
  document.customlist.defaultlists.disabled = true;
  document.customlist.doctype.disabled      = true;
  
  if (AllowAll || document.customlist.scope[1].checked == true) {
    document.customlist.events.disabled       = false;
    document.customlist.eventgroups.disabled  = false;
    document.customlist.topics.disabled       = false;
    document.customlist.doctype.disabled      = false;
    document.customlist.defaultlists.disabled = false;
  }
  if (AllowEvent) {
    document.customlist.events.disabled      = false;
  } 
}

