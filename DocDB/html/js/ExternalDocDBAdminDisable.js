function disabler_externaldocdb() {
 if (document.externaldocdb.admaction[0].checked == true) {
   document.externaldocdb.externaldocdbs.disabled = true;
   document.externaldocdb.project.disabled        = false;
   document.externaldocdb.desc.disabled           = false;
   document.externaldocdb.puburl.disabled         = false;
   document.externaldocdb.privurl.disabled        = false;
 }
 if (document.externaldocdb.admaction[1].checked == true) {
   document.externaldocdb.externaldocdbs.disabled = false;
   document.externaldocdb.project.disabled        = true;
   document.externaldocdb.desc.disabled           = true;
   document.externaldocdb.puburl.disabled         = true;
   document.externaldocdb.privurl.disabled        = true;
 }
 if (document.externaldocdb.admaction[2].checked == true) {
   document.externaldocdb.externaldocdbs.disabled = false;
   document.externaldocdb.project.disabled        = false;
   document.externaldocdb.desc.disabled           = false;
   document.externaldocdb.puburl.disabled         = false;
   document.externaldocdb.privurl.disabled        = false;
 }
}
