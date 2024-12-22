#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper; $Data::Dumper::Sortkeys = 1;

our @codes;
push @codes, $_;

END {
    my @keypad1 = (
        [7,8,9],
        [4,5,6],
        [1,2,3],
        [undef, 0, 'A'],
    );
    #this order is important to avoid paths such as vv>v which have a higher cost
    my @directions1 = qw(^ > v <);
    my $routes1 = calcRoutes(\@keypad1, \@directions1);

    my @keypad2 = (
        [undef, '^', 'A'],
        ['<', 'v', '>'],
    );
    #this order is important to avoid paths such as vv>v which have a higher cost
    my @directions2 = qw(v > ^ <);
    my $routes2 = calcRoutes(\@keypad2, \@directions2);

    my $sum = 0;
    for my $code (@codes) {
        my @paths = typeCode($routes2, typeCode($routes2, typeCode($routes1, $code)));
        my $bestCode = (sort {length($a) <=> length($b)} @paths)[0];
        my $length = length($bestCode);
        my $complexity = $length * (join '', grep {/\d/} split //, $code);
        print join ',', $code, $length, $complexity;
        $sum += $complexity;
    }
    print $sum;
}

my %directions = (
    '^' => { x=>0, y=>-1},
    'v' => { x=>0, y=>1},
    '>' => { x=>1, y=>0},
    '<' => { x=>-1, y=>0},
);


sub typeCode
{
    my ($routes, @code) = @_;

    #print "typecode ", join ',', @code;
    my @ret;
    for my $code (@code) {
        my @paths = '';
        my $currentKey = 'A';
        for my $nextKey (split //, $code) {
            #print join ',', $currentKey, $nextKey, Dumper $routes->{$currentKey};
            my @newpaths;
            for my $path (@paths) {
                for my $nextOption (@{$routes->{$currentKey}{$nextKey}}) {
                    push @newpaths, $path . $nextOption . 'A';
                }
            }
            $currentKey = $nextKey;
            @paths = @newpaths;
        }
        push @ret, @paths;
    }
    return @ret;
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

sub calcRoutesKey
{
    my ($keypad, $key, $keyDirections) = @_;
    my ($keyX, $keyY) = findKey($keypad, $key);

    my $sizey = scalar @$keypad;
    my $sizex = scalar @{$keypad->[0]};

    my $keyPos = join ',', $keyX, $keyY;
    my %visited = ($keyPos => undef);
    my @candidates = ({pos=>$keyPos, path=>''});
    my %routes = ($key => '');

    while (@candidates) {
        my @newCandidates = ();
        for my $candidate (@candidates) {
            my $candidatePos = $candidate->{pos};
            my $candidatePath = $candidate->{path};
            my ($x, $y) = split /,/, $candidatePos;
            for my $direction (@$keyDirections) {
                my $newx = $x + $directions{$direction}{x};
                my $newy = $y + $directions{$direction}{y};

                next if $newx < 0 || $newx > $sizex-1;
                next if $newy < 0 || $newy > $sizey-1;
                next unless defined $keypad->[$newy][$newx];

                my $newpos = join ',', $newx, $newy;
                next if exists $visited{$newpos};

                $visited{$newpos} = undef;
                my $newpath = $candidatePath . $direction;
                $routes{$keypad->[$newy][$newx]} = $newpath;
                push @newCandidates, {
                    pos => $newpos,
                    path => $newpath,
                };
            }
        }

        @candidates = @newCandidates;
    }

    return \%routes;
}

sub validPath
{
    my ($keypad, $key, $path) = @_;
    my ($x, $y) = findKey($keypad, $key);

    for my $dir (split //, $path) {
        my $newx = $x + $directions{$dir}{x};
        my $newy = $y + $directions{$dir}{y};
        return 0 if not defined $keypad->[$y][$x];
        $x = $newx, $y = $newy;
    }
    return 1;
}

sub explodeRoutes
{
    my ($keypad, $routes) = @_;
    my %explodedRoutes;
    for my $firstKey (sort keys %$routes) {
        my $paths = $routes->{$firstKey};
        for my $secondKey (sort keys %$paths) {
            #print join ',', $firstKey, $secondKey;
            my $path = $paths->{$secondKey};
            my @paths = $path;
            if ($path ne '') {
                my $c = substr($path,0,1);
                $c = "\\$c" if $c eq '^';
                if ($path =~ /[^$c]/) {
                    my $swap = join '', reverse ($path =~ /^([$c]+)([^$c]+)$/);
                    die unless length($path) == length($swap);
                    push @paths, $swap if validPath($keypad, $firstKey, $swap);
                }
            }

            $explodedRoutes{$firstKey}{$secondKey} = [@paths];
        }
    }
    #print Dumper \%explodedRoutes;
    return \%explodedRoutes;
}

sub calcRoutes
{
    my ($keypad, $keyDirections) = @_;
    my %routes;
    my @keys = grep {defined $_} map {@$_} @$keypad;
    $routes{$_} = calcRoutesKey($keypad, $_, $keyDirections) for @keys;
    my $explodedRoutes = explodeRoutes($keypad, \%routes);
    #print Dumper $explodedRoutes;
    return $explodedRoutes;
}