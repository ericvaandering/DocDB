# Description: How to get and use a certificate. 
#              This is mostly HTML, but making  it a script allows us to eliminate
#              parts of it that we don't want and get it following everyone's
#              style, and allows groups to add to it with ProjectMessages.
#
#      Author: Lynn Garren (garren@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)

# We've tried to make these instructions generically useful if you have both
# FNALKCA and DOEGrids set to false, as above. In the case where DOEGrids only
# is set, there may be some issues. Please feel free to send patches if you find
# FNAL specific information remaining.

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

sub CertificateInstructionsSidebar {
  print <<TOC;
  <h2>Contents</h2>
  <ul>
   <li><a href="$DocDBInstructions?set=cert">Introduction</a></li>
TOC

  if ($Preferences{Security}{Certificates}{DOEGrids}) {
    print "<li><a href=\"$DocDBInstructions?set=doe\">Get a DOEgrid Certificate</a></li>\n";
  }
  if ($Preferences{Security}{Certificates}{FNALKCA}) {
   print <<KCA;
   <li><a href="$DocDBInstructions?set=kca">Get a KCA (Kerberos) Certificate </a>
   <ul>
    <li><a href="$DocDBInstructions?set=kca#win">For Windows</a></li>
    <li><a href="$DocDBInstructions?set=kca#linux">For Linux</a></li>
    <li><a href="$DocDBInstructions?set=kca#mac">For MAC</a></li>
   </ul></li> 
KCA
  }
  print <<TOC;
   <li><a href="$DocDBInstructions?set=register">Register your certificate with DocDB</a></li>
   <li><a href="$DocDBInstructions?set=import">Importing and Exporting certificates</a></li>
   <li><a href="http://computing.fnal.gov/security/pki/browsercerttest.html">How to test your certificate</a></li>
   <li><a href="$DocDBInstructions?set=protect">Protect your certificate</a></li>
   <li><a href="$DocDBInstructions?set=misc#issues">Known issues with certificates</a>
TOC
  if ($Preferences{Security}{Certificates}{DOEGrids}) {
    print "<ul>
    <li><a href=\"$DocDBInstructions?set=misc#same\">Same machine</a></li>
    </ul>\n";
  }  
  print <<TOC;
   </li> 
  </ul>
TOC
}

sub CertificateInstructionsBody {
  print <<HTML;
  <a name="intro"/>
  <h1>Introduction</h1>

  <p>
  You can use certificates provided by various certification authorities (CAs)
  with DocDB. <span class="Highlight">Each certificate type must be separately
  registered with the database.</span> To minimize confusion, we strongly
  recommend that you choose only one certificate type for access.  
  </p>
HTML

if ($Preferences{Security}{Certificates}{DOEGrids}) {
  print <<DOE;
  <p>
  Get a <a href="$DocDBInstructions?set=doe">DOEgrid certificate</a>.
  </p>
DOE
}

if ($Preferences{Security}{Certificates}{FNALKCA}) {
   print <<KCA;
   <p>
   Get a <a href="$DocDBInstructions?set=kca">KCA (Kerberos) certificate</a> -
   <a href="$DocDBInstructions?set=kca#win">for Windows</a>, 
   <a href="$DocDBInstructions?set=kca#linux">for Linux</a>, or
   <a href="$DocDBInstructions?set=kca#mac">for MAC</a>.
   We recommend that Fermilab and other Kerberos 
users choose the KCA certificate.  This is more secure and will, 
at least at Fermilab, be required for access to other web sites.
   </p>
KCA
}

  print <<HTML;
<p>
<a href="$DocDBInstructions?set=register">Register</a> your certificate with DocDB
</p>
<p>
<a href="$DocDBInstructions?set=import">Importing and Exporting</a> certificates 
</p>
<p> 
You may wish to 
<a href="http://computing.fnal.gov/security/pki/browsercerttest.html">test your certificate</a>.
</p> 
<p>
<a href="$DocDBInstructions?set=protect">Protect your certificate.</a>
</p>
<p> 
<a href="$DocDBInstructions?set=misc#issues">Known issues</a> with certificates.
</p> 

HTML
}

sub DOECertificateInstructionsBody {
  print <<HTML;
<a name="doe"/>
<h1>Get a DOEgrid Certificate</h1>
<p>
DOEgrid certificates are good for 1 year.
</p>
<p>
Once you get this certificate, you can import it into other browsers on other
machines by <a href="$DocDBInstructions?set=import">exporting</a> 
it to a file and then <a href="$DocDBInstructions?set=import">importing</a> 
into the other browser. 
<span class="Warning">We do not recommend importing this certificate onto any
machine other than your own desktop or laptop.</span>
</p>
<ol>
<li>Get the certificate
    <ul>
    <li> <span class="Warning">Important for Mac users: The process does not work with Safari at this time.</span>
         Use <a href="http://www.mozilla.org/products/firefox/">Firefox</a>.</li>
    <li> Go to <a href="http://pki1.doegrids.org" target="view_doe_window">http://pki1.doegrids.org</a>  and select "enrollment" tab.
         (This link should open a new window for the DOEgrid site.)</li>
    <li> Select "New user" on the left hand side.</li>
    <li> Fill in the form
        <ul>
	<li> <b>Contact Information</b> <br/>
	     Your email address needs to match your affiliation. <br/> 
	     For instance, if you are at Fermilab, use your fnal.gov e-mail
	     address and choose <b>FNAL</b> in the pulldown menu.</li>
	<li> Your <b>sponsor</b> must also have an e-mail 
	     address associated with your affiliation.</li>
	<li> The person entered under <b>sponsor</b> receives email when you are granted the certificate.  
	     They are not asked to approve or disapprove before the certificate is granted.  
	     (Approval is handled by another process.)</li>
	<li> Get the optional password.</li>
	<li> Under "Public/Private key information", 
	     <ul>
	     <li> select 2048(High grade) for Mozilla/Firefox/Netscape. </li>
	     <li> For Microsoft, select "Strong Cryptographic Provider".
		  <br/>	
		  <span class="Warning">Windows IE users should note that you may need to use 
		  "Microsoft Enhanced Cryptographic Provider" instead of 
		  "Microsoft Strong Cryptographic Provider".</span></li>
	     </ul></li>
        </ul></li>
    <li> click "submit."</li>
    <li> click "yes" to the dialog box that asks you if you trust the site.  
         Your browser page should say "Request successfully submitted."  
	 Note the request number.</li>
    <li> You will get email notification that you got it or were refused.  
         If you don't get email in 24 hours, call the helpdesk, 2345.  
	 They will want the request number.</li>
    </ul></li>
<li> Import the certificate into your browser - first time
    <ul>
    <li> Use the <a href="$DocDBInstructions?set=misc#same">same physical machine</a>, 
         same user account, and the same web browser. </li>
    <li> Open the link in the email.</li>
    <li> Click on "import the certificate" at the bottom of the page of letters and numbers.</li>
    <li> In Firefox or Mozilla, if you have set a Master Password on your 
         Software Security Device, you might get a dialog box that asks for it.</li>
    <li> Click "OK" when asked if you trust this site.</li>
    <li> You should get a dialog box "Certificate successfully imported." 
         Click OK.</li>
    </ul></li>
<li> Save (<a href="$DocDBInstructions?set=import">export</a>) the certificate 
     in case you need it for something else or another browser.  
     We recommend that you keep a copy on your desktop or laptop
     so that you can restore it if necessary.  For more security, keep a copy on
     a USB thumb drive and nowhere else.  Do not keep copies elsewhere.</li>
<li> <a href="$DocDBInstructions?set=protect">Protect your certificate.</a></li>
<li> If you want, test your certificate by going to 
     <a href="http://security.fnal.gov/pki/browsercerttest.html">http://security.fnal.gov/pki/browsercerttest.html</a>
     and following the instructions.</li>

<li> Finally, <a href="$DocDBInstructions?set=register">register</a> your certificate with 
     the $ShortProject document database.
     <span class="Warning">You only need to register once.</span></li>
</ol>
 
HTML
}

sub KCACertificateInstructionsBody {
  print <<HTML;
 
<a name="kca"/>
<h1>Get a KCA (Kerberos) Certificate </h1>
<p>
Use the instructions appropriate to your machine to get and use a KCA certificate.
</p>

 <a name="win"/>
<h2>Get a KCA (Kerberos) Certificate for Windows</h2>
<p>
The KCA certificate will be good for one week, but if you create a 
desktop shortcut (as specified below), then you will only need to open 
the shortcut and type in your Kerberos password.
</p>
<ol>
<li> Create an empty folder and go there.
</li>
<li> Download <a href="http://security.fnal.gov/tools/getcert.zip">getcert.zip</a>
</li>
<li> Unzip the file. 
     <ul>
     <li> Right click on <b>getcert.zip</b> and select "Open with WinZip" or
     "Extract All"
        </li>
     <li> Use the wizard to extract the contents of the zip file into
          a folder.
        </li>
     </ul>
</li>
<li> Find <b>Get-Cert.cmd</b> and make a shortcut to it on your desktop.
</li>
<li> Close the folder
</li>
<li> Double click on the shortcut. <br/>
     <ul>
     <li> A command window will appear.
        </li>
     <li> Follow the instructions in the window.
        </li>
     <li> It will prompt you for your Kerberos password and ask you
          to close all browser windows.
        </li>
     <li> If it asks for a new password, just ignore and close the window.
        </li>
     <li> You should get a message in the window indicating that it has
          imported the certificate into your browsers.
        </li>
     <li> It will also tell you the location of the certificate file it created.
        </li>
     </ul>
</li>
<li> If your certificate was not imported, see 
     <a href="$DocDBInstructions?set=import">these instructions</a>.
</li>
<li> If you want, test your certificate by going to 
     <a href="http://security.fnal.gov/pki/browsercerttest.html">http://security.fnal.gov/pki/browsercerttest.html</a>
     and following the instructions.
</li>
<li> Finally, <a href="$DocDBInstructions?set=register">register</a> your certificate with 
     the $ShortProject document database.  
     <span class="Warning">You only need to register once.</span>
</li>
</ol>

 <a name="linux"/>
<h2>Get a KCA (Kerberos) Certificate for Linux</h2>
<ol>
<li> GetCert method:
  <ul>
  <li> Download <a href="http://security.fnal.gov/tools/get-cert.tar.gz">get-cert.tar.gz</a>
       </li>
  <li> <b>tar -xzf get-cert.tar.gz</b> <br/>
       This will create a kca directotry.
       </li>
  <li> <b>kinit -r 7d</b> <br/>
           If you make your ticket renewable for 7 days, then the resulting certificate
	   will be valid for 7 days.
       </li>
  <li> <b>cd kca</b> and choose one of the following options
       <ol>
       <li>  <b>./get-cert.sh</b> <br/>
             The certificate will be /tmp/x509up_u&lt;your uid&gt;.p12, where &lt;your uid&gt; is your UID. <br/>
             You will need to manually <a href="$DocDBInstructions?set=import">import</a> the certificate.
             </li>
       <li> Close your browser. <br/>
            <b>./get-cert.sh -i</b> <br/>
            This option should automatically import the certificate into
	    your browser.  If it does not, 
            manually <a href="$DocDBInstructions?set=import">import</a> the certificate.
            </li>
       </ol>
       </li>
  <li> get-cert.sh will tell you the name and location of the certificate 
      it creates.
        </li>
  </ul>
</li>
<li>  Manual method:
  <ul>
  <li> <b>kinit -r 7d</b> <br/>
           If you make your ticket renewable for 7 days, then the resulting certificate
	   will be valid for 7 days.
        </li>
  <li> <b>kx509</b>
        </li>
  <li> <b>kxlist -p</b>
        </li>
  <li> <b>openssl pkcs12 -in /tmp/x509up_u&lt;your uid&gt; -out /tmp/x509up_u&lt;your uid&gt;.p12 -export</b> <br/>
       This converts your x509 certificate to browser format. <br/>
       The file will be named /tmp/x509up_u&lt;your uid&gt;.p12, where &lt;your uid&gt; is your UID. <br/>
       You will be asked for a password that will be used when you import your 
       certificate into your browser.
        </li>
  </ul>
</li>
<li> If your certificate was not imported, see 
     <a href="$DocDBInstructions?set=import">these instructions</a>.
</li>
<li> If you want, test your certificate by going to 
     <a href="http://security.fnal.gov/pki/browsercerttest.html">http://security.fnal.gov/pki/browsercerttest.html</a>
     and following the instructions.
</li>
<li> Finally, <a href="$DocDBInstructions?set=register">register</a> your certificate with 
     the $ShortProject document database.
     <span class="Warning">You only need to register once.</span>
</li>
</ol>

 <a name="mac"/>
<h2>Get a KCA (Kerberos) Certificate for MAC</h2>
<ol>
<li>  First make sure that you have both <b>kx509</b> and <b>kxlist</b>.
      If these are not already on your machine, you can find
      instructions and a disk image (for panther) at 
      <a href="http://www.fnal.gov/orgs/macusers/osx/">http://www.fnal.gov/orgs/macusers/osx/</a>
</li>
<li>  You'll want to make sure that both <b>kx509</b> and <b>kxlist</b> are
      in your path.
</li>
<li>  You probably also need a properly configured krb5.conf.
</li>
<li>  Manual method:
  <ul>
  <li> Open a terminal window.
  </li>
  <li> <b>kinit</b> 
      <ul>
      <li> If your MAC Kerberos has not been configured: 
           <b>kinit user@FNAL.GOV</b> 
      </li>
      <li> By default, the ticket should be renewable for 7 days.
      </li>
      </ul>
  </li>
  <li> <b>kx509</b> 
  </li>
  <li> <b>kxlist -p</b>
  </li>
  <li> <b>openssl pkcs12 -in /tmp/x509up_u&lt;your uid&gt; -out /tmp/x509up_u&lt;your uid&gt;.pfx -export</b> <br/>
       This converts your x509 certificate to browser format. <br/>
       The file will be named /tmp/x509up_u&lt;your uid&gt;.pfx, where &lt;your uid&gt; is your UID. <br/>
       You will be asked for a password that will be used when you import your 
       certificate into your browser.
  </li>
  </ul>
</li>
<li> <a href="$DocDBInstructions?set=import">Import</a> 
     <b>/tmp/x509up_u&lt;your uid&gt;</b> into your browser.
</li>
<li> If you want, test your certificate by going to 
     <a href="http://security.fnal.gov/pki/browsercerttest.html">http://security.fnal.gov/pki/browsercerttest.html</a>
     and following the instructions.
</li>
<li> Finally, <a href="$DocDBInstructions?set=register">register</a> your certificate with 
     the $ShortProject document database.
     <span class="Warning">You only need to register once.</span>
</li>
</ol>

HTML
}

sub RegisterCertificateInstructionsBody {
  print <<HTML;

<a name="register"/>
<h1>Register your certificate with DocDB</h1>
<p>
You must register your certificate with the $ShortProject document database 
before you will have full access. 
</p>
<ol>
<li> In a browser that has had your certificate imported, 
     go to the secure $ShortProject document database page: 
      <a href="$secure_root/DocumentDatabase">$secure_root/DocumentDatabase</a></li> 
<li> If you get a window "choose a digital certificate", 
     pick the desired certificate.  Click "OK"
     </li>
<li> You should see the message "You have presented a valid certificate, 
     but are not yet authorized to access the Docdb."  
     Click on the "Apply for Access" link.  
     This is to register your certificate in the database.
     </li>
<li> A form will appear - enter your email and highight the desired
     access permission(s) and then "submit."  
     There is a comments box which you can use to swear at the system.
     </li>
<li> Someone should authorize you within a few hours during working hours.  
     Send email to the <a href="mailto:$DBWebMasterEmail">$DBWebMasterName</a> 
     if you don't hear anything within a day.
     </li>
</ol>
HTML

  if ($Preferences{Security}{Certificates}{DOEGrids} || $Preferences{Security}{Certificates}{FNALKCA}) {
    print "<p>
    <span class=\"Highlight\">People are investigating ways to streamline this process. 
    We are not yet sure how much is possible.</span>
    </p>\n";
  }
}
 
sub ImportCertificateInstructionsBody {
  print <<HTML;

<a name="import"/>
<h1>Importing and Exporting certificates</h1>
<ol>
<li> Naming conventions vary by certificate provider.  
     We will refer to all certificates as <b>mycert.p12</b>.</li>
<li> Your certificate must be of type PKCS#12 with a <b>.p12</b> extension.</li>
<li> Choose a simple password when exporting your certificate.  
     You will need to use this password when importing the certificate.</li>
<li> To import a certificate into your browser:
   <ul>
   <li> For Firefox: 
        <ul>
	<li> <span class="Highlight">Linux:</span> 
	     open Edit -> Preferences -> Advanced -> Certificates -> Manage Certificates <br/>
	     <span class="Highlight">Windows:</span> 
             open Tools -> Options -> Advanced -> Certificates -> Manage Certificates <br/>
	     <span class="Highlight">MAC:</span> 
	     open  Firefox -> Preferences -> Advanced -> Certificates -> Manage Certificates <br/>
        </li>
        <li> click import and enter the filename (mycert.p12 or <span class="Highlight">mycert.pfx on a MAC</span>)
        </li>
        </ul>
   </li>
   <li> For Mozilla:
        <ul>
        <li> open Edit -> Preferences -> Privacy &amp; Security -> Certificates -> Manage Certificates 
        </li>
        <li> click import and enter the filename (mycert.p12)
        </li>
        </ul>
   </li>
   <li> For Windows IE: 
        <ul>
        <li> open Tools -> Internet Options -> Content -> Certificates 
        </li>
        <li> click import and enter the filename (mycert.p12)
        </li>
        </ul>
   </li>
   <li> For MAC Safari: 
        <ul>
        <li> open a Terminal
        </li>
        <li> <b>open mycert.pfx</b> <br/>
	     Open recognizes either the <b>.pfx</b> or <b>.p12</b> extension and will
	     open the keychain so you can import the certificate.
        </li>
        <li> Import the certificate into your login keychain. 
        </li>
        <li> There is a script at 
             <a href="http://www.fnal.gov/orgs/macusers/osx/">http://www.fnal.gov/orgs/macusers/osx/</a>
             which will generate the certificate and import it into your
	     keychain.  But this script makes certain assumptions that may not 
	     be true on your machine. 
        </li>
        </ul>
   </li>
   </ul>
</li>
<li> To export a certificate from your browser:
   <ul>
   <li>In all cases, make sure you save the certificate as type 
        <b>PKCS#12</b> with extension <b>.p12</b> or (<b>.pfx</b> on a MAC)
   </li>
<li> <a href="$DocDBInstructions?set=protect">Protect your certificate.</a></li>
   <li>For Firefox: 
        <ul>
	<li> <span class="Highlight">Linux:</span> 
	     open Edit -> Preferences -> Advanced -> Certificates -> Manage Certificates <br/>
	     <span class="Highlight">Windows:</span> 
             open Tools -> Options -> Advanced -> Certificates -> Manage Certificates <br/>
	     <span class="Highlight">MAC:</span> 
	     open  Firefox -> Preferences -> Advanced -> Certificates -> Manage Certificates <br/>
        </li>
        <li> highlight the certificate to export
        </li>
        <li> click Backup and choose an appropriate filename (mycert.p12 or <span class="Highlight">mycert.pfx on a MAC</span>) and directory.
        </li>
        </ul>
   </li>
   <li> For Mozilla:
        <ul>
        <li> open Edit -> Preferences -> Privacy &amp; Security -> Certificates -> Manage Certificates 
        </li>
        <li> highlight the certificate to export
        </li>
        <li> click Backup and choose an appropriate filename (mycert.p12) and directory.
        </li>
        </ul>
   </li>
   <li> For Windows IE: 
        <ul>
        <li> open Tools -> Internet Options -> Content -> Certificates 
        </li>
        <li> highlight the certificate to export
        </li>
        <li> click Backup and choose an appropriate filename (mycert.p12) and directory.
        </li>
        </ul>
   </li>
   <li> For MAC Safari: 
        <ul>
        <li> open Finder and go to Applications -> Utilities -> Keychain Access
        </li>
        <li> double click on Keychain to open it
        </li>
        <li> on the left, click on Certificates
        </li>
        <li> highlight the certificate to export and open File -> Eport
        </li>
        <li> choose an appropriate filename (mycert.pfx) and directory.
        </li>
        </ul>
   </li>
   </ul>
</li>
<li> <a href="http://computing.fnal.gov/security/pki/browsercerttest.html">Test your certificate</a>
</li>
</ol>

HTML
}
 
sub ProtectCertificateInstructionsBody {

  if ($Preferences{Security}{Certificates}{DOEGrids} || $Preferences{Security}{Certificates}{FNALKCA}) {
    print <<HTML;

  <a name="protect"/>
  <h1>Protect your certificate</h1>

  <p>
  If you export your DOEgrid certificate to a PKCS#12 file, it contains your private key.  
  You must carefully guard any PKCS#12 certificate files.
  </p>
  <p>
  <span class="Warning">
  Exposure of the private key is grounds for having the certificate revoked.
  </span>
  </p>
  <p>
  If you keep a copy of your certificate on your machine, make sure that it can
  only be ready by you.  (On unix, <b>chmod 600 mycert.p12</b>.)
  </p>
  <p>
  The Fermilab security team recommends that you keep your certificate on a
  floppy or USB thumb drive instead of online.
  </p>
  <p>
  Please be careful when copying the certificate.  If it is necessary to
  temporarily use your certificate on a machine that does not belong to you (e.g.,
  when visiting CERN), make absolutely sure that you delete the certificate.
  <span class="Warning">
  If someone else uses your certificate, the certificate will be revoked.
  </span>
  </p>
  <p>
  Further explanation: <br/>
  When you generate your certificate request to DOEgrids, a private
  key is generated for you and stored in your brower (for Netscape,
  Mozilla, Firefox this is the Security Device protected by the
  Master Password).  This is why you have to import your new
  cewtificate using the same system and browser that you made
  the initial request with.  When you export the certificate,
  into a PKCS#12 file for backup or for later import, both
  the certificate and the private key are exported! 
  </p>

HTML
  } else {
    print "<p>
    If you export your certificate to a file, it contains your private key.  
    You must carefully guard the contents of any PKCS#12 certificate files.
    Some ways of protecting this information are: 
    </p>
    <ol>
    <li>Use access to controls to make sure other users can't read the files.</li>
    <li>Use a password when exporting the file. You will have to use the same password when reading back the file.</li>
    <li>Store the file on a removable disk</li>
    </ol>\n";
  }  
  
}
 
sub MiscCertificateInstructionsBody {
  print <<HTML;

  <a name="issues"/>
  <h1>Known issues with certificates</h1>
  <ol>
  <li> If you wish to use more than one type of certificate 
HTML
  if ($Preferences{Security}{Certificates}{DOEGrids} && $Preferences{Security}{Certificates}{FNALKCA}) {
    print "(for instance, both KCA and DOEgrid certificates),\n"; 
  }  
  print <<HTML;
     each certificate type will need to be separately registered with DocDB.
     <ul>
     <li>To minimize confusion, we strongly recommend that you choose only one 
     certificate type for access.  
     </li>
HTML
  if ($Preferences{Security}{Certificates}{FNALKCA}) {
    print "<li>We recommend that Fermilab and other Kerberos 
     users choose the Kerberos (KCA) certificate.  This is more secure and will, 
     at least at Fermilab, be required for access to other web sites.
     </li>\n";
  }
  print <<HTML;
     </ul>
</li>
<li> Every browser handles multiple certificates differently.
     <ul>
     <li>IE will ask you which certificate you want to use.
     </li>
     <li>Mozilla and Firefox will attempt to present the appropriate
         certificate to the server.    
     Unfortunately, this may not be the one you want.
     The only way around this is to configure Mozilla or Firefox to always
     ask you which certificate to use.  
     This will quickly get old, so you probably only want a single certificate
     in your browser.  
     </li>
     <li>  A bit of explanation may be in order.  
           The web server has a list of acceptable certificate types.
	   Your browser returns one of these acceptable certificates.  
	   If you only have one acceptable certificate type,
	   there is no confusion.  If, however, you have more than
	   one acceptable certificate, the browser does not automatically
	   know which one to use.
     </li>
     </ul>
</li>
<li>MacOSX Safari seems to have problems with certificates.</li>
<li> <a href="$DocDBInstructions?set=protect">Protect your certificate.</a></li>
</ol>
HTML

  if ($Preferences{Security}{Certificates}{DOEGrids}) {
    print <<HTML;
    <a name="same"/>
    <h2>Same Machine Explanation</h2>
    <p>
    When you apply for a DOEgrid certificate, your web brower sends along a public
    key.  This key is used to match up with the private key that is kept on your
    browser.  When you get the e-mail with a link to your new DOEgrid certificate,
    that web page will be expecting to make a proper connection to the private key
    in your web browser.  This key is unique to your physical machine and chosen web
    browser.  
    </p> 
    <p>
    The actual port you use (wired, wireless, etc.) is irrelevant.
    </p> 
    <p>
    Your IP address (at the lab, away from the lab, DHCP, static, etc.) is
    irrelevant.
    </p> 
HTML
  }
}


1;
