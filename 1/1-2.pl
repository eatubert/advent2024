#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

my ($a,$b) = split /\s+/, $_;
our (@a, %b);
push @a, $a;
$b{$b}++;

END {
	my $total;
	$total += $_ * ($b{$_}//0) for @a;
	print $total;
}