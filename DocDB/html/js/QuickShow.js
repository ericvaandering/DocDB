function unhideQuick() {
        domNode = document;
        searchClass = "QuickEntryHide";

        tagName = '*';
        var el = new Array();
        var tags = domNode.getElementsByTagName(tagName);
        var tcl = " "+searchClass+" ";
        for(i=0,j=0; i<tags.length; i++) {
                var test = " " + tags[i].className + " ";
                if (test.indexOf(tcl) != -1){
                        tags[i].className = tags[i].className.replace("QuickEntryHide","QuickEntryShow");
                }
        }
}
