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
    my $size = @$map;
    print "    ",(join '', map {int($_/100) || ' '} (0..$size-1));
    print "    ",(join '', map {(int($_/10) % 10) || ' '} (0..$size-1));
    print "    ",(join '', map {$_ % 10} (0..$size-1));

    my $row = 0;
    printf "%3i $_\n", $row++ for map {join '', @$_} @$map;
    print "";
}

sub findSavings {
    my ($map, $path) = @_;
    my %path; @path{@$path} = (0..scalar @$path-1);
    my $length = scalar @$path;

    my %cheatSavings;
    for my $i (0..$length-2) {
        my ($x1,$y1) = split /,/, $path->[$i];
        for my $j ($i+1..$length-1) {
            my ($x2,$y2) = split /,/, $path->[$j];
            my $distance = abs($x2-$x1)+abs($y2-$y1);
            next if $distance > 20;
            my $savings = $j-$i-$distance;
            $cheatSavings{$savings}++;
        }
    }

    if ($debug >= 1) {
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

    my $cheatSavings = findSavings($map, $path);
    my $sum = 0;
    $sum += $cheatSavings->{$_} for grep {$_ >= 100} keys %$cheatSavings;
    print $sum;
}