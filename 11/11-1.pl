#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';

INIT {
    our $rounds = shift;
    die "$0 [rounds] [filename]" unless $rounds =~ /\d+/;
}

our $rounds;
my $stones = [split /\s+/];
#print join ' ', @stones;

for (0..$rounds) {
    $stones = automata($stones);
    print STDERR "$_: ", join ' ', @$stones;
}

print scalar(@$stones);

sub automata
{
    my ($stones) = @_;
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