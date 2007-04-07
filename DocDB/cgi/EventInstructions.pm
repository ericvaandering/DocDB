# Description: The instructions for the event organizer and calendar in DocDB. 
#              This is mostly HTML, but making  it a script allows us to eliminate
#              parts of it that we don't want and get it following everyone's
#              style, and allows groups to add to it with ProjectMessages.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2007 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub EventInstructionsSidebar {
  print <<TOC;
  <h2>Contents</h2>
  <ul>
   <li><a href="#intro">Introduction</a></li>
   <li><a href="#calendar">Calendar</a>
   <ul>
    <li><a href="#day">Daily view</a></li>
    <li><a href="#month">Monthly view</a></li>
    <li><a href="#year">Yearly view</a></li>
    <li><a href="#upcoming">Upcoming events</a></li>
   </ul></li>
   <li><a href="#create">Creating a New Event</a>
   <ul>
    <li><a href="#eventinfo">Event information</a></li>
    <li><a href="#sessions">Creating sessions</a></li>
   </ul></li> 
   <li><a href="#talks">Managing Talks in Sessions</a>
   <ul>
    <li><a href="#basicinfo">Basic information</a></li>
    <li><a href="#order">Ordering talks</a></li>
    <li><a href="#confirm">Confirming documents</a></li>
    <li><a href="#hints">Giving hints about talks</a></li>
   </ul></li>
   <li><a href="#modify">Modifying an Event</a></li>
   <li><a href="#matching">Matching agenda with documents</a>
   <ul>
    <li><a href="#userentry">User uploads</a></li>
    <li><a href="#hinting">DocDB guesses</a></li>
    <li><a href="#confirm2">Moderator confirms</a></li>
   </ul></li>
  </ul>
TOC
}

sub EventInstructionsBody {
  print <<HTML;
<a name="intro"/>
<h1>Introduction</h1>

<p>
The event organizer and calendar system provides the ability to set up events
with arbitrary numbers of sessions and breaks. Within each session, a moderator 
can set up an arbitrary number of talks
and small breaks, discussion sessions, etc. Each
talk has a running time and each session has a starting time. This creates a
time ordered agenda. Anything from an afternoon video conference to conferences
with parallel and plenary sessions can be organized with the organizer.
The calendar provides an easy way to see which events are scheduled.
</p>

<p>
These instructions refer to a "moderator" which is any user who is
authorized to organize an event. Several people can collaborate to organize an
event, but when changes collide or appear to collide, only the first is taken.
</p>

<a name="calendar"/>
<h1>Using the Calendar</h1>

<p>
DocDB supplies a calendar which shows upcoming and past events. 
The calendar also allows you easily create new events. 
There are four <q>views</q> which the calendar supplies; the first view you
will likely see is the month view. 
</p>

<a name="day"/>
<h2>Daily view</h2>

<p>The daily view shows a detailed list of a day's events. Events with no
sessions are shown first, followed by the various sessions taking place on that
day. Start and end times as well as locations and URLs (if any) are also shown.
Click on the link for the event to see the relevant agenda. At the
top of the page are buttons that can be used to schedule events for that day.
You can also click on the dates at the top of the page to view the next or
previous days, or to switch to the monthly or yearly views.</p>

<a name="month"/>
<h2>Monthly view</h2>

<p>The monthly view shows a whole month and an abbreviated list of the
events on each day. Start times  for events that have them are shown. If you
move your mouse over the event link, you will see more information. Click on the
links to see the agendas. At the top-left of each day is a link to the daily
view for that date. Click on the plus sign at the top-right to add a new event
on that date. You can also click on the month names at the top of the page to
view the next or previous month or click on the year to switch to the yearly
view.</p>

<p>If you are viewing the current month, the table of upcoming events is also
shown.</p>

<a name="year"/>
<h2>Yearly view</h2>

<p>The yearly view shows the calendar for a whole year. The linked dates are
days with events; click on a link to see the daily view for that day. Click on
the name of a month to see the monthly view for that month.   You can also click
on the years at the top of the page to view the next or previous year.</p>

<p>If you are viewing the current year, the table of upcoming events is also
shown.</p>

<a name="upcoming"/>
<h2>Upcoming events</h2>

<p>This view shows events scheduled for the next 60 days. The view is similar
to the day view in that titles, locations, and URLs are all shown. Click on the
links to view the agendas.</p> 

<a name="create"/>
<h1>Creating a New Event</h1>

<p>DocDB is capable of scheduling three kinds of events. Events with no sessions
(perhaps a conference someone from the group is attending), events with just one
session (a small meeting) or events with more than one session (a multi-day
meeting, perhaps with plenary and parallel sessions).</p>

<p>Begin by clicking the correct button on the <a href="$ModifyHome">Change or
Create</a> page according to how many sessions your event will have. (You can
always add sessions to existing events, so don't worry if you change your mind
later.) For creating an event with no sessions, follow just the instructions for
<a href="#eventinfo">Event information</a>.  For events with one session follow
the instructions for <a href="#eventinfo">Event information</a> (realizing that
some of the inputs described are not present), and then follow the instructions
for <a href="#talks">Managing Talks in Sessions</a>. For meetings with multiple
sessions, follow all these instructions.</p>

<a name="eventinfo">
<h2>Entering event information</h2>

<p>A list of the groups of events are shown; you must select one. You must also
provide a title, or short description,  and start and end dates for the event. 
A long description of the event, a location, and a URL (external homepage) are
all optional, but if they exist, you should supply them.  The "Show All Talks"
selection controls what the user sees when viewing a event. In the event view,
either all the sessions for an event with all their talks can be shown or just
links to the various sessions. This should probably be checked for events with
just a few dozen talks, but left unchecked for larger events.</p>

<p>The boxes labeled Event Preamble and Epilogue provide a space for text which
will be placed at the top and bottom respectively of the display of the
event. A welcome message or instructions can be placed here.</p>

<p>Finally, the View and Modify selections are used to control which groups may
view and modify the agenda for the events. The documents (talks) themselves
rely on their own security, not this setting.</p>

<p>The same form is used for modifying event information.</p>

<a name="sessions"/>
<h2>Creating Sessions</h2>

<p>On the same form used for creating or modifying an event, the moderator is
able to set up one or more sessions in the event. If there are not enough spaces
for all the needed sessions, don't worry; blank slots will be added after
"Submit" is pressed.</p>

<p>The order of these sessions is 
displayed and can be changed by entering new numbers in the Order column.
Decimal numbers are OK, so entering "1.5" will place the session between those
currently numbered "1" and "2."</p>

<p>Sessions may be designated as "Breaks" which cannot have talks associated with
them. Breaks can be used for entering meals or other activities.</p>

<p>Existing sessions can be deleted by checking the delete box.</p>

<p>For each session or break, a location (such as a room number) and starting
time should be entered. A session title should be entered and a longer
description of the session (such as an explanation of the topics covered) may
also be entered.</p>

<p>Once at least one session has been added to the event, talks can be
associated with the sessions.</p>

<a name="talks"/>
<h1>Adding and Modifying Talks in a Session</h1>

<p>To create or modify slots for talks in a session, either click on the "Modify
Session" button on the "Display Session" page or the "Modify Session Agenda"
link on the "Modify Event" page. For events with a single session, you will
modify event and talk information on the same page. The moderator may add as
many talks or breaks as needed (blank slots are created at the bottom after the
submit button is pushed). Breaks can be announcements, discussions, or coffee
breaks (any activity which won't have a document attached to it) during a
session.</p>

<p>To create an agenda, the moderator should enter as much information as needed
about each talk or break. The fields are described below.</p>

<a name="basicinfo"/>
<h2>Entering basic talk information</h2>

<p>For each talk, at least a suggested title and time (length) should be entered.
A note on each talk can also be entered, but these are only visible when
clicking on the "Note" link in the event or session displays.</p>

<a name="order"/>
<h2>Ordering the talks</h2>

<p>On the far left is the document order within the session. To reorder talks
within the session, just input new numbers and press "Submit." Decimal numbers
are allowed, so entering "1.5" will place that talk between the talks currently
numbered "1" and "2."</p>

<a name="confirm"/>
<h2>Specifying, deleting, and confirming documents</h2>

<p>On the form there are places to enter the document number of a talk if the
moderator already knows it, to confirm a suggestion by the DocDB, and to delete
the entry for a talk entirely. (This will NOT delete the document from the
database, just the entry for the event.)</p>

<p>A confirmed talk is one where the relationship between agenda entry and
document has been verified by a human, not guessed at by DocDB as explained
below. Unconfirmed talks are shown in <i>italics</i> type.</p>

<p>By checking the "Reserve" box when creating creating or updating an agenda, 
the moderator can create new documents with the title, authors, and topics chosen. 
Then, the author can upload document by updating this initial document. If you 
choose to do this, make sure the users understand that they are supposed
to update rather than create new documents.</p>

<p>If document numbers are entered manually, the "Confirm" box(es) must also be
checked, or DocDB will guess its own numbers instead.</p>

<a name="hints"/>
<h2>Giving hints about the talks</h2>

<p>Finally, the moderator may enter the suggested authors and topics for the talks
to be given. This has two purposes. First, before documents are entered into
the DocDB, attendees can more clearly see what the preliminary agenda is.
Secondly, this assists DocDB in finding the correct matches as described below.
</p>

<a name="modify"/>
<h1>Modifying an Event</h1>

<p>From the <a href="$ModifyHome">Create or Change</a> page, follow the link to
modify an existing event. Then select the event you wish to modify. You will see
the same page you used to create the event.  If you are a moderator, you will
also see buttons to modify events or sessions when you view those events or
sessions.</p>


<a name="matching"/>
<h1>How DocDB Matches Agenda Entries with Documents</h1>

<p>In addition to the moderator associating or reserving talks as described
above, there are two other ways documents are matched with agenda entries. The
first way is for the user themselves match the documents. The second way is to
let DocDB guess.</p>

<p>A suggested course of action for the moderator is to first encourage users to
match their talks as described below. Then the moderator confirms its correct
guesses,  and then inputs numbers manually to correct DocDB's incorrect guesses.
DocDB will not assign documents confirmed for another agenda entry to a second
entry, so confirming documents and letting it guess again may find correct
matches.</p>

<a name="userentry"/>
<h2>User selects the talk</h2>

<p>When a user presses the button at the top of a session or event display that
says "Upload a document," they will see a document entry form with one small
addition: a menu to select his or her talk from the list of talks for that event
or session that have not yet been entered. When the user selects his or her talk
from this list, it is entered into the agenda as a confirmed talk, just as if
the moderator had followed the instructions below.</p>

<a name="hinting"/>
<h2>DocDB selects based on hints</h2>

<p>For entries without a confirmed document, the DocDB will try to figure out
which agenda entry matches which document. To do this, the DocDB constructs a
list of documents which might match the entries in the agenda. It then compares
each of these documents against the items in the agenda and picks what it thinks
is the best document among them. This document becomes an unconfirmed match with
the entry in the agenda. If it guesses right, confirm the match by clicking the
confirm box.</p>

<p>The list of documents to check against comes from two sources. First
documents with modification times in a time window around the event dates are
considered. Second, documents associated with the event are considered.</p>

<p>
Documents are matched with the agenda entries using a scoring system that takes
into account several criteria:
<ul>
<li>Whether the document is associated with the event</li>
<li>If the document's topic(s) match those in the agenda</li>
<li>If the document's author(s) match those in the agenda</li>
<li>How well the title of the document matches the suggested title in the
agenda</li>
</ul></p>
 
<p>Points are assigned to documents for each of these criteria where the
document matches the agenda entry. For each agenda entry/document pair, a score
is calculated. If the score is high enough, that document is entered as an
unconfirmed match. When documents are confirmed, they are removed from
consideration, which may change which assignments DocDB makes.</p>

<p>The precise algorithm used in choosing the best match can be determined by
looking at the DocDB code. </p>

<a name="confirm2"/>
<h2>Moderator corrects and/or confirms</h2>

<p>As explained above, the final step in the process is for the moderator to
either confirm DocDB's correct guesses or  manually enter the correct document
number and check confirm. If a very good match for a suggested document is
found, a button to confirm the match will appear in the agenda.  In all cases,
clicking on "Note" in the agenda will pop up a window that will list all
possible matches, from best to worst. Click the relevant button to confirm the
match.</p>

<p> For very small events (just a few talks) moderators may wish to not use
hints at all and just manually enter the talks.</p>

HTML
}
 
1;
