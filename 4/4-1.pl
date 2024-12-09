#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

our @lines;
push @lines, [split //, $_];

END {
    my $total;
    my $numrows = scalar @lines;
    my $numcolumns = scalar @{$lines[0]};
    for my $row (0..($numrows-1)) {
        for my $col (0..($numcolumns-1)) {
            next unless $lines[$row][$col] eq 'X';
            $total++ if $col<=$numcolumns-4 &&
                $lines[$row][$col+1] eq 'M' &&
                $lines[$row][$col+2] eq 'A' &&
                $lines[$row][$col+3] eq 'S';
            $total++ if $col>=3 &&
                $lines[$row][$col-1] eq 'M' &&
                $lines[$row][$col-2] eq 'A' &&
                $lines[$row][$col-3] eq 'S';
            $total++ if $row<=$numrows-4 &&
                $lines[$row+1][$col] eq 'M' &&
                $lines[$row+2][$col] eq 'A' &&
                $lines[$row+3][$col] eq 'S';
            $total++ if $row>=3 &&
                $lines[$row-1][$col] eq 'M' &&
                $lines[$row-2][$col] eq 'A' &&
                $lines[$row-3][$col] eq 'S';
            $total++ if $col<=$numcolumns-4 &&
                $row<=$numrows-4 &&
                $lines[$row+1][$col+1] eq 'M' &&
                $lines[$row+2][$col+2] eq 'A' &&
                $lines[$row+3][$col+3] eq 'S';
            $total++ if $col>=3 &&
                $row>=3 &&
                $lines[$row-1][$col-1] eq 'M' &&
                $lines[$row-2][$col-2] eq 'A' &&
                $lines[$row-3][$col-3] eq 'S';
            $total++ if $col<=$numcolumns-4 &&
                $row>=3 &&
                $lines[$row-1][$col+1] eq 'M' &&
                $lines[$row-2][$col+2] eq 'A' &&
                $lines[$row-3][$col+3] eq 'S';
            $total++ if $col>=3 &&
                $row<=$numrows-4 &&
                $lines[$row+1][$col-1] eq 'M' &&
                $lines[$row+2][$col-2] eq 'A' &&
                $lines[$row+3][$col-3] eq 'S';
        }
    }

    print $total;
}