#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

sub match
{
    my ($expected, @terms) = @_;

    my @ops = ('+', '*', '.');

    for my $combo (0..3**$#terms-1) {
        my $result = $terms[0];
        for my $term (0..$#terms-1) {
            my $op = $ops[$combo % 3];
            if ($op eq '.') {
                $result .= $terms[$term+1];
            } elsif ($op eq '+') {
                $result += $terms[$term+1];
            } elsif ($op eq '*') {
                $result *= $terms[$term+1];
            }
            $combo = int ($combo/3);
        }
        return 1 if $result == $expected;
    }
    return 0;
}

our $total;
my ($result, @terms) = split /[: ]+/;
$total += $result if match($result, @terms);

END {
    print $total;
}