#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;


our %connections;
our %threesomes;

my ($computer1, $computer2) = split /-/;

$threesomes{join ',', sort ($computer1, $computer2, $_)} = undef for grep {exists $connections{$computer2}{$_}} (keys %{$connections{$computer1}});

$connections{$computer1}{$computer2} = undef;
$connections{$computer2}{$computer1} = undef;
END {
    print scalar (grep {/^t/ || /,t/} sort keys %threesomes);
}