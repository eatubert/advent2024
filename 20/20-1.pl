#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

my $debug = 0;
my $fname = shift or die "$0 [fname]";
main($fname);

sub readmap
{
    my ($fname) = @_;
    open my $fh, '<', $fname or die "Can't open $fname";
    my @map = map {chomp; [split //, $_]} <$fh>;
    my $sizey = scalar @map;
    my $sizex = scalar @{$map[0]};
    die "Wrong size" if $sizey != $sizex;
    my ($startx, $starty, $endx, $endy);
    for my $y (0..$sizey-1) {
        for my $x (0..$sizex-1) {
            $startx = $x, $starty = $y if $map[$y][$x] eq 'S';
            $endx = $x, $endy = $y if $map[$y][$x] eq 'E';
        }
    }
    die "No start" unless defined $startx;
    die "No end" unless defined $endx;

    return \@map, $sizey, (join ',', $startx, $starty), (join ',', $endx, $endy);
}


sub findPath
{
    my ($map, $start, $end) = @_;
    my @path;
    my ($x, $y) = split /,/, $start;
    my ($endx, $endy) = split /,/, $end;

    my @directions = (
        [1,0], [-1,0], [0,1], [0,-1]
    );

    my ($lastx, $lasty) = (-1,-1);

    push @path, join ',', $x, $y;
    do {
        my $delta = (grep {
            my $newy = $y+$_->[1];
            my $newx = $x+$_->[0];

            $map->[$newy][$newx] ne '#' && ($newx != $lastx || $newy != $lasty)
        } @directions)[0];

        $lastx = $x; $lasty = $y;

        $x += $delta->[0];
        $y += $delta->[1];
        push @path, join ',', $x, $y;
    } while ($x != $endx || $y != $endy);

    return \@path;
}

sub printMap
{
    my ($map) = @_;
    print for map {join '', @$_} @$map;
    print "";
}

sub findSavings {
    my ($map, $size, $start, $end, $path) = @_;
    my %path; @path{@$path} = (0..scalar @$path-1);
    my $length = scalar @$path;

    my @directions = (
        [-2,0], [2,0], [0,-2], [0,2]
    );

    my %cheatSavings;
    for my $index (0..scalar @$path-2) {
        my ($x,$y) = split /,/, $path->[$index];
        for my $direction (@directions) {
            my $newx = $x + $direction->[0];
            my $newy = $y + $direction->[1];

            next if $newx < 0 || $newx >= $size;
            next if $newy < 0 || $newy >= $size;
            next unless exists $path{join ',', $newx, $newy};
            next if $path{join ',', $newx, $newy} < $path{join ',', $x, $y};

            my $cheatx = ($x+$newx)/2;
            my $cheaty = ($y+$newy)/2;
            next if exists $path{join ',', $cheatx, $cheaty};

            print "Cheat $x,$y => $newx,$newy ($cheatx,$cheaty)" if $debug > 0;
            my $savings = $path{join ',', $newx, $newy} - $index - 2;
            print "Savings ($cheatx,$cheaty) = ", $savings if $debug > 0;
            $cheatSavings{$savings}++;
        }
    }

    if ($debug > 0) {
        print "Savings $_=$cheatSavings{$_}" for sort {$a <=> $b} keys %cheatSavings;
    }
    return \%cheatSavings;
}

sub main
{
    my ($fname) = @_;
    my ($map, $size, $start, $end) = readmap($fname);
    if ($debug > 0) {
        printMap($map);
        print "Size=$size";
        print "Start=$start";
        print "End=$end";
    }
    my $path = findPath($map, $start, $end);
    print "Path=", join '; ', @$path if $debug > 0;

    my $cheatSavings = findSavings($map, $size, $start, $end, $path);
    my $sum = 0;
    $sum += $cheatSavings->{$_} for grep {$_ >= 100} keys %$cheatSavings;
    print $sum;
}