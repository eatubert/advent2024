#!perl -wnl
use strict;
use warnings FATAL => 'all';

our @data = split /\s+/, $_;
my $sign = $data[1]-$data[0];
next unless $sign;
$sign = $sign/abs($sign);
our $safe;
while (my $d = shift @data) {
	$safe++, last unless defined $data[0];
	my $delta = ($data[0]-$d) / $sign;
	last unless 1 <= $delta && $delta <= 3;
}

END { print $safe }