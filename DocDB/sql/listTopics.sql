#
# List major and minor topics with minor topic descriptions and sorted by major topic
#
select MajorTopic.ShortDescription, MinorTopic.ShortDescription, MinorTopic.LongDescription
from MajorTopic, MinorTopic
where MajorTopic.MajorTopicID = MinorTopic.MajorTopicID ;
