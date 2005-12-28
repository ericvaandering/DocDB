function disabler_customlist(AllowEvent,AllowAll) {
  document.event.events.disabled      = true;
  document.event.eventgroups.disabled = true;
  document.event.events.topics        = true;
  document.event.events.defaultlists  = true;
  if (AllowAll || document.event.scope[1].checked == true) {
    document.event.events.disabled      = false;
    document.event.eventgroups.disabled = false;
    document.event.events.topics        = false;
    document.event.events.defaultlists  = false;
  }
  if (AllowEvent) {
    document.event.events.disabled      = false;
  } 
}

