function disabler_externaldocdb() {
 if (document.externaldocdb.admaction[0].checked == true) {
   document.externaldocdb.externaldocdbs.disabled = true;
   document.externaldocdb.project.disabled        = false;
   document.externaldocdb.desc.disabled           = false;
   document.externaldocdb.public.disabled         = false;
   document.externaldocdb.private.disabled        = false;
 }
 if (document.externaldocdb.admaction[1].checked == true) {
   document.externaldocdb.externaldocdbs.disabled = false;
   document.externaldocdb.project.disabled        = true;
   document.externaldocdb.desc.disabled           = true;
   document.externaldocdb.public.disabled         = true;
   document.externaldocdb.private.disabled        = true;
 }
 if (document.externaldocdb.admaction[2].checked == true) {
   document.externaldocdb.externaldocdbs.disabled = false;
   document.externaldocdb.project.disabled        = false;
   document.externaldocdb.desc.disabled           = false;
   document.externaldocdb.public.disabled         = false;
   document.externaldocdb.private.disabled        = false;
 }
}
