#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

INIT {$/=undef}

my $total;
$total += $1*$2 while /mul\((\d+),(\d+)\)/g;
print $total;