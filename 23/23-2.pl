#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper; $Data::Dumper::Sortkeys=1;


our %connections;
our @sets;

my ($computer1, $computer2) = split /-/;
$connections{$computer1}{$computer2} = undef;
$connections{$computer2}{$computer1} = undef;
push @sets, join ',', sort $computer1, $computer2;

END {
    my %visited;
    while (@sets) {
        my $set = shift @sets;
        next if exists $visited{$set};
        $visited{$set} = undef;

        my %newset = map {$_, undef} split /,/, $set;
        my $oldLength = scalar keys %newset;
        my %extra = map {$_, undef} grep {not exists $newset{$_}} map {keys %{$connections{$_}}} keys %newset;
        #print join ',', sort keys %newset;
        #print join ',', sort keys %extra;

        for my $candidate (sort keys %extra) {
            $newset{$candidate}=undef unless grep {not exists $connections{$candidate}{$_}} keys %newset;
        }

        #print join ',', sort keys %newset;
        #print '';
        push @sets, join ',', sort keys %newset if scalar keys %newset > $oldLength;
    }

    print((sort {length($b) <=> length($a)} keys %visited)[0]);
}