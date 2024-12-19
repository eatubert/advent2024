#!/usr/bin/perl -wnl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
no warnings 'recursion';

my $debug = 0;

our @map;
push @map, [split //];

END {
    my ($sizex, $sizey);
    $sizey = scalar @map;
    $sizex = scalar @{$map[0]};

    printMap(\@map) if $debug;

    my ($posx, $posy, $endx, $endy);
    my @vertices;
    my $directions = [
        [-1,0], [1,0], [0,1], [0,-1]
    ];
    for my $y (0..$sizey-1) {
        for my $x (0..$sizex-1) {
            $posx=$x, $posy=$y if $map[$y][$x] eq 'S';
            $endx=$x, $endy=$y if $map[$y][$x] eq 'E';
            next unless $map[$y][$x] eq '.';

            if ($x>0 && $y>0 && $x < $sizex-1 && $y < $sizey-1) {
                my $options = scalar grep {$map[$y+$_->[0]][$x+$_->[1]] eq '.'} @$directions;
                push @vertices, join ',', $x, $y if ($options >= 3);
            }
        }
    }

    die unless defined $posx && defined $endx;

    my $origin = join ',', $posx, $posy;
    push @vertices, $origin;
    my $destination = join ',', $endx, $endy; 
    push @vertices, $destination;

    my %vertices;
    @vertices{@vertices} = (undef) x @vertices;

    my %edges;
    for my $vertex (@vertices) {
        my ($x, $y) = split /,/, $vertex;
        findEdges($x, $y, $vertex, \%vertices, \%edges, '', {});
    }

    my $cost = dijkstra($origin, $destination, \@vertices, \%edges);
    print $cost;
}

sub dijkstra
{
# 1  function Dijkstra(Graph, source):
# 2     
# 3      for each vertex v in Graph.Vertices:
# 4          dist[v] ← INFINITY
# 5          prev[v] ← UNDEFINED
# 6          add v to Q
# 7      dist[source] ← 0
# 8     
# 9      while Q is not empty:
#10          u ← vertex in Q with minimum dist[u]
#11          remove u from Q
#12         
#13          for each neighbor v of u still in Q:
#14              alt ← dist[u] + Graph.Edges(u, v)
#15              if alt < dist[v]:
#16                  dist[v] ← alt
#17                  prev[v] ← u
#18
#19      return dist[], prev[]    

    my ($origin, $destination, $vertices, $edges) = @_;
    use constant INFINITE => 100_000_000;
    my %Q = map {$_, undef} @$vertices;
    my %prev = map {$_, undef} @$vertices;
    my %dist = map { $_, { path => '', cost => INFINITE } } @$vertices;
    $dist{$origin}{cost} = 0;

    while (%Q) {
        my $u = (sort {$dist{$a}{cost}<=>$dist{$b}{cost}} grep {exists $Q{$_}} keys %dist)[0];
        print "U=$u" if $debug > 0;
        delete $Q{$u};

        for my $edge (@{$edges->{$u}}) {
            my $v = $edge->{vertex2};
            print "V=$v" if $debug > 0;
            next unless exists $Q{$v};
            my $alt = $dist{$u}{path} . $edge->{path};
            my $altCost = cost($alt);
            if ($altCost < $dist{$v}{cost}) {
                $dist{$v}{path} = $alt;
                $dist{$v}{cost} = $altCost;
                $prev{$v} = $u;
            }
        }

        if ($debug > 0) {
            print 'Q=', join '; ', sort keys %Q;
            print 'PREV=', join '; ', map {join '=', $_, $prev{$_} // 'undef'} sort keys %prev;
            print 'DIST=', join '; ', map {join '=', $_, $dist{$_}{cost}} sort keys %dist;
            print "";
            <>;
        }
    }

    return $dist{$destination}{cost};
}


sub cost
{
    my $path = shift;

    my $moves = scalar (grep {/[v^><]/} split //, $path);
    my $last = '>';
    my $turns;
    for (split //, $path) {
        ++$turns unless $_ eq $last;
        $last = $_;
    }
    return $moves + $turns * 1000;
}


sub findEdges
{
    my ($x, $y, $vertex1, $vertices, $edges, $path, $visited) = @_;
    my $vertex2 = join ',', $x, $y;

    if ($path ne '' && exists $vertices->{$vertex2}) {
        push @{$edges->{$vertex1}}, {
            vertex2 => $vertex2,
            path  => $path,
        };
        return;
    }

    my %directions = (
        '>' => { x => 1, y => 0 },
        '<' => { x =>-1, y => 0 },
        'v' => { x => 0, y => 1 },
        '^' => { x => 0, y =>-1 },
    );

    markVisited($x, $y, $visited);
    for my $dir (keys %directions) {
        my $direction = $directions{$dir};
        my $newx = $x+$direction->{x};
        my $newy = $y+$direction->{y};

        findEdges($newx, $newy, $vertex1, $vertices, $edges, $path . $dir, $visited)
            if $map[$newy][$newx] ne '#' && !isVisited($newx, $newy, $visited);
    }
    clearVisited($x, $y, $visited);
}


sub printMap
{
    my ($map) = @_;
    print for map {join '', @$_} @$map;
}

sub visitedIndex { join ',', @_ }

sub isVisited
{
    my ($x, $y, $visited) = @_;
    exists $visited->{visitedIndex($x, $y)}
}

sub markVisited
{
    my ($x, $y, $visited) = @_;
    $visited->{visitedIndex($x, $y)} = undef;
}

sub clearVisited
{
    my ($x, $y, $visited) = @_;
    delete $visited->{visitedIndex($x, $y)};
}
