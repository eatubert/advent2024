#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper; $Data::Dumper::Sortkeys = 1;

#21-2 [iterations] [filename]

our (@keypad1, @keypad2, $routes1, $routes2, $iterations);
our $total;
$total += main($_);

INIT {
    $iterations = shift;
    die "$0 [iterations] [filename]" unless $iterations && $iterations =~ /^\d+$/ && $iterations > 0;

    @keypad1 = (
        [ 7, 8, 9 ],
        [ 4, 5, 6 ],
        [ 1, 2, 3 ],
        [ undef, 0, 'A' ],
    );
    $routes1 = calcRoutes(\@keypad1);

    @keypad2 = (
        [ undef, '^', 'A' ],
        [ '<', 'v', '>' ],
    );
    $routes2 = calcRoutes(\@keypad2);
}

END { print $total }

sub main
{
    my ($code) = @_;
    my $first = nextKeyboard($routes1, 'A'.$code);
    my $length = calcLength($first, $iterations);
    my $num; ($num = $code) =~ s/A//;
    return $length * $num;
}

sub nextKeyboard
{
    my ($routes, $input)  = @_;
    my $outputKeys = '';
    my @inputKeys = split //, $input;
    $outputKeys .= $routes->{$inputKeys[$_]}{$inputKeys[$_+1]} for 0..scalar @inputKeys-2;
    #print join ' => ', $input, $outputKeys;
    return $outputKeys;
}

sub calcLength
{
    my ($input, $depth) = @_;
    our %cache;
    my $cacheKey = join ',', $input, $depth;
    #print $cacheKey, ' ', $cache{$cacheKey} // '';
    return $cache{$cacheKey} if exists $cache{$cacheKey};
    return length($input) if $depth == 0;
    my @inputKeys = split //, 'A'.$input;
    my $sum = 0;
    $sum += calcLength(nextKeyboard($routes2, join '', $inputKeys[$_], $inputKeys[$_+1]), $depth-1) for 0..scalar @inputKeys-2;
    $cache{$cacheKey}  = $sum;
    #print join '=', $cacheKey, $sum;
    return $sum;
}

sub findKey
{
    my ($keypad, $key) = @_;

    my $sizey = scalar @$keypad;
    my $sizex = scalar @{$keypad->[0]};

   my ($keyX, $keyY);

    for my $y (0..$sizey-1) {
        for my $x (0..$sizex-1) {
            return ($x, $y) if ($keypad->[$y][$x]//'') eq $key;
        }
    }

    die "Key $key not found";
}

sub walkKey
{
    my ($keypad, $x, $y, $targetX, $targetY, $paths, $path) = @_;
    if (($x == $targetX) && ($y == $targetY)) {
        my $last = '';
        my $count = 0;
        for (split //, $path) {
            ++$count if $_ ne $last;
            $last = $_;
        }

        push @$paths, $path.'A' if $count < 3;
    }

    #the order of the next lines is important, tried 4! = 24 combinations and <^v> or <v^> yield the best results
    walkKey($keypad, $x-1, $y, $targetX, $targetY, $paths, $path . '<') if $targetX < $x && defined $keypad->[$y][$x-1];
    walkKey($keypad, $x, $y-1, $targetX, $targetY, $paths, $path . '^') if $targetY < $y && defined $keypad->[$y-1][$x];
    walkKey($keypad, $x, $y+1, $targetX, $targetY, $paths, $path . 'v') if $targetY > $y && defined $keypad->[$y+1][$x];
    walkKey($keypad, $x+1, $y, $targetX, $targetY, $paths, $path . '>') if $targetX > $x && defined $keypad->[$y][$x+1];
}

sub calcRoute
{
    my ($keypad, $current, $target) = @_;
    return "A" if $current eq $target;
    my ($currentX, $currentY) = findKey($keypad, $current);
    my ($targetX, $targetY) = findKey($keypad, $target);
    my @paths;
    walkKey($keypad, $currentX, $currentY, $targetX, $targetY, \@paths, '');
    return $paths[0];
}

sub calcRoutes
{
    my ($keypad) = @_;
    my @keys = grep {defined $_} map {@$_} @$keypad;
    my %routes;
    for my $first (@keys) {
        $routes{$first}{$_} = calcRoute($keypad, $first, $_) for @keys;
    }
    return \%routes;
}