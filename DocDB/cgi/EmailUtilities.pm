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

sub SendEmail (%) {
  unless ($MailInstalled) {
    return 0;
  }    

  require Mail::Send;          #FIXME: Why not use?
  require Mail::Mailer;
  my (%Params) = @_;
  
  my %Headers = ();
  my @Addressees   = @{$Params{-to}};

  print "Sending mail to: ",@Addressees,"<br>\n";

  $Headers{To}      = \@Addressees;
  $Headers{From}    = $Params{-from} || "$Project Document Database <$DBWebMasterEmail>";
  $Headers{Subject} = $Params{-subject} || "Message from $Project DocDB";

  my $Body          = $Params{-body} || "";
  
  my $Mailer = new Mail::Mailer 'smtp', Server => $MailServer;
  
  $Mailer -> open(\%Headers);    # Start mail with headers
  print $Mailer $Body;        # Write the body
  $Mailer -> close;              # Complete the message and send it

  return 1;
}

1;
