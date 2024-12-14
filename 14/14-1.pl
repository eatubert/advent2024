#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

my $fname = shift or die;
open my $fh, '<', $fname or die;

#line 1 = SIZEXxSIZEY
my ($sizex, $sizey) = map {chomp; split /x/} scalar <$fh>;
#line 2 empty
scalar <$fh>;

my @robots;

while (<$fh>) {
    #p=0,4 v=3,-3
    my ($posx, $posy, $vx, $vy) = /p=(\d+),(\d+) v=(-?\d+),(-?\d+)/;
    push @robots, {
        posx => $posx,
        posy => $posy,
        vx   => $vx,
        vy   => $vy
    };
    die $_ unless defined $posx && defined $posy && defined $vx && defined $vy;
}

#simulate 100s of movement
for my $robot (@robots) {
    $robot->{posx} = ($robot->{posx} + $robot->{vx} * 100) % $sizex;
    $robot->{posy} = ($robot->{posy} + $robot->{vy} * 100) % $sizey;
}

my @map;
for my $y (0..$sizey-1) {
    push @map, [(0) x $sizex];
}
$map[$_->{posy}][$_->{posx}]++ for @robots;
print join '', map {$_||'.'} @$_ for grep {$_} @map;

my $halfx = int($sizex/2);
my $halfy = int($sizey/2);

my @sums = (0)x4;
for my $y (0..$sizey-1) {
    next if $y == $halfy;
    for my $x (0..$sizex-1) {
        next if $x == $halfx;
        my $q = ($x > $halfx)  + ($y > $halfy) * 2;

        $sums[$q] += $map[$y][$x];
    }
}

print join ',', @sums;
my $total = 1; $total *= $_ for @sums;
print $total;