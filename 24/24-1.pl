#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;


main();

sub main
{
    my ($fname) = shift @ARGV or die "$0 [fname]";
    my ($values, $pending) = readInput($fname);
    simulate($values, $pending);
    my $output = output($values);
    print $output;
}

sub readInput
{
    my ($fname) = @_;
    my (%values, %pending);
    open my $fh, '<', $fname or die "Can't open $fname";
    while (<$fh>) {
        chomp;
        $values{$1} = int($2) if /^(.*): (\d)/;
        $pending{$_} = {
            in1 => $1,
            op  => $2,
            in2 => $3,
            out => $4
        } if /^(\S+) (AND|OR|XOR) (\S+) -> (\S+)$/;
    }

    return \%values, \%pending;
}

sub simulate
{
    my ($values, $pending) = @_;

    while (keys %$pending) {
        for my $operationIndex (sort keys %$pending) {
            my $operation = $pending->{$operationIndex};
            my $in1 = $operation->{in1};
            my $in2 = $operation->{in2};
            my $op = $operation->{op};
            my $out = $operation->{out};

            next unless exists $values->{$in1} && exists $values->{$in2};
            $in1 = $values->{$in1};
            $in2 = $values->{$in2};
            $values->{$out} = $in1 | $in2 if $op eq 'OR';
            $values->{$out} = $in1 & $in2 if $op eq 'AND';
            $values->{$out} = $in1 ^ $in2 if $op eq 'XOR';
            delete $pending->{$operationIndex};
        }
    }
}


sub output
{
    my ($values) = @_;
    my @keys = reverse sort grep {/^z/} keys %$values;
    my $output = 0;
    $output = $output << 1 | $values->{$_} for @keys;
    return $output;
}