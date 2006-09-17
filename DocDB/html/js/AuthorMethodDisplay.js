function author_method_choose(method) {
  if (method == "text") {
    document.getElementById("AuthorScroll").style.display = "none";
    document.getElementById("AuthorText").style.display   = "";
  }
  if (method == "scroll") {
    document.getElementById("AuthorScroll").style.display = "";
    document.getElementById("AuthorText").style.display   = "none";
  }
}
