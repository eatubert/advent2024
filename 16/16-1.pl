#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
no warnings 'recursion';

my $debug = 0;

our @map;
push @map, [split //];

END {
    my ($sizex, $sizey);
    $sizey = scalar @map;
    $sizex = scalar @{$map[0]};

    my ($posx, $posy, $endx, $endy);
    for my $y (0..$sizey-1) {
        for my $x (0..$sizex-1) {
            $posx=$x, $posy=$y if $map[$y][$x] eq 'S';
            $endx=$x, $endy=$y if $map[$y][$x] eq 'E';
            last if defined $posx && defined $endx;
        }
        last if defined $posx && defined $endx;
    }

    die unless defined $posx && defined $endx;

    my %bestPath;
    walk($posx, $posy, undef, [], {}, \%bestPath);
    print Dumper \%bestPath;
    print $bestPath{cost};
}


sub visitedIndex { join ',', @_ }

sub isVisited
{
    my ($x, $y, $visited) = @_;
    exists $visited->{visitedIndex($x, $y)}
}

sub markVisited
{
    my ($x, $y, $visited) = @_;
    $visited->{visitedIndex($x, $y)} = undef;
}

sub clearVisited
{
    my ($x, $y, $visited) = @_;
    delete $visited->{visitedIndex($x, $y)};
}

sub walk
{
    my ($x, $y, $direction, $path, $visited, $bestPath) = @_;
    print STDERR join ',', sprintf('%3i', $x), sprintf('%3i', $y), (join '', @$path), (join '|', keys %$visited);
    my $c = $map[$y][$x];

    markVisited($x, $y, $visited);
    push @$path, $direction if $direction;

    if ($c eq 'E') {
        my $moves = scalar (grep {/[v^><]/} @$path);
        my $last = '>';
        my $turns;
        for (@$path) {
            ++$turns unless $_ eq $last;
            $last = $_;
        }
        my $cost = $moves + $turns * 1000;

        print STDERR join ',', $moves, $turns, $cost, join '', @$path;

        if ((not defined $bestPath->{cost}) || ($cost < $bestPath->{cost})) {
            $bestPath->{path} = join '', @$path;
            $bestPath->{cost} = $cost;
        }
    } else {
        walk($x+1, $y, '>', $path, $visited, $bestPath) if $map[$y][$x+1] ne '#' && !isVisited($x+1,$y,$visited);
        walk($x-1, $y, '<', $path, $visited, $bestPath) if $map[$y][$x-1] ne '#' && !isVisited($x-1,$y,$visited);
        walk($x, $y+1, 'v', $path, $visited, $bestPath) if $map[$y+1][$x] ne '#' && !isVisited($x,$y+1,$visited);
        walk($x, $y-1, '^', $path, $visited, $bestPath) if $map[$y-1][$x] ne '#' && !isVisited($x,$y-1,$visited);
    }

    clearVisited($x, $y, $visited);
    pop @$path;
}