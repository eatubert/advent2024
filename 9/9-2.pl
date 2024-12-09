#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

my ($map, $fullblocks, $emptyblocks) = generateMap($_);
$map = compact($map, $fullblocks, $emptyblocks);
print calcChecksum($map);

sub generateMap
{
    my ($input) = @_;

    my (@output, @fullblocks, @emptyblocks);
    my $file = 0;
    for ($input =~ /..?/g) {
        my ($full, $empty) = split //, $_;
        $empty ||= 0;
        push @fullblocks, {id=>$file, len=>int($full), ofs=>scalar @output};
        push @output, $file for (0..$full-1);
        push @emptyblocks, {len=>$empty, ofs=>scalar @output} if $empty;
        push @output, '.' for (0..$empty-1);

        ++$file;
    }

    return \@output, \@fullblocks, \@emptyblocks;
}


sub compact
{
    my ($map, $fullblocks, $emptyblocks) = @_;

    for my $full (reverse @$fullblocks) {
        my @candidates = grep {$_->{len} >= $full->{len} && $_->{ofs} < $full->{ofs}} @$emptyblocks;
        next unless @candidates;

        for my $i (0..$full->{len}-1) {
            $map->[$candidates[0]{ofs} + $i] = $full->{id};
            $map->[$full->{ofs} + $i] = '.';
        }

        $candidates[0]{len} -= $full->{len};
        $candidates[0]{ofs} += $full->{len};
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