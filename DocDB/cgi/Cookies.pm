sub GetPrefsCookie {
  $UserIDPref     = $query -> cookie('userid');
  $UploadTypePref   = $query -> cookie('archive');
  $NumFilesPref     = $query -> cookie('numfile');
  $UploadMethodPref = $query -> cookie('upload');
  $TopicModePref    = $query -> cookie('topicmode');
  $AuthorModePref   = $query -> cookie('authormode');
  $DateOverridePref = $query -> cookie('overdate');
}

1;
 
