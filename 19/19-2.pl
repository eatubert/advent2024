#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';

my $fname = shift or die "$0 [fname]";
main($fname);


sub readInput
{
    my ($fname) = shift;
    open my $fh, '<', $fname or die "Can't open $fname";
    my @options = split /, /, (map {chomp; $_}  scalar <$fh>)[0];
    scalar <$fh>;
    my @targets = map {chomp; $_} <$fh>;

    #print join ',', @options;
    #print join ',', @targets;

    return \@options, \@targets;
}

sub main
{
    my ($fname) =shift;
    my ($options, $targets) = readInput($fname);

    #print join ',', @$targets;
    my $sum = 0;
    $sum += match($_, $options, "", {}) for @$targets;
    print $sum;
}

sub match
{
    my ($target, $options, $prefix, $cache) = @_;

    $prefix //= '';
    my $remains = substr($target, length $prefix);
    #print "Target: $target, prefix=$prefix, remains=$remains";

    if ($remains eq '') {
        #print "MATCH";
        return 1;
    }
    if (defined $cache->{$prefix}) {
        #print "CACHE $prefix = $cache->{$prefix}";
        return $cache->{$prefix};
    }

    my @candidates = grep {substr($remains, 0, length $_) eq $_} @$options;
    #print join ',', "Candidates", @candidates;

    my $ret = 0;
    for (@candidates) {
        $ret += match($target, $options, $prefix.$_, $cache);
    }
    #print "RESULT $prefix = $ret";
    $cache->{$prefix} = $ret if $prefix ne '';
    return $ret;
}