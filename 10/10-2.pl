#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

our @map;
push @map, [split //];
our ($sizex, $sizey);
++$sizey;
$sizex //= scalar(@{$map[0]});

sub findPaths
{
    my ($x,$y,$paths) = @_;
    my $current = $map[$y][$x];

    if ($current == 9) {
        $paths->{join ',', $x, $y}++;
        return;
    }

    findPaths($x+1,$y,$paths) if $x < $sizex-1 && $map[$y][$x+1] eq $current+1;
    findPaths($x-1,$y,$paths) if $x > 0 && $map[$y][$x-1] eq $current+1;
    findPaths($x,$y+1,$paths) if $y < $sizey-1 && $map[$y+1][$x] eq $current+1;
    findPaths($x,$y-1,$paths) if $y > 0 && $map[$y-1][$x] eq $current+1;
}

sub countPaths
{
    my ($x,$y) = @_;
    my %paths;
    findPaths($x,$y,\%paths);
    my $rating;
    $rating += $paths{$_} for keys %paths;
    return $rating;
}

END {
    my $total;
    for my $y (0..$sizey-1) {
        for my $x (0..$sizex-1) {
            $total += countPaths($x,$y) if $map[$y][$x] eq '0';
        }
    }

    print $total;
}