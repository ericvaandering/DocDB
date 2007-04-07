# Description: The generic instructions for DocDB. This is mostly HTML, but making 
#              it a script allows us to eliminate parts of it that we don't want
#              and get it following everyone's style, and allows groups to add
#              to it with ProjectMessages.
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

sub GeneralInstructionsSidebar {
  if ($Public) {
    print <<TOC;
    <h2>Contents</h2>
    <ul>
     <li><a href="#about">About DocDB</a></li>
     <li><a href="#find">Finding Documents</a></li>
     <li><a href="#more">More Information</a></li>
    </ul>
TOC
  } else {

    print <<TOC;
    <h2>Contents</h2>
    <ul>
     <li><a href="#entering">Entering or Updating a Document</a>
     <ul>
      <li><a href="#morehelp">Getting more help</a></li>
      <li><a href="#modtypes">What do you want to do?</a></li>
      <li><a href="#prepare">Preparing your document for upload</a>
      <ul>
       <li>Multiple file uploads</li>
       <li>Archive uploads</li>
      </ul></li>
      <li><a href="#upload">Upload methods</a></li>
      <li><a href="#filling">Filling in the form</a></li>
      <li><a href="#advanced">Advanced options</a></li>
     </ul></li>
     <li><a href="#special">Special Cases</a>
     <ul>
      <li><a href="#meeting">Documents for events</a></li>
      <li><a href="#conference">Conference talks and proceedings</a></li>
      <li><a href="#reference">Publications in refereed journals</a></li>
     </ul></li>
     <li><a href="#prefsandemail">Preferences and E-mail Notification</a>
     <ul>
      <li><a href="#prefs">Setting preferences</a></li>
      <li><a href="#email">Setting e-mail notification</a></li>
     </ul></li>
TOC
    if ($UseSignoffs) {
     print "<li><a href=\"#signoff\">Document Signoffs</a></li>\n";
    } 
    print <<TOC;
     <li><a href="#advancedusers">Advanced Users</a></li>
     <li><a href="#philosophy">Final Words</a>
     <ul>
      <li><a href="#annoyances">Javascript, pop-ups, etc.</a></li>
      <li><a href="#archive">Archive vs. Catalog</a></li>
      <li><a href="#whatis">What is a document?</a></li>
      <li><a href="#formats">Notes on file formats</a></li>
     </ul></li>
    </ul>
TOC
  }

}

sub GeneralInstructionsBody {
  if ($Public) {

  print '
  <a name="about" />
  <h1>About DocDB</h1>
  <p>Only some of the documents in DocDB are publicly accessible. 
  If you try to access documents that are not visible to the public, 
  you will receive an error. Also, all of the interface for creating new documents
  is hidden from you. '; 
  
  if ($PrivateRoot || $secure_root) {
    my $PrivateDocDB = $PrivateRoot."/DocumentDatabase";
    my $SecureDocDB  = $secure_root."/DocumentDatabase";
    print 'If you arrived to this public interface by mistake and wish to add a document
           you must use the private interface instead. These links may help you: 
           <ul>';
    if ($PrivateRoot) {
      print "<li><a href=\"$PrivateDocDB\">Private DocDB Homepage</a> (password protected)</li>\n";
    }
    if ($secure_root) {
      print "<li><a href=\"$SecureDocDB\">Secure DocDB Homepage</a> (valid certificate required)</li>\n";
    }
    print 'If you need more assistance, please ask your DocDB administrator';
  } else {
    print 'If you arrived to this public interface by mistake and wish to add a document
           you must use the private interface instead. If you don\'t know how to find it,
           ask your DocDB administrator';
  }
  print <<HTML;
  </p>
  <p>A <q>document</q> consists of a number of files along with 
  additional information about the document.</p> 

  <a name="find" />
  <h1>Finding Documents</h1>

  <p>If you are looking for a specific document and know its document number, 
  the easiest thing is to just enter the number in the box on the <a href="$MainPage">home page</a>.
  If you are looking for documents by a certain person or on a certain topic,
  you might want to see the <a href="$ListTopics">list of topics</a> or 
  <a href="$ListAuthors">list of authors</a>. 
  A full fledged <a href="$SearchForm">search engine</a> is also available.
  </p> 


  <a name="more" />
  <h1>More Information</h1>

  <p>If you want more information about how DocDB works or would like to use it for
  your own project, please visit the <a href="$DocDBHome">DocDB homepage.</a></p> 

HTML

  } else {

  print <<HTML;

  <a name="entering" />
  <h1>Entering or updating a document in the database</h1>

  <p>Creating a document will be most users first experience with DocDB. 
  Read the next few sections to help you get an idea of what you can do and how 
  to proceed. Follow the link to "Create or change documents or other information" 
  to begin.</p> 

  <a name="morehelp" />

  <h2>Getting More Help</h2>

  <p>You can often get more help when using DocDB by clicking on <span class="Help">red terms</span> on the
  page. A small window will pop up to explain what is going on.</p>

  <p>If you don't find your answer in the pop-up or  if you have additional
  questions or problems with the DocDB, please send e-mail to the <a
  href="mailto:$DBWebMasterEmail">DocDB administrators</a>.</p>

  <p>For a more technical document on how the database works, see 
  <a href="http://www-btev.fnal.gov/cgi-bin/public/DocDB/ShowDocument?docid=140">
  BTeV-doc-140</a>.</p> 

  <a name="modtypes" />
  <h2>What do you want to do?</h2>

  <p>You can add information or documents to the database in five different ways for
  five different situations:</p>

  <div>
  <ol class="IEWrap">
  <li><strong>Reserve a document #: </strong>You want a number for a document
  you are going to write, but don't have a draft of the document.</li>
  <li><strong>New document: </strong>You have a new document ready to be put into the
  database. This document has not been entered or reserved before.</li>
  <li><strong>Update document: </strong>You want to upload a new version of a document that is already in the
  database. You will also be able to change any of the information in the
  database about the document. You must supply a document number to modify.</li>
  <li><strong>Update database information: </strong>The document hasn't changed, but the
  information about it has. For example, it's now published so you want to add
  that information. You must supply a document number to modify.</li>
  <li><strong>Add files to document:</strong> Perhaps you forgot a file initially, or maybe
  now you have a PDF file to go with the PowerPoint file already
  present. You can add these files to an existing version of a document. If the
  content has changed at all, you should use the Update, not the Add File, option.</li>
  </ol>
  </div>

  <p>
  Select the type of modification appropriate to your situation. 
  </p>

  <a name="prepare" />
  <h2>Preparing your document for upload</h2>

  <p>
  If your document just consists of just a few files, say a PDF and PowerPoint, and 
  they are on the computer
  you are using or accessible by the web, you are prepared. Better yet, you will
  probably be able to use one of the shortcuts at the top of the page. Skip
  ahead to the next section.</p>
  <p>
  If your document is in a lot of pieces, say a bunch of HTML files, 
  you have a decision to make. Do you want
  to specify each file you want to upload or do you want to make everything into
  an archive (like a .tar or .zip file) and upload that? In either case, you might
  have to use the advanced form in the middle of the "Create or Change" web page.
  (The short cuts allow you to upload multiple files if you don't want to choose
  any other advanced options.)</p>
  <p>
  <strong>Multiple file uploads:</strong>
  When you upload things this way, it might be a little bit more
  work, but what the end user will see is usually clearer. To upload your file
  this way, select "Multiple files" under "Upload Type" and type the number of
  files in your document in the box that says "# of files." The pros of using
  this upload method are that you (optionally) get to describe each of your files
  in the document and that you don't have to spend time preparing an archive.
  </p>

  <p>
  When using multiple file upload, you should also understand the concept of Main
  and supporting files. Main files are typically the ones you want people to look
  at. As an example, the top file of several linked HTML files is a "Main" file,
  the others are "Other" files. By default, all files are "Main" files. To mark
  additional files as "Other" un-check the appropriate boxes.
  </p>

HTML

  if ($Preferences{Options}{AlwaysRetrieveFile} || $UserValidation eq "certificate") {

    print <<HTML;
  <p><strong>Note on HTML uploads:</strong>
  Remember that the purpose of the document database is to store your
  <i>complete</i> document. If you have a number of HTML pages all linked
  together, things may appear to "work" just fine if you only upload the first
  one. There is no mechanism to prevent you from doing this. However, please
  don't do this. Upload all the files so that they <i>all</i> reside on the
  server, including images. To
  make the links in your HTML work on the server, use  RetrieveFile links as described
  in the 
HTML

    print "<a href=\"$DocDBInstructions?set=advanced#refer\">Referring to your 
           document and its files</a> section.</p>\n";
  } else {

    print <<HTML;


  <p><strong>Archive uploads:</strong>
  Another way to upload multiple files is to place all the files into an
  archive. Currently accepted formats are .tar (Unix tape archives), .tar.gz/.tgz
  (compressed .tar files), and .zip (Windows ZIP files). To use this option,
  select "Archive Upload" under "Upload Type." When you upload your archive you
  will be asked for two additional pieces of information. You will be asked for
  the filename of the main file in the archive and to describe that file. Through
  that one file, the user should be able to access the other files. For this
  reason, this uploaded file should probably be HTML. The pros of this method are
  that you don't have to describe or enter every file in the form.
  </p>

  <p>
  When uploading via archive mode, the Main file will be marked as such and the
  entire archive will be marked as an "Other" file.
  </p>

  <p><strong>Note on HTML uploads:</strong>
  Remember that the purpose of the document database is to store your
  <i>complete</i> document. If you have a number of HTML pages all linked
  together, things may appear to "work" just fine if you only upload the first
  one. There is no mechanism to prevent you from doing this. However, please
  don't do this. Upload all the files so that they <i>all</i> reside on the
  server, including images. To
  make the links in your HTML work on the server, use links like</p>
  <pre>
  &lt;a href="myotherpage.html"&gt; or &lt;a href="mysubdir/myotherpage.html"&gt; 
  </pre>
  <p>rather than</p> 
  <pre>
  &lt;a href="http://some.server.com/myotherpage.html"&gt;
  </pre>
  <p>
  since in the second form, your document will still point outside of the database
  server to files which may disappear.
  </p>
HTML

  }

  print <<HTML;

  <a name="upload" />
  <h2>Upload methods</h2>

  Once your document is prepared, you have one more decision to make. How do you
  want to get the file(s) to the document database? You have two choices:

  <ol>
  <li>You can upload files from your local computer. In this case, you will get
  boxes to type the file names into and (probably) a "Browse" button that will
  allow you to pick the file from a list. (How this happens depends on your
  browser and operating system.)</li> 
  <li>You can upload files by supplying a URL. You have to make sure the files
  are accessible from the web, but they can be password protected (you will have
  to supply the password). You will have to specify the full URL, including the
  "http://" or "https://" at the beginning and a filename at the end (you may not
  end the URL with "/"). Currently "https://" (secure upload) does not work, but
  we hope this will change in the near future.</li> 
  </ol>

  <a name="filling" />
  <h2>Filling in the form</h2>

  <p>Now that you've decided what you want to do and how you want to get any required
  files from your computer into the document database, you've presumably pressed
  one of the buttons that lets you add information into the database.</p>

  <p>You are now presented with an initially daunting form asking for all kinds of
  information about your document. A lot of the fields are required, but some are
  optional. The required fields are indicated. You can click on any <span class="Help">red link</span> to get a quick
  help window that tells you what you are being asked for. Instructions for every
  piece of information are not reproduced here, just click on the <span class="Help">red link</span> 
  if anything is not obvious.</p>

  <p>Also, note that lots of things can have more than one selection. For instance,
  your document can have several topics selected. How this is done varies by
  browser; some browsers require holding Ctrl and clicking to make multiple
  selections, others just click to select and deselect.</p>

  <p>
  When <strong>reserving</strong> a document, you must supply:</p>
  <ul>
   <li>A title </li> 
   <li>A requester (who is requesting the document?)</li> 
   <li>A document type (talk, note, etc.)</li> 
  </ul>

  <p>
  When <strong>adding</strong> a new document, you must supply all of the above plus:</p>
  <ul>
   <li>An abstract</li> 
   <li>Authors (one required, multiples OK)</li> 
   <li>Topics (one required, multiples OK)</li> 
   <li>At least one file</li> 
  </ul> 
  <p>and optionally:</p>
  <ul>
   <li>Keywords: These can be anything, but check with your group and/or subgroups
       as standards may exist.</li> 
   <li>Meetings, conferences, or other events</li>    
   <li>Notes and changes: What changed in this version?</li> 
   <li>Security settings (blank is the same as public, multiples OK)</li> 
   <li>A journal reference (you can add more later)</li> 
   <li>A note explaining any publication information</li> 
  </ul>

  <p>
  When <strong>updating</strong> a document, you can change all the information above.
  However, all the forms should be pre-filled for you with the information from
  the previous version. You will either have to supply <i>all</i> the files you want to
  be in the new version, or choose to have unchanged files copied to the next version.</p>

  <p>
  Finally, <strong>updating the database information</strong> about the document is similar to
  updating the document except for two things. First, you can't supply new
  files. Second, a new version number <i>is not</i> created.</p>

  <a name="advanced" />
  <h2>Advanced options</h2>

  <p> 
  The advanced form provides a few other options that might be useful.</p> 

  <p>
  <strong>Topic Selection: </strong>
  You can either select the topics(s) for your document from a number of
  shorter lists split up by parent topic (the default) or from one long
  list.</p> 

  <p>
  <strong>Author Selection: </strong> You can either select the author(s) for your document
  from a long list (the default) or by typing the author list into a text box.
  Using the second method, each author is checked against the master list and the
  document will not be placed in the database until every author you've typed in
  has a unique match. You can type in full first names or first initials (middle initials
  are ignored); the matching is <i>reasonably</i> intelligent.</p>

  <p><strong>Overriding the submission date: </strong> Using this option will give you another
  control on the entry form to set the date and time for a document written in
  the past. Unless you are submitting a document from the old database or one
  written  some time ago, you should probably not select this option. By default,
  new documents are entered with the current date and time.</p>

  <a name="special" />
  <h1>Special Cases</h1>

  <a name="meeting" />
  <h2>Documents for Events</h2>

  <p>These can be entered into the database using the normal entry
  form, just make sure you choose the appropriate event for your talk. </p>

  <a name="conference" />
  <h2>Conference Talks and Proceedings</h2>

  <p>Conference documents are added just like any other document, except for one extra step. 
  Before entering the document, you probably need to 
  <a href="$ConferenceAddForm">add some
  information</a> into the database about your conference. Do this by following
  the link on the 
  <a href="$ModifyHome">Create or Change</a> page.
  But before you add it, make sure someone else didn't already do it for you. (At
  the bottom of the add form is the list of conferences the database knows
  about).</p>

  <p>Also make sure that you select
  the conference from the list of events. This way your document is
  associated with the right conference.</p>

  <a name="reference" />
  <h2>Publications in Refereed Journals</h2>

  <p>Above the free-form "Publication Information" field is a place to select a
  journal, volume, and page for your document if it is published. If you need a
  journal added, let the database administrators know.</p>

  <a name="prefsandemail" />
  <h1>Preferences and E-mail Notification</h1>

  <a name="prefs" />
  <h2>Setting preferences</h2>

  <p>Setting preferences with the Document Database allows you to configure the
  default entry
  forms to your liking and to save some typing by telling the database who you
  are. </p>

  <p>Once the database knows who you are, your name will be pre-selected as the requester and
  author of new documents. You can, of course, change this setting to enter
  documents by people other than (or in addition to) yourself.</p>

  <p>You can also set your document entry preferences, so for instance if you often
  find yourself submitting URLs instead of files, you may wish to select HTTP
  submission as your default file submission method. You can always use the
  <q>Customized Insert/Modify</q> form to over-ride any preferences.</p>

  <p>To set your preferences, follow the link from the main Document Database page.
  Also, make sure your browser will accept cookies, at least for the DocDB web
  server.</p>

  <a name="email" />
  <h2>Setting e-mail notification</h2>

  <p>By following the link for "Your Account" from the main page, you can
  request to be notified of new documents or documents that change. You are
  notified only for documents on topics that you select. You can choose to be
  notified immediately, once a day, and/or once a week. For each time period, you
  can choose which documents to be notified about. So, for instance, you could
  choose to be notified immediately if a new document is created about your
  detector and every week about all new documents in the database.</p> 

HTML

  if ($UseSignoffs) {
   print "<a name=\"signoff\" /><h1>Document Signoffs</h1>\n";

   print "<p>An optional component of DocDB is to allow some documents to be <q>signed</q>
   by a group of people before becoming <q>approved.</q> People with <strong>Personal
   Accounts</strong> can sign documents. The list of people needing to approve a
   document is editable by the same groups that can edit the document itself.</p> 
   <p>
   To <q>freeze</q> a document and its meta-information such that only
   <q>managers</q> can modify it or unfreeze it, ask the 
   <a href=\"mailto:$DBWebMasterEmail\">DocDB
   administrators</a> for the procedure.</p>\n";

   print "<p>When displaying document version(s) in a list, there are obvious indications of
  which documents are approved, which are unapproved, and which are obsolete
  (even if they were approved at some time). All information about who <q>signed</q>'
  each version of each document is kept.</p>\n";

   print "<p>DocDB contains the ability to allow any number of approval <q>topologies.</q> 
  For instance, person A or person B might be allowed to sign at the first step,
  followed by person C at the second step. Or, person A and person B may both have to
  sign (but in parallel) before person C can sign. However, the current DocDB code only
  allows one topology (an ordered list). When a document under control is
  updated, the signoff list structure is preserved, but the approvals themselves
  are cleared.</p>\n";

   print "<p>The signoff system provides a number of additional convieniences:</p>
  <ul>
    <li>Email notifications to signatories when a document is ready for their
    signature</li>
    <li>A way to list all controlled documents</li>
    <li>List of all documents a person is a signatory (actual or requested) on</li>
  </ul>\n";

   print "<p>A number of other features are planned and will be added as needed:</p>
  <ul>
    <li>Email reports of outstanding signatures needed (to desired signatory and
      other signatories of documents)</li>
    <li>More complicated approval topolgies (OR's, parallel paths, etc.)</li>
    <li>Reminders if a document goes unsigned for a while</li>
    <li>Restricting the list of people who may sign documents to a sub-set of those with
    personal accounts</li>
  </ul>\n";
  }

  print <<HTML;

  <a name="advancedusers" />
  <h1>Notes for Advanced Users</h1>

  <p>As you become more familiar with DocDB, you may wish to link to documents,
     files within those documents, or to a list of documents. You may even want to use
     another computer program to communicate with DocDB. The <a
     href="$DocDBInstructions?set=advanced">Advanced Instructions</a> describe
     how to do these things and more.</p>

  <a name="philosophy" />
  <h1>Final Words</h1>

  <a name="annoyances" />
  <h2>Javascript, pop-ups, and cookies</h2>

  <p>DocDB makes limited use of these technologies to enhance your experience,
  however DocDB will generally function just  fine without them. These
  techniques are only used where they are required. For instance, DocDB will pop
  up windows when you request help, but never automatically. We suggest you
  configure your web browser to allow cookies, pop-ups, etc. from the DocDB
  server.</p>

  <a name="archive" />
  <h2>Archive vs. Catalog</h2>

  <p>Some other document databases are only a method for cataloging
  documents. DocDB goes one step further; it is also a method for
  storing documents in a central location. So, you should never again see a
  broken link while looking for the information you want. This distinction is
  especially important for archive uploads as discussed above. </p>

  <p>While parts of the interface may look complicated, some options can be
  left blank. Omitting a version number will give you the latest version.
  We've tried to simplify the use
  of the most common options. Of course, if you have a suggestion on how to make
  things easier, please let us know.</p>

  <a name="whatis" />
  <h2>What is a document?</h2>

  <p>This may sound like a stupid question, but it's not. People tend to think of
  a document as something that consists of writing and can be printed on a
  piece of paper. In our context, a document is something much more general. A
  document is any piece of information that a) you want to save and b) you want
  to share with others. So, a video can be a document.  A
  picture is a document. A calculation on the back of an
  envelope and scanned is a document. (And it's probably a "Note," not a
  "Figure." The document type you  choose tells people what the document
  <strong>is</strong> not what format it's stored in.)</p>

  <a name="formats" />
  <h2>File formats (PowerPoint, Postscript, PDF etc.)</h2>


  <p>People view the web with many different OS/Software combinations. 
  This means they
  may not be able to view files in formats such as PowerPoint, MS Word, and Excel. The two
  file formats that everyone can read are Postscript and PDF. PDF is easiest for
  Windows users.  Please save your
  document in one of these formats as well as in the native formats.</p>

HTML

  }
}

1;
