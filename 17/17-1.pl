#!/usr/bin/perl -w
use strict;
use warnings FATAL => 'all';
use feature 'say';

my $fname = shift or die "$0 [fname]";
my $debug = shift // 0;
main($fname);

sub main {
    my $fname = shift;
    my ($ra, $rb, $rc, @program) = readinput($fname);
    my $ip = 0;
    while ($ip < scalar @program) {
        my $opcode = $program[$ip];
        my $operand = $program[$ip+1];

        say "IP=$ip, Opcode: $opcode, operand: $operand, ra=$ra (${\(sprintf '%03b', $ra % 8)}), rb=$rb (${\(sprintf '%03b', $rb % 8)}), rc=$rc (${\(sprintf '%03b', $rc % 8)})" if $debug > 0;

        my $newip;
        ($ra, $rb, $rc, $newip) = process($opcode, $operand, $ra, $rb, $rc);
        say "IP=$newip" if $debug > 0 && defined $newip;
        $ip = defined $newip ? $newip : $ip+2;
    }
}

sub readinput {
    open my $fh, '<', $fname or die "Can't open $fname";
    my ($ip, $ra, $rb, $rc, @program);
    while (<$fh>) {
        $ra = $1 if /Register A: (\d+)/;
        $rb = $1 if /Register B: (\d+)/;
        $rc = $1 if /Register C: (\d+)/;
        @program = split /,/, $1 if /Program: ([\d,]+)/;
    }
    return $ra, $rb, $rc, @program;
}

sub process
{
    my ($opcode, $operand, $ra, $rb, $rc) = @_;
    my $newip;

    $ra = adv(combo($operand, $ra, $rb, $rc), $ra) if $opcode == 0;
    $rb = bxl($operand, $rb) if $opcode == 1;
    $rb = bst(combo($operand, $ra, $rb, $rc)) if $opcode == 2;
    $newip = jnz($operand, $ra) if $opcode == 3;
    $rb = bxc($rb, $rc) if $opcode == 4;
    out(combo($operand, $ra, $rb, $rc)) if $opcode == 5;
    $rb = adv(combo($operand, $ra, $rb, $rc), $ra) if $opcode == 6;
    $rc = adv(combo($operand, $ra, $rb, $rc), $ra) if $opcode == 7;

    return $ra, $rb, $rc, $newip;
}

sub combo
{
    my ($operand, $ra, $rb, $rc) = @_;

    return $operand if $operand <= 3;
    return $ra if $operand == 4;
    return $rb if $operand == 5;
    return $rc if $operand == 6;
    die "Invalid combo operand";
}

sub adv
{
    my ($operand, $ra) = @_;
    return $ra >> $operand;
}

sub bxl
{
    my ($operand, $rb) = @_;
    return $rb ^ $operand;
}

sub bst
{
    my ($operand) = @_;
    return $operand % 8;
}

sub jnz
{
    my ($operand, $ra) = @_;
    return $ra ? $operand : undef;
}

sub bxc
{
    my ($rb, $rc) = @_;
    return $rb ^ $rc;
}

sub out
{
    my ($operand) = @_;
    our $notFirst;
    print "OUT: " if $debug > 0;
    print ',' if defined $notFirst;
    print $operand % 8;
    print "\n" if $debug > 0;
    $notFirst = 1;
}

