sub SetAuthorMode {
  if ($params{authormode}) {
    $AuthorMode = $params{authormode};
  } else {
    $AuthorMode = $AuthorModePref;
  }    
  if ($AuthorMode ne "list" && $AuthorMode ne "field") {
    $AuthorMode = "list";
  }
}
1;
