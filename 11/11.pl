#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

our $rounds;

INIT {
    $rounds = shift;
    die "$0 [rounds] [filename | stdin]" unless $rounds =~ /^\d+$/;
}

my $count = 0;
$count += walkTree($_, $rounds) for split /\s+/;
print $count;

sub step
{
    return 1 if $_[0] == 0;

    return (
        0+substr($_[0], 0, length($_[0])/2),
        0+substr($_[0], length($_[0])/2, length($_[0])/2)
    ) if length($_[0])%2 == 0;

    return $_[0] * 2024;
}

sub walkTree
{
    my ($actual, $round) = @_;
    return 1 unless $round;

    my $total = 0;
    our %cache;
    $total += ($cache{join ',', $_, $round} //= walkTree($_, $round-1)) for step($actual);

    return $total;
}