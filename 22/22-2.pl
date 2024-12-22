#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

our $sum;
our %allOptions;
my ($options, $last) = calcSequences($_, 2000);
$sum += $last;
$allOptions{$_} += $options->{$_} for keys %$options;
#print "LAST $_: $last";
#print "$_: $options->{$_}" for sort {$options->{$b}<=>$options->{$a}} keys %$options;
#print "";

END {
    #print $sum;
    my $best = (sort {$allOptions{$b}<=>$allOptions{$a}} keys %allOptions)[0];
    print("$best: $allOptions{$best}");
}

sub calcSequences
{
    my ($secret, $iterations) = @_;
    my $input = $secret;

    my @sequence;
    my %prices;

    my $last;
    for (1..$iterations) {
        my $price = $secret % 10;
        push @sequence, $price - $last if defined $last;
        shift @sequence if @sequence > 4;
        $prices{join ',', @sequence} //= $price if @sequence == 4;
        $last = $price;
        #printf "%8i %8i: %i (%s)\n", $input, $secret, $price, (join ',', @sequence);
        $secret = pseudorandom($secret);
    }

    return \%prices, $secret;
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