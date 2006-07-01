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

sub Unique {
  my @Elements = @_;
  my %Hash = ();
  foreach my $Element (@Elements) {
    ++$Hash{$Element};
  }
  
  my @UniqueElements = keys %Hash;  
  return @UniqueElements;
}

sub Union (\@@) {
  my ($Array_ref,@A2) = @_;

  my @A1 = @{$Array_ref};

  @A1 = &Unique(@A1);
  @A2 = &Unique(@A2);
  push @A1,@A2; # Concat arrays into A1
  my @UnionElements = ();
  
  my %Hash = ();
  foreach my $Element (@A1) {
    if ($Hash{$Element} > 0) {
      push @UnionElements,$Element;
    } else {  
      ++$Hash{$Element};
    }  
  }
  
  return @UnionElements;
}

sub RemoveArray (\@@) { # Removes elements of one array from another
                        # Call &RemoveArray(\@Array1,@Array2)
                        # FIXME: Figure out how to do like push, no reference
                        #        on call needed
                        
  my ($Array_ref,@BadElements) = @_;

  my @Array = @{$Array_ref};

  foreach my $BadElement (@BadElements) {
    my $Index = 0;
    foreach my $Element (@Array) {
      if ($Element eq $BadElement) {
        splice @Array,$Index,1;
      }
      ++$Index;  
    }
  }
  return @Array;
}

sub URLify { # Adapted from Perl Cookbook, 6.21
  my ($Text) = @_;

  $urls = '(http|telnet|gopher|file|wais|ftp|https)';
  $ltrs = '\w';
  $gunk = '/#~:.?+=&%@!\-';
  $punc = '.:?\-';
  $any  = "${ltrs}${gunk}${punc}";
  $Text =~ s{
              \b                    # start at word boundary
              (                     # begin $1  {
               $urls     :          # need resource and a colon
               [$any] +?            # followed by on or more
                                    #  of any valid character, but
                                    #  be conservative and take only
                                    #  what you need to....
              )                     # end   $1  }
              (?=                   # look-ahead non-consumptive assertion
               [$punc]*             # either 0 or more punctuation
               [^$any]              #   followed by a non-url char
               |                    # or else
               $                    #   then end of the string
              )
             }{<A HREF="$1">$1</A>}igox;
  $Text = &SafeHTML($Text);
  return $Text;           
}

sub AddTime ($$) {
  my ($TimeA,$TimeB) = @_;
  
  use Time::Local;

  my ($HourA,$MinA,$SecA) = split /:/,$TimeA;
  my ($HourB,$MinB,$SecB) = split /:/,$TimeB;
  
  $TimeA = timelocal($SecA,$MinA,$HourA,1,0,0);
  $TimeB = timelocal($SecB,$MinB,$HourB,1,0,0)-timelocal(0,0,0,1,0,0);
  
  my $Time = $TimeA + $TimeB;

  my ($Sec,$Min,$Hour) = localtime($Time);
  
  my $TimeString = sprintf "%2.2d:%2.2d:%2.2d",$Hour,$Min,$Sec;

  return $TimeString; 
}

sub Paragraphize {
  my ($Text) = @_;
  $Text =~ s/\s*\n\s*\n\s*/<p\/>/g; # Replace two new lines and any space with <p>
  $Text =~ s/<p\/>/<p\/>\n/g;
  $Text = SafeHTML($Text);
  return $Text;
}

sub ParagraphizeXML {
  my ($Text) = @_;
  $Text = SafeHTML($Text);
  $Text =~ s/\s*\n\s*\n\s*/<\/p><p>/g; # Replace two new lines and any space with </p><p>
  $Text =~ s/\s*\n\s*/<br\/>/g;        # Replace one new line and any space with <br/>
  return "<p>".$Text."</p>";
}

sub AddLineBreaks {
  my ($Text) = @_;
  $Text =~ s/\s*\n\s*\n\s*/<p\/>/g; # Replace two new lines and any space with <p>
  $Text =~ s/\s*\n\s*/<br\/>\n/g;
  $Text =~ s/<p\/>/<p\/>\n/g;
  $Text = SafeHTML($Text);
  return $Text;
}

sub SafeHTML {
  my ($Text) = @_;
  $Text =~ s/\&/\&amp;/g;
  $Text =~ s/\&amp;amp;/\&amp;/g;
  return $Text;
}  
 
sub Printable ($) {
  my ($Text) = @_;
  $Text =~ tr/[\040-\377\r\n\t]//cd;
  return $Text;
}  
 
sub FillTable ($) {
  my ($ArgRef) = @_;
  my $Arrange  = exists $ArgRef->{-arrange}  ?   $ArgRef->{-arrange}   : "vertical";
  my $Columns  = exists $ArgRef->{-columns}  ?   $ArgRef->{-columns}   : 1;
  my @Elements = exists $ArgRef->{-elements} ? @{$ArgRef->{-elements}} : ();

  # Nothing other than vertical works
  
  my @PerColumn = ();
  my $PerColumn = int(scalar(@Elements) / $Columns);
  my $ExtraColumns = scalar(@Elements) % $Columns;
  
  for my $i (1..$Columns) {
    if ($ExtraColumns >= $i) {
      $PerColumn[$i] = $PerColumn + 1;
    } else {  
      $PerColumn[$i] = $PerColumn;
    }    
  }
  
  my @ColumnRefs = ();
  
  for my $i (1..$Columns) {
    for my $j (1..$PerColumn[$i]) {
      my $Element = shift @Elements;
      if ($Element) {
        push @{$ColumnRefs[$i]},$Element;
      }  
    }
  }    
  
  return @ColumnRefs;
}
  
1;
