# Routines to produce snippets of HTML dealing with topics (major and minor)

sub TopicListByID {
  my @topicIDs = @_;
  if (@topicIDs) {
    print "<b>Topics:</b><br>\n";
    print "<ul>\n";
    foreach $topicID (@topicIDs) {
      &FetchMinorTopic($topicID);
      my $topic_link = &TopicLink($topicID);
      print "<li> $topic_link </li>\n";
    }
    print "</ul>\n";
  } else {
    print "<b>Topics:</b> none<br>\n";
  }
}

sub TopicLink {
  my ($TopicID,$mode) = @_;
  
  require "TopicSQL.pm";
  
  &FetchMinorTopic($TopicID);
  my $link;
  $link = "<a href=$ListByTopic?topicid=$TopicID>";
  if ($mode eq "short") {
    $link .= $MinorTopics{$TopicID}{SHORT};
  } else {
    $link .= $MinorTopics{$TopicID}{FULL};
  }
  $link .= "</a>";
  
  return $link;
}

sub MeetingLink {
  my ($TopicID,$mode) = @_;
  
  require "TopicSQL.pm";
  
  &FetchMinorTopic($TopicID);
  my $link;
  $link = "<a href=$ListByTopic?topicid=$TopicID&mode=meeting>";
  if ($mode eq "short") {
    $link .= $MinorTopics{$TopicID}{SHORT};
  } else {
    $link .= $MinorTopics{$TopicID}{FULL};
  }
  $link .= "</a>";
  
  return $link;
}

sub TopicsTable {
  require "Sorts.pm";

  my $NCols = 4;
  my @MajorTopicIDs = sort byMajorTopic keys %MajorTopics;
  my @MinorTopicIDs = sort byTopic keys %MinorTopics;

  my $Col   = 0;
  print "<table cellpadding=10>\n";
  foreach my $MajorID (@MajorTopicIDs) {
    unless ($Col % $NCols) {
      print "<tr valign=top>\n";
    }
    print "<td><b>$MajorTopics{$MajorID}{SHORT}</b>\n";
    ++$Col;
    print "<ul>\n";
    foreach my $MinorID (@MinorTopicIDs) {
      if ($MajorID == $MinorTopics{$MinorID}{MAJOR}) {
        my $topic_link = &TopicLink($MinorID,"short");
        print "<li>$topic_link\n";
      }  
    }  
    print "</ul>";
  }  

  print "</table>\n";
}

1;
