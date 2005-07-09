function helppopupwindow(page) {
  window.open(page,"docdbhelp","width=450,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0");
}

function notepopupwindow(page){
  window.open(page,"docdbnote","width=800,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0");
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
  
