#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

our $debug;
our @directions;

INIT {
    $debug = 0;
    @directions = (
        {x=>0,y=>-1,c=>'^'},
        {x=>1,y=>0,c=>'>'},
        {x=>0,y=>1,c=>'v'},
        {x=>-1,y=>0,c=>'<'},
    );
}

our (@board, $sizex, $sizey);
push @board, [split //, $_];

sub printboard
{
    print join '', @{$_} for @_;
    print '';
}

END {
    $sizex = scalar @board;
    $sizey = scalar @{$board[0]};

    my ($guardx, $guardy);
    for my $x (0..$sizex-1) {
        for my $y (0..$sizey-1) {
            if ($board[$y][$x] eq '^') {
                $guardx = $x;
                $guardy = $y;
            }
        }
    }
    die unless defined $guardx;

    my $direction = 0;

    while ($guardx>=0 && $guardy>=0 && $guardx<$sizex && $guardy<$sizey) {
        $board[$guardy][$guardx] = $directions[$direction]{c};
        #printboard(@board);
        $board[$guardy][$guardx] = 'X';

        my ($newx, $newy);
        while (1) {
            $newx = $guardx+$directions[$direction]{x};
            $newy = $guardy+$directions[$direction]{y};

            last if $newx < 0 || $newy < 0;
            last if $newx >= $sizex || $newy >= $sizey;
            last unless $board[$newy][$newx] eq '#';
            $direction = ($direction+1) % scalar @directions;
        }

        $guardx = $newx;
        $guardy = $newy;
    }

    print scalar ( grep {$_ eq 'X'} map {@$_} @board );
}