#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

our %coords;
our $row;
$row //= 0;
my @chars = split //;
our $sizex;
$sizex //= scalar @chars;
die join ',', $row,  $sizex,  scalar @chars unless $sizex == scalar @chars;

for my $column (0..$#chars) {
    next if $chars[$column] eq '.';
    push @{$coords{$chars[$column]}}, {
        x => $column,
        y => $row,
    };
}

++$row;

END {
    my %antinodes;
    my $sizey = $row;
    for my $type (keys %coords) {
        $sizex //= scalar @{$coords{$type}};

        for my $i (0..(scalar @{$coords{$type}} - 2)) {
            for my $j ($i+1..(scalar @{$coords{$type}} - 1)) {

                my $deltax = $coords{$type}[$i]{x} - $coords{$type}[$j]{x};
                my $deltay = $coords{$type}[$i]{y} - $coords{$type}[$j]{y};

                my $newx = $coords{$type}[$i]{x} + $deltax;
                my $newy = $coords{$type}[$i]{y} + $deltay;
                $antinodes{join ',', $newx, $newy}++ if ($newx >= 0 && $newx < $sizex && $newy >= 0 && $newy < $sizey);

                $newx = $coords{$type}[$j]{x} - $deltax;
                $newy = $coords{$type}[$j]{y} - $deltay;
                $antinodes{join ',', $newx, $newy}++ if ($newx >= 0 && $newx < $sizex && $newy >= 0 && $newy < $sizey);
            }
        }
    }
    #print for keys %antinodes;
    print scalar keys %antinodes;
}