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
    walk($posx, $posy, '>', [], {}, \%bestPath);
    walk($posx, $posy, '^', [], {}, \%bestPath);
    walk($posx, $posy, 'v', [], {}, \%bestPath);
    walk($posx, $posy, '<', ['R'], {}, \%bestPath);
    print $bestPath{cost};
}


my %directions = (
    '^' => { x => 0, y => -1 },
    '<' => { x => -1, y => 0 },
    'v' => { x => 0, y => 1 },
    '>' => { x => 1, y => 0},
);

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

sub walk
{
    my ($x, $y, $direction, $path, $visited, $bestPath) = @_;
    #print join ',', $x, $y, $direction, (join '', @$path), (join '|', keys %$visited);
    return if isVisited($x, $y, $visited);

    my %newvisited = %$visited;
    markVisited($x, $y, \%newvisited);

    die  join ',', $x, $y, $direction, (join '', @$path), (join '|', keys %$visited) unless $directions{$direction};

    my $newx = $x + $directions{$direction}{x};
    my $newy = $y + $directions{$direction}{y};
    my $newc = $map[$newy][$newx];

    return if $newc eq '#';

    my $newPath = [@$path, $direction];

    if ($newc eq 'E') {
        my $moves = scalar (grep {/[v^><]/} @$newPath);
        my $last = '>';
        my $turns;
        for (@$newPath) {
            ++$turns unless $_ eq $last;
            $last = $_;
        }
        my $cost = $moves + $turns * 1000;

        if ((not defined $bestPath->{cost}) || ($cost < $bestPath->{cost})) {
            $bestPath->{path} = join '', @$newPath;
            $bestPath->{cost} = $cost;
        }

        return;
    }

    walk($newx, $newy, $direction, $newPath, \%newvisited, $bestPath);
    if ($direction eq '^' || $direction eq 'v') {
        walk($newx, $newy, '>', $newPath, \%newvisited, $bestPath);
        walk($newx, $newy, '<', $newPath, \%newvisited, $bestPath);
    }
    if ($direction eq '>' || $direction eq '<') {
        walk($newx, $newy, '^', $newPath, \%newvisited, $bestPath);
        walk($newx, $newy, 'v', $newPath, \%newvisited, $bestPath);
    }
}