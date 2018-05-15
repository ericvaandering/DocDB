#        Name: $RCSfile$
# Description: Generates HTML for things related to signoffs
#
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2014 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub SignoffBox { # Just a text box for now with a list of names
  my (%Params) = @_;

  my $Default  = $Params{-default}  || "";

  my $ChooserLink  = "- <a href=\"Javascript:signoffchooserwindow(\'$SignoffChooser\');\">".
        "<b>Signoff Chooser</b></a>";
  my $ElementTitle = &FormElementTitle(-helplink  => "signoffs",
                                       -helptext  => "Signoffs",
                                       -extratext => $ChooserLink);
  print $ElementTitle,"\n";

  print $query -> textarea (-name => 'signofflist', -default => $Default,
                            -columns => 30, -rows => 2);
};

sub PrintRevisionSignoffInfo ($) { # FIXME: Handle more complicated topologies?
  require "SignoffSQL.pm";
  require "Security.pm";

  my ($DocRevID) = @_;
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{Version};

  # Don't display anything if the user is logged in as public.
  # Provide the ability to sign if the user can modify or
  # if the user can access the document (without modify permissions).

  if ($Public) {
    return;
  }
  my $UserCanSign = $FALSE;
  if (CanModify($DocumentID,$Version) || CanAccess($DocumentID,$Version)) {
    $UserCanSign = $TRUE;
  }

  my @RootSignoffIDs = &GetRootSignoffs($DocRevID);
  if (@RootSignoffIDs) {
    print "<div id=\"Signoffs\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Signoffs:</span></dt>\n";
    print "</dl>\n";

    print "<ul>\n";
    foreach my $RootSignoffID (@RootSignoffIDs) {
      PrintSignoffInfo($RootSignoffID,$UserCanSign);
    }
    print "</ul>\n";
    print "</div>\n";
  }
}

sub PrintSignoffInfo ($) {
  require "SignoffSQL.pm";

  my ($SignoffID,$UserCanSign) = @_;

  if ($Public) { return; }

  my @SubSignoffIDs = &GetSubSignoffs($SignoffID);
  print "<li>";
  PrintSignatureInfo($SignoffID,$UserCanSign);
  if (@SubSignoffIDs) {
    print "<ul>\n";
    foreach my $SubSignoffID (@SubSignoffIDs) {
      PrintSignoffInfo($SubSignoffID,$UserCanSign);
    }
    print "</ul>\n";
  }
  print "</li>\n";
  return;
}

sub PrintSignatureInfo ($) {
  require "SignoffSQL.pm";
  require "SignoffUtilities.pm";
  require "NotificationSQL.pm";

  my ($SignoffID,$UserCanSign) = @_;

  if ($Public) { return; }

  my @SignatureIDs = &GetSignatures($SignoffID);

  my @SignatureSnippets = ();

  foreach my $SignatureID (@SignatureIDs) {
    my $SignatureIDOK = &FetchSignature($SignatureID);
    if ($SignatureIDOK) {
      my $EmailUserID = $Signatures{$SignatureID}{EmailUserID};
      &FetchEmailUser($EmailUserID);

      my $SignoffID = $Signatures{$SignatureID}{SignoffID};
      my $Status = &SignoffStatus($SignoffID);

      # If the Signoff is ready for a signature, put a password field
      # If signed, allow rescinding the signature
      # Otherwise, note that it's waiting

      my $SignatureText = "";
      my ($SignatureLink, $SignatureTime) = SignatureLink($EmailUserID,$SignatureID);
      if ($UserCanSign) {
        if ($Status eq "Ready" || $Status eq "Signed") {
          if ($Status eq "Ready") {
            $Action = "sign";
            $ActionText = "Sign Document"
          } else {
            $Action = "unsign";
            $ActionText = "Remove Signature"
          }
          if ($UserValidation eq "certificate" || $UserValidation eq "shibboleth" || $UserValidation eq "FNALSSO") {
            if (FetchEmailUserID() == $EmailUserID) {
              $SignatureText .= $query -> start_multipart_form('POST',"$SignRevision");
              $SignatureText .= "<div>\n";
              $SignatureText .= "$SignatureLink ";
              $SignatureText .= $query -> hidden(-name => 'signatureid',   -default => $SignatureID);
              $SignatureText .= $query -> hidden(-name => 'emailuserid',   -default => $EmailUserID);
              $SignatureText .= $query -> hidden(-name => 'action',   -default => $Action);
              $SignatureText .= $query -> submit (-value => $ActionText);
              $SignatureText .= "</div>\n";
              $SignatureText .= $query -> end_multipart_form;
            } else {
              if ($Status eq "Signed") {
                $SignatureText .= "$SignatureLink (signed $SignatureTime)";
              } else {
                $SignatureText .= "$SignatureLink (waiting for signature)";
              }
            }
          } else {
            $SignatureText .= $query -> start_multipart_form('POST',"$SignRevision");
            $SignatureText .= "<div>\n";
            $SignatureText .= "$SignatureLink ";
            $SignatureText .= $query -> hidden(-name => 'signatureid',   -default => $SignatureID);
            $SignatureText .= $query -> hidden(-name => 'emailuserid',   -default => $EmailUserID);
            $SignatureText .= $query -> hidden(-name => 'action',   -default => $Action);
            $SignatureText .= $query -> password_field(-name => "password-$EmailUserID", -size => 16, -maxlength => 32);
            $SignatureText .= " ";
            $SignatureText .= $query -> submit (-value => $ActionText);
            $SignatureText .= "</div>\n";
            $SignatureText .= $query -> end_multipart_form;
          }
        } elsif ($Status eq "NotReady") {
          $SignatureText .= "$SignatureLink (waiting for other signatures)";
        } else {
          $SignatureText .= "$SignatureLink (unknown status)";
        }
      } else {
        if ($Status eq "Ready") {
          $SignatureText .= "$SignatureLink (waiting for signature)";
        } elsif ($Status eq "Signed"){
          $SignatureText .= "$SignatureLink (signed $SignatureTime)";
        } elsif ($Status eq "NotReady") {
          $SignatureText .= "$SignatureLink (waiting for other signatures)";
        } else {
          $SignatureText .= "$SignatureLink (unknown status)";
        }
      }
      push @SignatureSnippets,$SignatureText;
    } # if ($SignatureIDOK)
  } # foreach (@SignatureIDs)

  my $SignoffText = join ' or <br>',@SignatureSnippets;
  print "$SignoffText\n";
}

sub SignatureLink ($) {
  require "NotificationSQL.pm";
  require "SQLUtilities.pm";
  require "SignoffSQL.pm";
  my ($EmailUserID,$SignatureID) = @_;
  my $SignatureTime;

  &FetchEmailUser($EmailUserID);
  my $Link = "<a href=\"$SignatureReport?emailuserid=$EmailUserID\"";
  if ($SignatureID) {
    FetchSignature($SignatureID);
    if ($Signatures{$SignatureID}{Signed}) {
      my $SignatureTimestamp = $Signatures{$SignatureID}{TimeStamp};
      my $SignatureDateTime = ConvertToDateTime({-MySQLTimeStamp => $SignatureTimestamp, });
         $SignatureTime  = DateTimeString({ -DateTime => $SignatureDateTime });


      $Link .= " title=\"Signed $SignatureTime\"";
    } else {
      $Link .= " title=\"Not signed\"";
    }
  }
  $Link .= ">";
  $Link .= $EmailUser{$EmailUserID}{Name};
  $Link .= "</a>";
  return ($Link, $SignatureTime);
}
1;
