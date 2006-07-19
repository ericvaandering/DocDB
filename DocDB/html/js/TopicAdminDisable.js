function disabler_topic() {
  if (document.topic.admaction[0].checked == true) {
    document.topic.topics.disabled      = true;
    document.topic.shortdesc.disabled   = false;
    document.topic.longdesc.disabled    = false;
    document.topic.parenttopic.disabled = false;
  }
  if (document.topic.admaction[1].checked == true) {
    document.topic.topics.disabled      = false;
    document.topic.shortdesc.disabled   = true;
    document.topic.longdesc.disabled    = true;
    document.topic.parenttopic.disabled = true;
  }
  if (document.topic.admaction[2].checked == true) {
    document.topic.topics.disabled      = false;
    document.topic.shortdesc.disabled   = false;
    document.topic.longdesc.disabled    = false;
    document.topic.parenttopic.disabled = false;
  }
}
