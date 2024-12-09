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
    $total += $pages[((scalar @pages)+1)/2-1] if $ok;
}

print $total;
