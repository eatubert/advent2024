#!/usr/bin/perl -wln
use strict;
use warnings FATAL => 'all';

our $sum;
my $secret = $_;
$secret = pseudorandom($secret) for (1..2000);
#print "$_: $secret";
$sum += $secret;

END {
    print $sum;
}

sub mix
{
    my ($secret, $mix) = @_;
    return $secret ^ $mix;
}

sub prune
{
    my ($secret) = @_;
    return $secret % 16777216;
}

sub pseudorandom
{
    my ($secret) = shift;
    $secret = prune(mix($secret, $secret * 64));
    $secret = prune(mix($secret, int($secret / 32)));
    $secret = prune(mix($secret, $secret * 2048));
    return $secret;
}