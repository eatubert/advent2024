#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

main(shift);

sub main
{
    my ($fname) = @_;
    my ($maxHeight, $keys, $locks) = readInput($fname);
    my $count;
    #print $maxHeight;
    for my $lock (@$locks) {
        #print 'lock ', join ',', @$lock;
        for my $key (@$keys) {
            #print 'key ', join ',', @$key;
            my $fits = 1;
            for my $column (0..scalar @$lock-1) {
                #print join ',', $column, $lock->[$column], $key->[$column], '', $lock->[$column] + $key->[$column], $maxHeight;
                $fits = 0, last if $lock->[$column] + $key->[$column] > $maxHeight;
            }
            ++$count if $fits > 0;
            #print join "; ", (join ',', @$lock), (join ',', @$key)  if $fits > 0;
        }
        #print '';
    }
    print $count;
}

sub readInput
{
    my ($fname) = @_;
    my (@locks, @keys, $maxHeight);

    die "$0 [fname]" unless defined $fname;
    open my $fh, '<', $fname or die "Can't open $fname";
    $/ = "\n\n";
    while (my $input = <$fh>) {
        my $isKey = ($input =~ /^\./);
        my $target = $isKey ? \@keys : \@locks;

        my @lines = split /\n/, $input;
        my @heights = (-1) x length $lines[0];
        $maxHeight = scalar @lines - 2 unless defined $maxHeight;
        die "Height mismatch" unless $maxHeight == scalar @lines - 2;

        for my $line (@lines) {
            my @chars = split //, $line;
            for my $index (0..$#chars) {
                $heights[$index]++ if $chars[$index] eq '#';
            }
        }

        push @$target, \@heights;
    }

    return ($maxHeight, \@keys, \@locks);
}