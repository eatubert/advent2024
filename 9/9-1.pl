#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

my $map = generateMap($_);
$map = compact($map);
print calcChecksum($map);

sub generateMap
{
    my ($input) = @_;
    my @output;
    my $file = 0;
    for ($input =~ /..?/g) {
        my ($full, $empty) = split //, $_;
        $empty ||= 0;
        push @output, $file for (0..$full-1);
        push @output, '.' for (0..$empty-1);
        ++$file;
    }
    return \@output;
}


sub hasGaps
{
    my ($map) = @_;
    my $mapString = join '', @$map;
    return $mapString =~ /\d\.+\d/;
}


sub findEmpty
{
    my ($array) = @_;
    return $_ for grep {$array->[$_] eq '.'} (0..(scalar @$array)-1);
}

sub findFull
{
    my ($array) = @_;
    return $_ for grep {$array->[$_] ne '.'} (0..(scalar @$array)-1);
}


sub compact
{
    my ($map) = @_;
    my $left = 0;
    my $right = (scalar @$map)-1;
    while ($left < $right) {
        ++$left while $left < $right && $map->[$left] ne '.';
        --$right while $left < $right && $map->[$right] eq '.';
        if ($left < $right) {
            ($map->[$left], $map->[$right]) = ($map->[$right], $map->[$left]);
        }
    }
    return $map;
}


sub calcChecksum
{
    my ($map) = @_;
    my $checksum;
    $checksum += $_ * $map->[$_] for grep {$map->[$_] =~ /\d/} (0..(scalar @$map)-1);
    return $checksum;
}