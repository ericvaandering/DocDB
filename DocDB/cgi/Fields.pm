# Description: Variables for titles of fields
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

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
 

  
%FieldTitles = (
                Docid      => "$ShortProject-doc-#", Title      => "Title", 
                CanSign    => "Next Signature(s)",   Confirm    => "Confirm?",
                Updated    => "Last Updated",        Created    => "Created", 
                Author     => "Author(s)",           Edit       => "Edit",
                Events     => "Event(s)",            Files      => "File(s)",
                References => "References",          TalkTime   => "Start",
                Topics     => "Topic(s)",            TalkLength => "Length", 
                TalkNotes  => "Notes",               Abstract   => "Abstract",
                Blank      => "&nbsp;",              DocNotes   => "Notes & Changes",
                LongEvents => "Event(s)",            AuthorInst => "Author(s)", 
               );  
               
%FieldDescriptions = (%FieldTitles, # Take titles as defaults
                Confirm    => "Confirm Button",
                Updated    => "Date Last Updated",        
                Created    => "Date Created",        
                TalkTime   => "Talk Start Time",
                TalkLength => "Talk Length", 
                TalkNotes  => "Talk Notes",
                DocNotes   => "Document Notes & Changes",
                Edit       => "Edit Document/Agenda Info",
                Blank      => "Empty field (placeholder)",
                LongEvents => "Event(s) (Long Name)",            
                AuthorInst => "Author(s) and Institution", 
               );  
               
%DefaultFieldLists = (
                      "Default"             => ["Docid","Title","Author","Updated"], 
                      "Event Group Default" => ["Docid","Title","Events","Author","Updated"], 
                      "Meeting Mode"        => ["Docid","Title","Author","Updated"], 
                      "Conference Mode"     => ["Title","Events","Author","Files"],
                      "Publications"        => ["Title","References","Files"],
                      "Event Agenda"        => ["TalkTime","Title","Author","Topics","Files",
                                                "TalkLength","Edit"],
                     );               

1;
