function helppopupwindow(page) {
  window.open(page,"docdbhelp","width=450,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0");
}

function notepopupwindow(page){
  window.open(page,"docdbnote","width=700,height=600,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0");
}

function grouplimitpopupwindow(page){
  window.open(page,"grouplimit","width=450,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0");
}

function keywordchooserwindow(page){
  window.open(page,"KeywordChooser","width=800,height=600,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0");
}

function signoffchooserwindow(page){
  window.open(page,"SignoffChooser","width=400,height=500,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0");
}

function confirmtalkpopupwindow(theForm,confirm){
  var oUrl=confirm+"?documentid="+theForm.documentid.value+"&sessiontalkid="+theForm.sessiontalkid.value;
  window.open(oUrl,"confirmtalk","width=400,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0");
}

function confirmxfer(){
  var admaction_radiobutton= document.getElementsByName("admaction");
  var admaction_selected = document.getElementById("peraccount").elements["admaction"];
  var i;

  if (!admaction_selected.value) {
    for (i = 0; i < admaction_radiobutton.length; i++) {
      if (admaction_radiobutton[i].checked == true) {
        admaction_selected = admaction_radiobutton[i];
      }
    }
  }

  if (admaction_selected.value == "Transfer") {
    var cert1 = document.getElementById("peraccount").elements["emailuserid"];
    var cert2 = document.getElementById("peraccount").elements["newcertid"];

    if (cert1.selectedIndex != -1 && cert2.selectedIndex != -1 && cert1.selectedIndex != cert2.selectedIndex) {
      var cert1opt = cert1.options[cert1.selectedIndex];
      var cert2opt = cert2.options[cert2.selectedIndex];
      var cert1text = cert1opt.text;
      var cert2text = cert2opt.text;
      return confirm ("CAUTION: There is NO undo! Are you sure you want to transfer:\nFrom: " + cert1text + "\nTo:     " + cert2text);
    }
 }
  return (1);
}
