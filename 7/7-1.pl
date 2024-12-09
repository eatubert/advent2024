#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

sub match
{
    my ($expected, @terms) = @_;

    for my $combo (0..2**$#terms-1) {
        my $result = $terms[0];
        for my $term (0..$#terms-1) {
            my $opstring = join '', $result, ($combo & (1<<$term)) ? '+' : '*', $terms[$term+1];
            $result = eval($opstring);
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