sub ReferenceLink ($) {
  my ($ReferenceID) = @_;
  
  my $ReferenceLink = "";
  my $ReferenceText = "";
  if ($ReferenceID) {
    my $JournalID = $RevisionReferences{$ReferenceID}{JournalID};
    my $Volume    = $RevisionReferences{$ReferenceID}{Volume};
    my $Page      = $RevisionReferences{$ReferenceID}{Page};
    my $Acronym   = $Journals{$JournalID}{Acronym};
    
    if ($Acronym eq "PLB")    {
      ($ReferenceLink,$ReferenceText) = &PLBLink($Acronym,$Volume,$Page);
    }
    if ($Acronym eq "hep-ex" || $Acronym eq "hep-ph" || $Acronym eq "hep-th") {
      ($ReferenceLink,$ReferenceText) = &ArxivLink($Acronym,$Volume,$Page);
    }

    if (!$ReferenceLink && prototype ProjectReferenceLink) { # Only if it exists
      ProjectReferenceLink($Acronym,$Volume,$Page,$ReferenceID);
    }
  }
  return $ReferenceLink,$ReferenceText;
}

sub PLBLink ($$$) {
  my ($Acronym,$Volume,$Page) = @_;

  ($Page) = split /\D/,$Page; # Remove any trailing non-digits 
  $Volume =~ split s/\D//;    # Remove any non-digits 
  
  my $ReferenceLink = "http://www.elsevier.com/IVP/03702693/$Volume/$Page/";
  my $ReferenceText = "";

  return $ReferenceLink,$ReferenceText;
}

sub ArxivLink ($$$) {
  my ($Acronym,$Volume,$Page) = @_;

  my $ReferenceLink = "http://www.arxiv.org/abs/$Acronym/$Page";
  my $ReferenceText = "$Acronym/$Page";

  return $ReferenceLink,$ReferenceText;
}

1;
