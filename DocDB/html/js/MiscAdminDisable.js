function disabler_documenttype() {
  if (document.documenttype.admaction[0].checked == true) {
    document.documenttype.doctype.disabled = true;
    document.documenttype.longdesc.disabled = false;
    document.documenttype.name.disabled = false;
  }
  if (document.documenttype.admaction[1].checked == true) {
    document.documenttype.doctype.disabled = false;
    document.documenttype.longdesc.disabled = true;
    document.documenttype.name.disabled = true;
  }
  if (document.documenttype.admaction[2].checked == true) {
    document.documenttype.doctype.disabled = false;
    document.documenttype.longdesc.disabled = false;
    document.documenttype.name.disabled = false;
  }
}

function disabler_journals() {
 if (document.journals.admaction[0].checked == true) {
   document.journals.abbr.disabled = false;
   document.journals.acronym.disabled = false;
   document.journals.url.disabled = false;
   document.journals.name.disabled = false;
   document.journals.pub.disabled = false;
   document.journals.journal.disabled = true;
 }
 if (document.journals.admaction[1].checked == true) {
   document.journals.abbr.disabled = true;
   document.journals.acronym.disabled = true;
   document.journals.url.disabled = true;
   document.journals.name.disabled = true;
   document.journals.pub.disabled = true;
   document.journals.journal.disabled = false;
 }
 if (document.journals.admaction[2].checked == true) {
   document.journals.abbr.disabled = false;
   document.journals.acronym.disabled = false;
   document.journals.url.disabled = false;
   document.journals.name.disabled = false;
   document.journals.pub.disabled = false;
   document.journals.journal.disabled = false;
 }
}

function disabler_conferences() {
  if (document.conferences.admaction[0].checked == true) {
    document.conferences.location.disabled = false;
    document.conferences.longdesc.disabled = false;
    document.conferences.conftopic.disabled = true;
    document.conferences.endyear.disabled = false;
    document.conferences.startyear.disabled = false;
    document.conferences.endmonth.disabled = false;
    document.conferences.shortdesc.disabled = false;
    document.conferences.endday.disabled = false;
    document.conferences.majortopic.disabled = false;
    document.conferences.url.disabled = false;
    document.conferences.startday.disabled = false;
    document.conferences.startmonth.disabled = false;
  }
  if (document.conferences.admaction[1].checked == true) {
    document.conferences.location.disabled = true;
    document.conferences.longdesc.disabled = true;
    document.conferences.conftopic.disabled = false;
    document.conferences.endyear.disabled = true;
    document.conferences.startyear.disabled = true;
    document.conferences.endmonth.disabled = true;
    document.conferences.shortdesc.disabled = true;
    document.conferences.endday.disabled = true;
    document.conferences.majortopic.disabled = true;
    document.conferences.url.disabled = true;
    document.conferences.startday.disabled = true;
    document.conferences.startmonth.disabled = true;
  }
  if (document.conferences.admaction[2].checked == true) {
    document.conferences.location.disabled = false;
    document.conferences.longdesc.disabled = false;
    document.conferences.conftopic.disabled = false;
    document.conferences.endyear.disabled = false;
    document.conferences.startyear.disabled = false;
    document.conferences.endmonth.disabled = false;
    document.conferences.shortdesc.disabled = false;
    document.conferences.endday.disabled = false;
    document.conferences.majortopic.disabled = false;
    document.conferences.url.disabled = false;
    document.conferences.startday.disabled = false;
    document.conferences.startmonth.disabled = false;
  }
}
