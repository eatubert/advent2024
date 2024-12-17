#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';

my $debug = 0;

my $fname = shift or die "$0 [fname]";
open my $fh, '<', $fname or die "Can't open $fname";

my (@map, @moves);
{
    local $/ = "\n\n";
    @map = map {[split //]} split /\n/, scalar <$fh>;
    @moves = map {split //} split /\n/, scalar <$fh>;
}
close $fh;

my ($sizex, $sizey);
$sizey = scalar @map;
$sizex = scalar @{$map[0]};

printmap() if $debug;

my ($posx, $posy);
for my $y (0..$sizey-1) {
    for my $x (0..$sizex-1) {
        $posx=$x, $posy=$y, last if $map[$y][$x] eq '@';
    }
    last if defined $posx;
}




my %directions = (
    '^' => { x => 0, y => -1 },
    '<' => { x => -1, y => 0 },
    'v' => { x => 0, y => 1 },
    '>' => { x => 1, y => 0},
);

for my $move (@moves) {
    print "Move $move" if $debug;
    my $direction = $directions{$move};
    die unless defined $direction;
    my $candidateX = $posx + $direction->{x};
    my $candidateY = $posy + $direction->{y};
    die unless $candidateX >= 0 && $candidateX < $sizex && $candidateY >= 0 && $candidateY < $sizey;

    my $candidateC = $map[$candidateY][$candidateX];
    next if $candidateC eq '#';
    if ($candidateC eq 'O') {
        my $x = $candidateX;
        my $y = $candidateY;
        my ($emptyX, $emptyY);
        while ($x >= 0 && $x < $sizex && $y >= 0 && $y < $sizey) {
            $x += $direction->{x};
            $y += $direction->{y};
            my $c = $map[$y][$x];
            last if $c eq '#';
            $emptyX = $x, $emptyY= $y, last if $c eq '.';
        }

        next unless defined $emptyX;

        $x = $candidateX;
        $y = $candidateY;
        while ($x >= 0 && $x < $sizex && $y >= 0 && $y < $sizey) {
            $x += $direction->{x};
            $y += $direction->{y};
            $map[$y][$x] = 'O';
            last if $x == $emptyX && $y == $emptyY;
        }
    }

    $map[$posy][$posx] = '.';
    $posx=$candidateX;
    $posy=$candidateY;
    $map[$posy][$posx] = '@';

    printmap() if $debug;
}


my $sum = 0;
for my $y (0..$sizey-1) {
    for my $x (0..$sizex-1) {
        next unless $map[$y][$x] eq 'O';
        $sum += $y*100+$x;
    }
}
print $sum;




sub printmap
{
    print join "\n", (join '', @$_) for @map;
    print "\n";
}

