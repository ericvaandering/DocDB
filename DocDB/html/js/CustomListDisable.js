function disabler_customlist(AllowEvent,AllowAll) {
  document.customlist.events.disabled      = true;
  document.customlist.eventgroups.disabled = true;
  document.customlist.events.topics        = true;
  document.customlist.events.defaultlists  = true;
  if (AllowAll || document.event.scope[1].checked == true) {
    document.customlist.events.disabled      = false;
    document.customlist.eventgroups.disabled = false;
    document.customlist.events.topics        = false;
    document.customlist.events.defaultlists  = false;
  }
  if (AllowEvent) {
    document.customlist.events.disabled      = false;
  } 
}

