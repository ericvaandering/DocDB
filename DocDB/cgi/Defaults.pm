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

sub SetTopicMode {
  if ($params{topicmode}) {
    $TopicMode = $params{topicmode};
  } else {
    $TopicMode = $TopicModePref;
  }
  if ($TopicMode ne "single" && $TopicMode ne "multi") {
    $TopicMode = "multi";
  }  
}

sub SetUploadMethod {
  if ($params{upload}) {
    $Upload = $params{upload};
  } else {
    $Upload = $UploadMethodPref;
  }  
  if ($Upload ne "http" && $Upload ne "file") {
    $Upload = "file";
  }  
}

1;
