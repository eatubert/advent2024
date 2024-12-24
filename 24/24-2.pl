#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;


main();

sub main
{
    my ($fname) = shift @ARGV or die "$0 [fname]";
    my ($values, $rules) = readInput($fname);
    #print Dumper $values, $rules;
    backtrack($rules);

    print join ',', sort qw(z16 fkb z31 rdn z37 rrn rqf nnr);
}

sub readInput
{
    my ($fname) = @_;
    my (%values, %rules);
    open my $fh, '<', $fname or die "Can't open $fname";
    while (<$fh>) {
        chomp;
        $values{$1} = int($2) if /^(.*): (\d)/;
        $rules{$4} = {
            in1 => $1,
            op  => $2,
            in2 => $3,
        } if /^(\S+) (AND|OR|XOR) (\S+) -> (\S+)$/;
    }

    return \%values, \%rules;
}

sub backtrackVariable
{
    my ($rules, $variable) = @_;

    return $variable if $variable =~ /^[xy]\d+$/;

    my @evals = sort {(length($a)<=>length($b)) || ($a cmp $b)} map {backtrackVariable($rules, $_)} $rules->{$variable}{in1}, $rules->{$variable}{in2};

    return join '',
        '(' ,
        (
            join ' ',
            $evals[0],
            $rules->{$variable}{op},
            $evals[1],
        ),
        ')';
}

sub backtrack
{
    my ($rules) = @_;
    for my $out (sort grep {/^z/} keys %$rules) {
        print "$out = ", backtrackVariable($rules, $out);
    }
}

