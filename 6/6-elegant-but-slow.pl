#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Math::Complex;

our @board;
push @board, [split //, $_];

sub findpath
{
    my ($boardhash) = @_;
    my $dir = -i;
    my $pos = (grep {$boardhash->{$_} eq '^'} keys %$boardhash)[0];
    my %seen;

    while (1) {
        $seen{$pos}{$dir} = 1;
        my $new = $pos + $dir;

        #loop
        return [ keys %seen ], 1 if $seen{$new} && $seen{$new}{$dir};

        #exit board
        return [ keys %seen ], 0 unless $boardhash->{$new};

        if ($boardhash->{$new} eq '#') {
            $dir *= i;
        }
        else {
            $pos = $new;
        }
    }
}

END {
    my $sizex = scalar @board;
    my $sizey = scalar @{$board[0]};

    my %boardhash;
    for my $x (0 .. $sizex - 1) {
        for my $y (0 .. $sizey - 1) {
            $boardhash{Math::Complex->make($x,$y)} = $board[$y][$x];
        }
    }

    my ($path, $loop) = findpath(\%boardhash);
    print "6-1: ",scalar(@$path);
    print "6-2: ",scalar(grep {my %t=%boardhash; $t{$_}='#'; (findpath(\%t))[1]} grep {$boardhash{$_} ne '^'} @$path);
}