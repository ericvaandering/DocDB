# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub Unique {
  my @Elements = @_;
  my %Hash = ();
  foreach my $Element (@Elements) {
    ++$Hash{$Element};
  }

  my @UniqueElements = keys %Hash;
  return @UniqueElements;
}

sub Union {
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

sub IndexOf {
  my ($Element,@Array) = @_;

  my $Found = 0;
  my $Count = 0;
  foreach my $Test (@Array) {
    if ($Test eq $Element) {
      $Found = 1;
      last;
    }
    ++$Count;
  }

  if ($Found) {
    return $Count;
  } else {
    return undef;
  }
}

sub AddTime ($;$) {
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
