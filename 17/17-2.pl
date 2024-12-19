#!/usr/bin/perl -w
use strict;
use warnings FATAL => 'all';
use feature 'say';


my $fname = shift or die "$0 [fname]";
my $debug = shift // 0;
#main($fname);
my $overrideRA = shift;
if (defined $overrideRA) {
    run($fname, $overrideRA);
} else {
    main($fname);
}

sub main
{
    my ($fname) = @_;
    my ($originalRA, $originalRB, $originalRC, @program) = readinput($fname);

    my @search = @program;
    my @oldOptions = (0);

    for my $index (0..$#search) {
        my $rb = $search[$index];
        my %newOptions;
        for my $option (@oldOptions) {
            say "Searching for $rb, option $option" if $debug > 0;

            for my $raLow3 (0 .. 7) {
                my $shift = $raLow3 ^ 0b010;
                my $rc = $rb ^ 0b101 ^ $raLow3;
                my $shiftedrc = $rc << $shift;
                my $ra = (($raLow3 | $shiftedrc) << ($index * 3)) | $option;

                printf "ra=%i(%b)\n", $ra, $ra if $debug > 0;

                my @output = execute($ra, $originalRB, $originalRC, @program);
                say join ',', @output if $debug > 1;
                if (compare(\@search, \@output, $index+1)) {
                    $newOptions{$ra} = undef;
                    say "OK" if $debug > 0;
                }
            }
        }
        @oldOptions = keys %newOptions;
        if ($debug > 0) {
            say "\nOptions: ", join ',', map {sprintf '%i(%b)', $_, $_} @oldOptions;
            <>;
        }
    }

    say( (sort {$a <=> $b} @oldOptions)[0] );

}


sub run {
    my ($fname, $overrideRA) = @_;
    my ($ra, $rb, $rc, @program) = readinput($fname);
    $ra = $overrideRA;

    my @output = execute($ra, $rb, $rc, @program);
    print join ',', @output;
}

sub execute
{
    my ($ra, $rb, $rc, @program) = @_;
    my @output;
    my $counter = 0;
    @output = ();

    my $ip = 0;
    while ($ip < scalar @program) {
        my $opcode = $program[$ip];
        my $operand = $program[$ip+1];
        say "IP=$ip, Opcode: $opcode, operand: $operand, ra=$ra (${\(sprintf '%03b', $ra % 8)}), rb=$rb (${\(sprintf '%03b', $rb % 8)}), rc=$rc (${\(sprintf '%03b', $rc % 8)})" if $debug > 0;

        my $newip;
        ($ra, $rb, $rc, $newip) = process($opcode, $operand, $ra, $rb, $rc, \@output);
        $ip = defined $newip ? $newip : $ip+2;
    }

    return @output;
}

sub compare
{
    my ($program, $output, $length) = @_;
    say "Compare ", (join ',', @$program), " <=> ", (join ',', @$output), " length = $length" if $debug > 1;
    return !grep {
        scalar @$program > $_ &&
        scalar @$output > $_ &&
        $program->[$_] != $output->[$_]
    } 0..$length-1;
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
    my ($opcode, $operand, $ra, $rb, $rc, $output) = @_;
    my $newip;

    $ra = adv(combo($operand, $ra, $rb, $rc), $ra) if $opcode == 0;
    $rb = bxl($operand, $rb) if $opcode == 1;
    $rb = bst(combo($operand, $ra, $rb, $rc)) if $opcode == 2;
    $newip = jnz($operand, $ra) if $opcode == 3;
    $rb = bxc($rb, $rc) if $opcode == 4;
    out(combo($operand, $ra, $rb, $rc), $output) if $opcode == 5;
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
    my ($operand, $output) = @_;
    say  "OUT: ", $operand % 8 if $debug > 0;
    push @$output, $operand % 8;
}

