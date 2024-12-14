#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Math::Matrix;
use Data::Dumper;

INIT {$/ = "\n\n"}


my ($ax, $ay, $bx, $by, $px, $py) = (0,0,0,0,0,0);

for (split /\n/, $_) {
    ($ax, $ay) = ($1, $2) if /Button A: X(.*), Y(.*)/;
    ($bx, $by) = ($1, $2) if /Button B: X(.*), Y(.*)/;
    ($px, $py) = ($1, $2) if /Prize: X=(.*), Y=(.*)/;
}

die $_ unless $ax && $ay && $bx && $by && $px && $py;

my $A = Math::Matrix->new([$ax, $bx, $px],[$ay, $by, $py]);
my $X = $A->solve;
my $x = $X->[0][0];
my $y = $X->[1][0];
my $roundX = sprintf('%.0lf', $x);
my $roundY = sprintf('%.0lf', $y);
my $int = abs($x-$roundX) < 0.001 && abs($y-$roundY) < 0.001;
my $low = $x < 100 && $y < 100;
#print join ',', $x, $y, $int, $low;

our $total;
$total += $roundX*3 + $roundY if $int && $low;

END {
    print $total;
}
