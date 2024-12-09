#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

my $fname = shift || '-';
open my $fh, '<', $fname or die;
my (%rules, $updates);
{
    local $/ = "\n\n";
    %rules = map {$_, 1} split /\n/, scalar <$fh>;
    $updates = scalar <$fh>;
}

my $total;
for my $update (split /\n/, $updates) {
    my @pages = split /,/, $update;
    my $ok = 1;
    for my $i (0..$#pages-1) {
        for my $j ($i+1..$#pages) {
            my $rule = join '|', $pages[$i],$pages[$j];
            $ok = $rules{$rule};
            last unless $ok;
        }
        last unless $ok;
    }
    if (!$ok) {
        my @order;
        my %pendingset = map {$_,1} @pages;
        my $numpages = scalar @pages;
        for (0..$numpages-1) {
            my @pending = keys %pendingset;
            for my $candidateIndex (0..$#pending) {
                my $candidate = $pending[$candidateIndex];
                my @others = grep {$_ != $candidate} @pending;
                if (!grep {!exists $rules{join '|', $candidate, $_}} @others) {
                    push @order, $candidate;
                    delete $pendingset{$candidate};
                    last;
                }
            }
        }
        die "No answer for $update" if %pendingset;
        $total += $order[($#order+1)/2];
    }
}

print $total;
