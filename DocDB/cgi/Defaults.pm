#  Module Purpose:
#    Gather in one place all the routines that set the look and feel
#    of DocumentAddForm based on user selections, preferences, and defaults
#    (in that order)
#
#  Functions in this file:
#    
#    SetAuthorMode:   Selectable list or free-form text field
#    SetTopicMode:    Single or multiple selectable lists 
#    SetUploadMethod: File upload or HTTP fetch
#    SetDateOverride: Allows over-riding modification date  
#  

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

sub SetDateOverride {
  if ($params{overdate}) {
    $Overdate = $params{overdate};
  } else {
    $Overdate = $DateOverridePref;
  }  
}

1;
