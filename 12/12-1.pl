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
    $cost += $_->{area} * $_->{perimeter} for @regions;
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
        ++$region->{perimeter};
    }

    if ($x < (scalar @{$map->[0]})-1 && $map->[$y][$x+1] eq $name) {
        unless (isVisited($visited, $x+1, $y)) {
            print '+x' if $debug;
            findRegion($map, $x+1, $y, $visited, $region);
        }
    } else {
        print '+x perimeter' if $debug;
        ++$region->{perimeter};
    }

    if ($y > 0 && $map->[$y-1][$x] eq $name) {
        unless (isVisited($visited, $x, $y-1)) {
            print '-y' if $debug;
            findRegion($map, $x, $y-1, $visited, $region);
        }
    } else {
        print '-y perimeter' if $debug;
        ++$region->{perimeter};
    }

    if ($y < (scalar @$map)-1 && $map->[$y+1][$x] eq $name) {
        unless (isVisited($visited, $x, $y+1)) {
            print '+y' if $debug;
            findRegion($map, $x, $y+1, $visited, $region);
        }
    } else {
        print '+y perimeter' if $debug;
        ++$region->{perimeter};
    }
}