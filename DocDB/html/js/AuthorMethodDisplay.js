function author_method_choose(method) {
  if (method == "text") {
    document.getElementById("AuthorScroll").style.display = "none";
    document.documentadd.authormode.value = "field";
    document.getElementById("AuthorText").style.display   = "";
  }
  if (method == "scroll") {
    document.getElementById("AuthorScroll").style.display = "";
    document.documentadd.authormode.value = "list";
    document.getElementById("AuthorText").style.display   = "none";
  }
}

function author_method_choose_text(method) {
  if (method == "text") {
    document.getElementById("AuthorActiveSearch").style.display = "none";
    document.documentadd.authormode.value = "field";
    document.getElementById("AuthorText").style.display   = "";
  }
  if (method == "active") {
    document.getElementById("AuthorActiveSearch").style.display = "";
    document.documentadd.authormode.value = "list";
    document.getElementById("AuthorText").style.display   = "none";
  }
}
