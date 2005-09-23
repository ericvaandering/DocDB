# Description: The instructions for the event organizer and calendar in DocDB. 
#              This is mostly HTML, but making  it a script allows us to eliminate
#              parts of it that we don't want and get it following everyone's
#              style, and allows groups to add to it with ProjectMessages.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub EventInstructionsSidebar {
  print <<TOC;
  <h2>Contents</h2>
  <ul>
   <li><a href="#intro">Introduction</a></li>
   <li><a href="#create">Creating an Event</a></li>
   <li><a href="#modify">Modifying an Event</a></li>
   <li><a href="#talks">Managing Talks</a>
   <ul>
    <li><a href="#basicinfo">Basic information</a></li>
    <li><a href="#order">Ordering talks</a></li>
    <li><a href="#confirm">Confirming documents</a></li>
    <li><a href="#hints">Talk Hints</a></li>
   </ul></li>
   <li><a href="#matching">Matching agenda with documents</a>
   <ul>
    <li><a href="#userentry">User selects</a></li>
    <li><a href="#hinting">DocDB guesses</a></li>
    <li><a href="#reserve">Moderator reserves</a></li>
    <li><a href="#confirm2">Moderator confirms</a></li>
   </ul></li>
  </ul>
TOC
}

sub EventInstructionsBody {
  print <<HTML;
<h1>Introduction</h1>

These instructions refer to a "moderator," but this is just any user with any
valid password who is organizing an event. Several people can collaborate to
organize an event, but where changes collide or appear to collide, only the
first is taken.
<p/>

The event organizer system provides the ability to set up events with
arbitrary numbers of sessions and breaks and order these sessions and breaks.
Within each session, a moderator can set up an arbitrary number of talks and
small breaks, discussion sessions, etc. These entries are also ordered. Each
talk has a running time and each session has a starting time. This determines a
time ordered
agenda. Anything from an afternoon video conference to conferences with
parallel and plenary sessions can be organized with this organizer.

<a name="create"/>
<h1>Creating a New Event</h1>

The first step in creating an event is to set up the sessions in the event.
You begin this process by clicking on "Oragnize a new event" from the DocDB
modifications page. Events can be
created as a subtopic in the DocDB or, for smaller events (perhaps by small
subgroups of people), not as a subtopic. Ask an administrator if you are unsure
if you should create a topic or not.
Whether the moderator chooses to create
a topic or not, all the functionality of the event organizer is still
available. A list of the groups of events are
shown; simply select one.<p/>

The "Show All Talks" selection controls what the user sees when viewing a
event.  In the event view, either all the sessions for an event with all
their talks can be shown or just links to the
various sessions. This should probably be checked for events with just a few
dozen talks, but left unchecked for larger events.<p/>

Space is provided to provide both long and short descriptions of the event.
If the event is being created with a subtopic, both of these descriptions are
used. If a subtopic is not being created, only the long description is used. Also
provided are spaces to specify a location and URL for the conference or event
along with the start and end dates.<p/>

The boxes labeled Event Preamble and Epilogue provide a space for text which
will be placed at the top and bottom respectively of the display of the
event. A welcome message or instructions can be placed here.<p/>

Finally, the View and Modify selections are used to control which groups may
view and modify the agenda for the events. The documents (talks) themselves
rely on their own security, not this setting.<p/>

A nearly identical form is used for modifying event information.  

<a name="sessions"/>
<h1>Creating Sessions</h1>

On the same form used for creating or modifying an event, the moderator is able
to set up one or more sessions in the event. If there are not enough spaces
for all the needed sessions, don't worry; blank slots will be added when
"Submit" is pressed.<p/>

The order of these sessions is 
displayed and can be changed by entering new numbers in the Order column.
Decimal numbers are OK, so entering "1.5" will place the session between those
currently numbered "1" and "2." <p/>

Sessions may be designated as "Breaks" which cannot have talks associated with
them. Breaks can be used for entering meals or other activities.<p/>

Existing sessions can be deleted by checking the delete box. <p/>

For each session or break, a location (such as a room number) and starting time should be entered. A
session title should be entered and a longer description of the session
(such as an explanation of the topics covered) may also be entered.<p/>

Once at least one session has been added to the event, talks can be associated
with the sessions.<p/>

<a name="talks"/>
<h1>Adding and Modifying Talks in a Session</h1>

To create or modify slots for talks in a session, either click on the "Modify Session" link
in the navigation bar on the "Display Session" page or the "Modify Talks" link
on the "Modify Event" page. This allows the moderator to add as many talks or
breaks as needed. In this context, breaks can be announcements, discussions,
or coffee breaks during a session (any activity which won't have a document
attached to it).<p/>

To create an agenda, the moderator should enter as much information as needed
about each talk or break. The fields are described below. While there are
usually several open slots for talks, blank ones are added when "Submit" is
pressed.

<a name="basicinfo"/>
<h2>Entering basic talk information</h2>

For each talk, at least a suggested title and time (length) should be entered.
A note on each talk can also be entered, but these are only visible when
clicking on the "Note" link in the event or session displays. 

<a name="order"/>
<h2>Ordering the talks</h2>

On the far left is the document order within the session. To reorder talks
within the session, just input new numbers and press "Submit." Decimal numbers
are allowed, so entering "1.5" will place that talk between the talks currently
numbered "1" and "2." 

<a name="confirm"/>
<h2>Specifying, deleting, and confirming documents</h2>

On the form there are places to enter the document number of a talk if the
moderator already knows it, to confirm a suggestion by the DocDB, and to delete
the entry for a talk entirely. (This will NOT delete the document from the
database, just the entry for the event.)<p/>

A confirmed talk is one where the relationship between agenda entry and document
has been verified by a human, not guessed at by DocDB as explained below.
Unconfirmed talks are shown in <i>italics</i> type.

If document numbers are entered manually, the "Confirm" box(es) must also be
checked, or DocDB will guess its own numbers instead.

<a name="hints"/>
<h2>Giving hints about the talks</h2>

Finally, the moderator may enter the suggested authors and topics for the talks
to be given. This has two purposes. First, before documents are entered into
the DocDB, attendees can more clearly see what the proposed agenda is.
Secondly, this assists DocDB in finding the correct matches as described below.

<a name="matching"/>
<h1>How the DocDB matches your entries with documents</h1>

In addition to the moderator associating talks as described above, there are
two other ways this can happen. The first way is to have the user themselves
match the talks. The second way is to let DocDB guess.<p/>

A suggested course of action for the moderator is to first encourage users to
match their talks as described below. Then let DocDB guess and, as the
moderator, confirm its correct guesses, let it guess again, and only then
input numbers manually or correct its incorrect guesses. DocDB will not assign
documents confirmed for another agenda entry to a second entry, so confirming
documents and letting it guess again will often find more matches. 

<a name="userentry"/>
<h2>User selects the talk</h2>

When a user follows the link at the top of a session or event display that says "Add a talk to this
event of conference," they will see a document entry form with one small addition: a menu to select
his or her talk from the list of talks for that event or session that have not yet been entered.
When the user selects his or her talk from this list, it is entered into the agenda as a confirmed
talk, just as if the moderator had followed the instructions below.

<a name="hinting"/>
<h2>DocDB selects based on hints</h2>

For entries without a confirmed document, the DocDB will try to figure out which agenda entry matches
which document. To do this, the DocDB constructs a list of documents which
might match the entries in the agenda. It then compares each of those
documents against the items in the agenda and pick what it thinks is the best
document among them. This document becomes an unconfirmed match with the entry
in the agenda. If it guesses right, confirm the document as discussed below.<p/>

The list of documents to check against comes from two sources. First documents
with modification times in a time window around the event dates are
considered. Second, if the event is associated with a topic (discussed
above), documents associated with that topic are considered.<p/>

Documents are matched with the agenda entries using a scoring system that takes
into account several criteria:
<ul>
<li>Whether the document is associated with the event topic</li>
<li>If the document's topic(s) match those in the agenda</li>
<li>If the document's author(s) match those in the agenda</li>
<li>How well the title of the document matches the suggested title in the
agenda</li>
</ul>
 
Documents that are associated with the event receive a bonus over
documents that just happen to fall in the time window. Points are also assigned
to documents for each author or topic that matches those suggested in the
agenda and for matching words in the titles. For each agenda entry/document
pair, a score is calculated and the document with the highest score is entered
as the unconfirmed match. When documents are confirmed, they are removed from
consideration, which may change which assignments DocDB makes.<p/>

The precise algorithm used in choosing the best match can be determined by
looking at the DocDB code. <p/>

<a name="reserve"/>
<h2>Moderator reserves initial documents</h2>

<a name="confirm2"/>
<h2>Moderator corrects and/or confirms</h2>

Finally, a moderator can manually enter document numbers and check "Confirm" or
just check "Confirm" to verify DocDB's choices. When managing an event, it is
a good idea to periodically confirm unconfirmed documents for two reasons.
First, the DocDB might find a better match which is <b>not</b> correct. Second,
confirming documents removes them from the list of considered documents often
allowing the DocDB to find correct matches for remaining entries in the
agenda.<p/>

For very small events (just a few talks) moderators may wish to not use hints
at all and just manually enter the talks.<p/>

HTML
}
 
1;
