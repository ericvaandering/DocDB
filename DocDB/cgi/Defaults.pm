#  Module Purpose:
#    Gather in one place all the routines that set the look and feel
#    of DocumentAddForm based on user selections, preferences, and defaults
#    (in that order)
#
#  Functions in this file:
#    
#    SetAuthorMode:    Selectable list or free-form text field
#    SetTopicMode:     Single or multiple selectable lists 
#    SetUploadMethod:  File upload or HTTP fetch
#    SetDateOverride:  Allows over-riding modification date  
#    SetAuthorDefault: Sets Author and Requester defaults to cookie value
#    SetFileOptions:   Sets archive mode and number of uploads

# Copyright 2001-2009 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA


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

sub SetFileOptions {
  my ($DocRevID) = @_;

  if ($params{archive}) {
    $Archive = $params{archive};
  } else {
    $Archive = $UploadTypePref
  }  

  if ($Archive eq "single") {$NumberUploads = 3;}  # Make sure
  if ($Archive eq "multi")  {$Archive = "single";} # No real difference
  if ($Archive ne "archive" && $Archive ne "single") {
    $Archive = "single";
  }  
  
  if ($params{numfile}) {               # User has selected
    $NumberUploads = $params{numfile};
  } elsif ($NumFilesPref && $mode ne "update") {             # User has a pref
    if ($Meeting  || $OtherMeeting) {
      if ($NumFilesPref < 3) {
        $NumberUploads = 3;
      } else {   
        $NumberUploads = $NumFilesPref;
      }  
    } else {  
      $NumberUploads = $NumFilesPref;
    }   
  } else {                              # No selection, no pref
    if ($Meeting  || $OtherMeeting) {
      $NumberUploads = 3;
    } elsif ($mode eq "update") {
      my @DocFiles = &FetchDocFiles($DocRevID);
      $NumberUploads = @DocFiles; # FIXME: One line with scalar
      unless ($NumberUploads) { # Gyrations to handle docs that have 0 files
        $NumberUploads = 3;
      }  
    } else {
      $NumberUploads = 3;
    }  
  }
}


1;
