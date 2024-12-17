#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';

my $debug = 0;

my $fname = shift or die "$0 [fname]";
open my $fh, '<', $fname or die "Can't open $fname";

my (@map, @moves);
{
    local $/ = "\n\n";
    @map = map {[map {s/#/##/; s/O/[]/; s/\./../; s/@/@./; split//} split //]} split /\n/, scalar <$fh>;
    @moves = map {split //} split /\n/, scalar <$fh>;
}
close $fh;

my ($sizex, $sizey);
$sizey = scalar @map;
$sizex = scalar @{$map[0]};

printmap() if $debug;
print join '', @moves if $debug;

my ($posx, $posy);
for my $y (0..$sizey-1) {
    for my $x (0..$sizex-1) {
        $posx=$x, $posy=$y, last if $map[$y][$x] eq '@';
    }
    last if defined $posx;
}
die unless defined $posx;




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
    if ($candidateC eq '[' || $candidateC eq ']') {
        if ($direction->{x}) {
            next unless moveX($posx, $posy, $direction->{x});
        }
        if ($direction->{y}) {
            next unless moveY($posx, $posy, $direction->{y});
            moveY($posx, $posy, $direction->{y}, 1);
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
        next unless $map[$y][$x] eq '[';
        $sum += $y*100+$x;
    }
}
print $sum;




sub printmap
{
    print join "\n", (join '', @$_) for @map;
    print "\n";
}


sub moveX
{
    my ($x, $y, $deltaX) = @_;
    my $nextX = $x+$deltaX;
    my $c = $map[$y][$x];
    my $nextC = $map[$y][$nextX];

    print join ',', map {$_//'?'} $x, $y, $deltaX, $nextX, $c, $nextC if $debug > 1;

    return 0 if $nextC eq '#';
    if ($nextC eq '.' || moveX($nextX, $y, $deltaX)) {
        $map[$y][$nextX] = $c;
        return 1;
    }
    return 0;
}


sub moveY
{
    my ($x, $y, $deltaY, $doMove) = @_;
    my $nextY = $y+$deltaY;
    my $c = $map[$y][$x];
    my $nextC = $map[$nextY][$x];

    print join ',', map {$_//'?'} $x, $y, $deltaY, $nextY, $c, $nextC, $doMove if $debug > 1;

    my $ret = 0;
    $ret = 1 if $nextC eq '.';
    $ret = 1 if $nextC eq '[' && moveY($x, $nextY, $deltaY, $doMove) && moveY($x+1, $nextY, $deltaY, $doMove);
    $ret = 1 if $nextC eq ']' && moveY($x-1, $nextY, $deltaY, $doMove) && moveY($x, $nextY, $deltaY, $doMove);

    if ($ret && defined $doMove) {
        $map[$nextY][$x+1] = '.' if $nextC eq '[';
        $map[$nextY][$x-1] = '.' if $nextC eq ']';
        $map[$nextY][$x] = $c;
    }

    return $ret;
}
