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

our %antinodes;
for my $column (0..$#chars) {
    next if $chars[$column] eq '.';
    push @{$coords{$chars[$column]}}, {
        x => $column,
        y => $row,
    };
    $antinodes{join ',', $column, $row}++;
}

++$row;

END {
    print Dumper \%coords;
    my $sizey = $row;
    for my $type (keys %coords) {
        $sizex //= scalar @{$coords{$type}};

        for my $i (0..(scalar @{$coords{$type}} - 2)) {
            for my $j ($i+1..(scalar @{$coords{$type}} - 1)) {

                my $deltax = $coords{$type}[$i]{x} - $coords{$type}[$j]{x};
                my $deltay = $coords{$type}[$i]{y} - $coords{$type}[$j]{y};

                my ($newx, $newy);
                $newx = $coords{$type}[$i]{x};
                $newy = $coords{$type}[$i]{y};
                while (1) {
                    $newx += $deltax;
                    $newy += $deltay;
                    last unless ($newx >= 0 && $newx < $sizex && $newy >= 0 && $newy < $sizey);
                    $antinodes{join ',', $newx, $newy}++
                }

                $newx = $coords{$type}[$j]{x};
                $newy = $coords{$type}[$j]{y};
                while (1) {
                    $newx -= $deltax;
                    $newy -= $deltay;
                    last unless ($newx >= 0 && $newx < $sizex && $newy >= 0 && $newy < $sizey);
                    $antinodes{join ',', $newx, $newy}++
                }
            }
        }
    }
    #print for keys %antinodes;
    print scalar keys %antinodes;
}