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
for my $gen (0..9999) {
    for my $robot (@robots) {
        $robot->{posx} = ($robot->{posx} + $robot->{vx}) % $sizex;
        $robot->{posy} = ($robot->{posy} + $robot->{vy}) % $sizey;
    }

    my @map;
    for my $y (0 .. $sizey - 1) {
        push @map, [ (0) x $sizex ];
    }
    $map[$_->{posy}][$_->{posx}]++ for @robots;

    my $maxXrunlength = 0;
    for my $y (0..$sizey-1) {
        my $runlength = 0;
        my $state = 0;
        for my $x (0..$sizex-1) {
            $state = $map[$y][$x] > 0;
            $runlength = $state ? $runlength + 1 : 0;
            $maxXrunlength = $runlength if $runlength > $maxXrunlength;
        }
    }

    if ($maxXrunlength > 10) {
        print "***", $gen+1, "***";
        print join '', map {$_ || ' '} @$_ for grep {$_} @map;
        print '';
    }
}
