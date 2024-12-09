#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

INIT {$/=undef}

my @ops;
push @ops,$1 while /(mul\(\d+,\d+\)|do\(\)|don't\(\))/g;

my $total;
my $state = 1;
for (@ops) {
    $state = 1 if /do\(\)/;
    $state = 0 if /don't\(\)/;
    $total += $1*$2 if $state && /mul\((\d+),(\d+)\)/
}
print $total;