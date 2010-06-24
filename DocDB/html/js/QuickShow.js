function getElementsByClass( searchClass, domNode, tagName) {
        if (domNode == null) domNode = document;
        if (tagName == null) tagName = '*';
        var el = new Array();
        var tags = domNode.getElementsByTagName(tagName);
        var tcl = " "+searchClass+" ";
        for(i=0,j=0; i<tags.length; i++) {
                var test = " " + tags[i].className + " ";
                if (test.indexOf(tcl) != -1)
                        el[j++] = tags[i];
        }
        return el;
}

function unhideQuick () {
  var hiddenElements = getElementsByClass("QuickEntryHide");
  for(i=0,j=0; i<hiddenElements.length; i++) {
    var hiddenElement = hiddenElements[i];
    hiddenElement.style.display = "";
  }
}