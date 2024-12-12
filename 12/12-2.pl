#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
no warnings 'recursion';

my $debug = 0;

our @map;
push @map, [split //, $_];

END {
    if ($debug) {
        print @$_ for @map;
    }
    my @regions = findRegions(\@map);
    my $cost = 0;
    $cost += $_->{area} * numSides($_) for @regions;
    print $cost;
}


sub isVisited
{
    my ($visited, $x, $y) = @_;
    my $id = join ',', $x,$y;
    return $visited->{$id};
}

sub markVisited
{
    my ($visited, $x, $y) = @_;
    my $id = join ',', $x,$y;
    $visited->{$id} = 1;
}

sub findRegions
{
    my ($map) = @_;
    my $sizey = scalar @$map;
    my $sizex = scalar @{$map->[0]};
    my %visited;
    my @ret;
    for my $y (0..$sizey-1) {
        for my $x (0..$sizex-1) {
            unless (isVisited(\%visited, $x,$y)) {
                my $region = {};
                findRegion($map, $x, $y, \%visited, $region);
                push @ret, $region;
                print Dumper $region if $debug;
                print '' if $debug;
            }
        }
    }
    return @ret;
}

sub findRegion
{
    my ($map, $x, $y, $visited, $region) = @_;

    markVisited($visited, $x, $y);
    ++$region->{area};

    my $name = $map->[$y][$x];
    $region->{name} //= $name;
    print join ',', $x, $y, $name//'?', $x>0, $x < (scalar @{$map->[0]})-1 if $debug;
    if ($x > 0 && $map->[$y][$x-1] eq $name) {
        unless (isVisited($visited, $x-1, $y)) {
            print '-x' if $debug;
            findRegion($map, $x - 1, $y, $visited, $region);
        }
    } else {
        print '-x perimeter' if $debug;
        push @{$region->{perimeterV}}, join ',', $x, $y;
    }

    if ($x < (scalar @{$map->[0]})-1 && $map->[$y][$x+1] eq $name) {
        unless (isVisited($visited, $x+1, $y)) {
            print '+x' if $debug;
            findRegion($map, $x+1, $y, $visited, $region);
        }
    } else {
        print '+x perimeter' if $debug;
        push @{$region->{perimeterV}}, join ',', $x+1, $y;
    }

    if ($y > 0 && $map->[$y-1][$x] eq $name) {
        unless (isVisited($visited, $x, $y-1)) {
            print '-y' if $debug;
            findRegion($map, $x, $y-1, $visited, $region);
        }
    } else {
        print '-y perimeter' if $debug;
        push @{$region->{perimeterH}}, join ',', $x, $y;
    }

    if ($y < (scalar @$map)-1 && $map->[$y+1][$x] eq $name) {
        unless (isVisited($visited, $x, $y+1)) {
            print '+y' if $debug;
            findRegion($map, $x, $y+1, $visited, $region);
        }
    } else {
        print '+y perimeter' if $debug;
        push @{$region->{perimeterH}}, join ',', $x, $y+1;
    }
}


sub numSides
{
    my ($region) = @_;

    my $ret = 0;
    my ($lastx, $lasty);

    $lastx = $lasty = -1;

    my @h = sort {
        my @a = split /,/, $a;
        my @b = split /,/, $b;
        ($a[1]<=>$b[1]) || ($a[0]<=>$b[0])
    } @{$region->{perimeterH}};

    my %h;
    @h{@{$region->{perimeterH}}} = @{$region->{perimeterH}};

    my @v = sort {
        my @a = split /,/, $a;
        my @b = split /,/, $b;
        ($a[0]<=>$b[0]) || ($a[1]<=>$b[1])
    } @{$region->{perimeterV}};

    my %v;
    @v{@{$region->{perimeterV}}} = @{$region->{perimeterV}};

    for (@h) {
        my ($x,$y) = split /,/, $_;
        ++$ret unless $y == $lasty && $x == $lastx+1 && !$v{join ',', $x,$y};
        $lastx = $x;
        $lasty = $y;
    }

    $lastx = $lasty = -1;


    for (@v) {
        my ($x,$y) = split /,/, $_;
        ++$ret unless $y == $lasty+1 && $x == $lastx && !$h{join ',', $x,$y};
        $lastx = $x;
        $lasty = $y;
    }

    if ($debug) {
        print join ' ', $region->{name}, @h;
        print join ' ', $region->{name}, @v;
        print join ' ', $region->{name}, $ret;
        print '';
    }
    return $ret;
}