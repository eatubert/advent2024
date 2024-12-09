#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

our @lines;
push @lines, [split //, $_];

END {
    my $total;
    my $numrows = scalar @lines;
    my $numcolumns = scalar @{$lines[0]};
    for my $row (1..($numrows-2)) {
        for my $col (1..($numcolumns-2)) {
            next unless $lines[$row][$col] eq 'A';
            my $s1 = join '', $lines[$row-1][$col-1],$lines[$row+1][$col+1];
            my $s2 = join '', $lines[$row-1][$col+1],$lines[$row+1][$col-1];

            ++$total if ($s1 eq 'MS' || $s1 eq 'SM') && ($s2 eq 'MS' || $s2 eq 'SM');
        }
    }

    print $total;
}