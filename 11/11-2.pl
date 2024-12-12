#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

INIT {
    our $rounds = shift;
    die "$0 [rounds] [filename]" unless $rounds =~ /\d+/;
}

our $rounds;
my @stones = split /\s+/;

my %children;
my @pending = @stones;

for (0..$rounds-1) {
    print join ': ', $_, scalar @pending;
    my @nextpending;
    for my $candidate (@pending) {
        my $next = automata($candidate);
        #print join '->', $candidate, join ',', @$next;
        $children{$candidate} = $next;
        push @nextpending, grep {not exists $children{$_}} @$next;
    }
    @pending = @nextpending;
}

my $count = 0;
$count += walkTree($_, 0) for @stones;
print $count;

sub automata
{
    my $stones = [@_];
    my @ret;
    for (@{$stones}) {
        if ($_ == 0) {
            push @ret, 1;
        } elsif (length($_)%2 == 0) {
            push @ret, 0+substr($_, 0, length($_)/2);
            push @ret, 0+substr($_, length($_)/2, length($_)/2);
        } else {
            push @ret, $_ * 2024;
        }
    }
    return \@ret;
}



sub walkTree
{
    my ($actual, $depth) = @_;
    return 1 if $depth == $rounds;

    my $total;
    $total += walkTree($_, $depth+1) for @{$children{$actual}};
    return $total;
}