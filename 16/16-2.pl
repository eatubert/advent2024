#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use Tie::Array::Sorted;


my $debug = 1;
use constant INFINITE => 1_000_000_000;

our @map;
push @map, [split //];

END {
    my ($sizex, $sizey);
    $sizey = scalar @map;
    $sizex = scalar @{$map[0]};

    printMap(\@map) if $debug > 0;

    my ($posx, $posy, $endx, $endy);
    my @vertices;
    my $directions = [
        [ -1, 0 ], [ 1, 0 ], [ 0, 1 ], [ 0, -1 ]
    ];
    for my $y (0 .. $sizey - 1) {
        for my $x (0 .. $sizex - 1) {
            $posx = $x, $posy = $y if $map[$y][$x] eq 'S';
            $endx = $x, $endy = $y if $map[$y][$x] eq 'E';
        }
    }

    die unless defined $posx && defined $endx;

    my @directions = ([ 1, 0 ], [ 0, 1 ], [ -1, 0 ], [ 0, -1 ]);

    my @pending;
    tie @pending, "Tie::Array::Sorted", sub {$_[0][0] <=> $_[1][0]};
    # pending = (cost, pos, directionIndex, path)

    my %visited;
    # visited = pos,dir => cost

    my %inOptimal;
    # inOptimal = pos => undef;

    my $lowestCost;
    my $start = join ',', $posx, $posy;
    push @pending, [ 0, $start, 0, [ join ',', $start ] ];
    while (@pending) {
        #print Dumper \@pending;
        my ($cost, $pos, $directionIndex, $path) = @{shift @pending};
        last if (defined $lowestCost) && ($cost > $lowestCost);

        #print join ',', $cost, $pos, $directionIndex, ("(".(join '; ', @$path).")");
        my ($x,$y) = split /,/, $pos;
        if (($x == $endx) && ($y == $endy)) {
            $lowestCost = $cost;
            $inOptimal{$_} = undef for @{$path};
            next
        }

        next unless visit(\%visited, $pos, $directionIndex, $cost);

        my $nextx = $x + $directions[$directionIndex][0];
        my $nexty = $y + $directions[$directionIndex][1];
        my $nextpos = join ',', $nextx, $nexty;

        push @pending, [$cost+1, $nextpos, $directionIndex, [@$path, $nextpos]] if $map[$nexty][$nextx] ne '#' && visit(\%visited, $nextpos, $directionIndex, $cost+1);
        push @pending, [$cost+1000, $pos, ($directionIndex+1)%4, [@$path]] if visit(\%visited, $pos, ($directionIndex+1)%4, $cost+1000);
        push @pending, [$cost+1000, $pos, ($directionIndex-1)%4, [@$path]] if visit(\%visited, $pos, ($directionIndex-1)%4, $cost+1000);
    }

    for (keys %inOptimal) {
        my ($x,$y) = split /,/, $_;
        $map[$y][$x] = 'O';
    };

    printMap(\@map);
    print scalar keys %inOptimal;
}


sub visit
{
    my ($visited, $pos, $dir, $cost) = @_;
    my $key = join ',', $pos, $dir;
    return 0 if $cost > ($visited->{$key}//INFINITE);
    $visited->{$key} = $cost;
    return 1;
}


sub printMap
{
    my ($map) = @_;
    print for map {join '', @$_} @$map;
}

