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

our (@originalboard, $sizex, $sizey);
push @originalboard, [split //, $_];

sub printboard
{
    print join '', @{$_} for @_;
    print '';
}

sub duplicateboard
{
    my @board;
    for (@originalboard) {
        push @board, [@{$_}];
    }
    return @board;
}

sub solveboard
{
    my ($x,$y,$guardx,$guardy) = @_;
    my @board = duplicateboard();
    $board[$y][$x] = 'O' if defined $x;

    my $direction = 0;
    my %visited;

    while ($guardx>=0 && $guardy>=0 && $guardx<$sizex && $guardy<$sizey) {
        $board[$guardy][$guardx] = $directions[$direction]{c};
        #printboard(@board);
        if (exists $visited{$guardy}{$guardx}{$direction}) {
            #printboard(@board);
            return undef;
        }

        $visited{$guardy}{$guardx}{$direction} = undef;
        $board[$guardy][$guardx] = 'X';

        my ($newx, $newy);
        while (1) {
            $newx = $guardx+$directions[$direction]{x};
            $newy = $guardy+$directions[$direction]{y};

            last if $newx < 0 || $newy < 0;
            last if $newx >= $sizex || $newy >= $sizey;
            last unless ($board[$newy][$newx] =~ /[#O]/);
            $direction = ($direction+1) % scalar @directions;
        }

        $guardx = $newx;
        $guardy = $newy;
    }

    return @board;
}

END {
    $sizex = scalar @originalboard;
    $sizey = scalar @{$originalboard[0]};

    my ($guardx, $guardy);
    for my $x (0..$sizex-1) {
        for my $y (0..$sizey-1) {
            if ($originalboard[$y][$x] eq '^') {
                $guardx = $x;
                $guardy = $y;
            }
        }
    }
    die unless defined $guardx;

    my @originalpath = solveboard(undef,undef,$guardx,$guardy);

    my $count = 0;
    for my $y (0..$sizey-1) {
        for my $x (0..$sizex-1) {
            next unless $originalboard[$y][$x] eq '.';
            next unless $originalpath[$y][$x] eq 'X';
            next if defined solveboard($x,$y,$guardx,$guardy);
            #print join ',', $x, $y;
            ++$count;
        }
    }

    print $count;
}