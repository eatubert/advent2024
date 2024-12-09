#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

my ($a,$b) = split /\s+/, $_;
our(@a,@b);
push @a, $a;
push @b, $b;

END {
	@a = sort @a;
	@b = sort @b;
	my $total;
	$total += abs($a - (scalar shift @b)) while ($a = shift @a);
	print $total;
}