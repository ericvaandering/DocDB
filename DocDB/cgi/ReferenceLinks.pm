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
    if ($Acronym eq "hep-ex") {
      ($ReferenceLink,$ReferenceText) = &HepExLink($Acronym,$Volume,$Page);
    }

    if (!$ReferenceLink && prototype ProjectReferenceLink) { # Only if it exists
      ProjectReferenceLink($Acronym,$Volume,$Page,$ReferenceID);
    }
  }
  return $ReferenceLink,$ReferenceText;
}

sub PLBLink ($$$) {
  my ($Acronym,$Volume,$Page) = @_;

  my $ReferenceLink = "";
  my $ReferenceText = "";

  return $ReferenceLink,$ReferenceText;
}

sub HepExLink ($$$) {
  my ($Acronym,$Volume,$Page) = @_;

  my $ReferenceLink = "http://www.arxiv.org/abs/hep-ex/$Page";
  my $ReferenceText = "hep-ex/$Page";

  return $ReferenceLink,$ReferenceText;
}

1;
