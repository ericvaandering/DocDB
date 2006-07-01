# Description: The generic instructions for DocDB. This is mostly HTML, but making 
#              it a script allows us to eliminate parts of it that we don't want
#              and get it following everyone's style, and allows groups to add
#              to it with ProjectMessages.
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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

sub AdminInstructionsSidebar {
  print <<TOC;
  <h2>Contents</h2>
  <ul>
   <li><a href="#basic">Basic Administration</a></li>
   <li><a href="#special">Specific Cases</a>
   <ul>
    <li><a href="#groups">Understanding groups</a></li>
    <li><a href="#personal">Personal accounts</a></li>
   </ul></li>
  </ul>
TOC
}

sub AdminInstructionsBody {
  print <<HTML;

  <a name="basic" />
  <h1>Admintering DocDB</h1>

  <p>DocDB comes with a full complement of administration pages which modify
  the underlying lists of meta-data.  Since these pages are used by very few
  people, you will find they are not as polished or fool-proof as the pages
  intended for regular users. However, you should become comfortable with using
  these pages. These pages have been written at various times, so some may be
  more user friendly than others. If you have a suggestion on how to improve
  particular pages, contact your maintainer or the developers. </p> 

  <p>While some conventions differ from page to page (see above), a few are consistent:</p>
  
  <ol>   
  <li>You must always supply the administrators password for every action. This
      is to remind you that you are doing something potentially harmful and to
      keep a casual user from exploiting unknown DocDB bugs and causing
      havoc.</li>
  <li>You must select an action from New, Modify, or Delete. This activates the
      parts of the user interface you may use. For Modify, you typically select  
      something to act on on the left and then change what you want to change on the 
      right. Usually if you leave something blank, no change will be made. In certain
      cases there are boxes to check which will clear lists like this.</li>
  <li>Be especially careful deleting things. Deleting and then adding the same thing
      back again is not the same thing. Every piece of meta-data (like an author) is
      just a number in the DB.</li>
  <li>Some more recent routines have a <strong>Force</strong> option. This is
      a  warning that you are about to do something destructive. For instance,
      if you  check <strong>Force</strong> and delete a group of users, you may
      end up making lots of documents public. We have tried to put the
      <strong>Force</strong> options where the need to stop mistakes is the
      greatest, but the flip side is that if you check these boxes, you can do
      severe damage to your underlying database. </li>
  <li>If you are unsure of what you are doing, ask your maintainer or even back
      up the DB before acting.</li>
  </ol>
  
  <a name="specific" />
  <h1>Specific Cases</h1>

  <a name="groups" />
  <h2>Administering groups</h2>
  
  <p>Groups are at the heart of the access control of DocDB and they are a
     little difficult to understand.</p>
  
  <p>Access to documents within the DocDB is controlled in several ways. A
     document may be tagged as accessible to a subset of groups. Additionally,
     each group may have a list of subordinate groups. Anything marked viewable
     by a subordinate is also viewable by its superior group. (This
     relationship does not extend to more than one generation, though.)</p>

  <p>Each group also has a flag determining whether that group is allowed to
     create new or modify existing documents. If a group is in the list of
     those allowed to modify a  document, it can change that document (assuming
     they also have the create/modify flag set). These group names must match
     those in the .htpasswd file although the comparison is not case
     sensitive.</p>

  <a name="personal" />
  <h2>Personal accounts</h2>
  
  <p>These are settings for users in DocDB. While you can see what their
     settings are  (e.g. which documents they are watching) you can only change
     things that they cannot, such as the password (unless using certificate
     authentication) and which groups they belong to. The user is expected to
     do everything else for themselves.</p>

HTML

}

1;
