#
# Description: Routines to deal with cookies
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2004 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License 
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

sub GetPrefsCookie {
  $UserIDPref       = $query -> cookie('userid');
  $UploadTypePref   = $query -> cookie('archive');
  $NumFilesPref     = $query -> cookie('numfile');
  $UploadMethodPref = $query -> cookie('upload');
  $TopicModePref    = $query -> cookie('topicmode');
  $AuthorModePref   = $query -> cookie('authormode');
  $DateOverridePref = $query -> cookie('overdate');
  $UserPreferences{AuthorID}     = $UserIDPref      ;
  $UserPreferences{UploadType}   = $UploadTypePref  ;
  $UserPreferences{NumFiles}     = $NumFilesPref    ;
  $UserPreferences{UploadMethod} = $UploadMethodPref;
  $UserPreferences{TopicMode}    = $TopicModePref   ;
  $UserPreferences{AuthorMode}   = $AuthorModePref  ;
  $UserPreferences{DateOverride} = $DateOverridePref;
}

1;
 
