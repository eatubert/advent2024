#!/usr/bin/perl -wl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
no warnings 'recursion';

my $debug = 0;
my ($size, $readBytes, $fname) = @ARGV;
die "$0 [size] [read] [fname]" unless defined $fname;
main($size, $readBytes, $fname);


sub readmap
{
    my ($size, $readBytes, $fname) = @_;

    my (@map, @extra);
    push @map, [('.') x $size] for 0..$size-1;

    open my $fh, '<', $fname or die "Can't open $fname";
    my $count;
    while (<$fh>) {
        chomp;
        my ($x,$y) = split /,/, $_;
        if (++$count <= $readBytes) {
            $map[$y][$x] = '#';
        } else {
            push @extra, $_;
        }
    }
    return \@map, \@extra;
}

sub printmap
{
    my ($map) = @_;
    print join '', @$_ for @$map;
    print "";
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

sub findVertices
{
    my ($map) = @_;
    my @vertices;
    my $sizey = scalar @$map;
    my $sizex = scalar @{$map->[0]};
    my $directions = [
        [-1,0], [1,0], [0,1], [0,-1]
    ];

    for my $y (0..$sizey-1) {
        for my $x (0..$sizex-1) {
            next unless $map->[$y][$x] eq '.';
            my $options = 0;
            for my $direction (@$directions) {
                my $newx = $x + $direction->[0];
                my $newy = $y + $direction->[1];
                next if $newx < 0 || $newx >= $sizex;
                next if $newy < 0 || $newy >= $sizey;
                next if $map->[$newy][$newx] ne '.';
                ++$options;
            }
            push @vertices, join ',', $x, $y if ($options >= 3);
        }
    }

    push @vertices, join ',', 0, 0;
    push @vertices, join ',', $sizex-1, $sizey-1;
    return \@vertices;
}

sub subFindEdges
{
    my ($x, $y, $vertex1, $map, $vertices, $edges, $path, $visited) = @_;
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
    my $sizey = scalar @$map;
    my $sizex = scalar @{$map->[0]};

    markVisited($x, $y, $visited);
    for my $dir (keys %directions) {
        my $direction = $directions{$dir};
        my $newx = $x+$direction->{x};
        my $newy = $y+$direction->{y};

        next if $newx < 0 || $newx >= $sizex;
        next if $newy < 0 || $newy >= $sizey;
        next if $map->[$newy][$newx] eq '#';
        next if isVisited($newx, $newy, $visited);

        subFindEdges($newx, $newy, $vertex1, $map, $vertices, $edges, $path . $dir, $visited);
    }
    clearVisited($x, $y, $visited);
}


sub findEdges
{
    my ($map, $vertices) = @_;
    my %edges;

    my %vertices;
    @vertices{@$vertices} = (undef) x @$vertices;

    for my $vertex (@$vertices) {
        my ($x, $y) = split /,/, $vertex;
        subFindEdges($x, $y, $vertex, $map, \%vertices, \%edges, '', {});
    }
    return \%edges;
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
        last if $dist{$u}{cost} == INFINITE;

        print "U=$u" if $debug > 0;
        delete $Q{$u};

        for my $edge (@{$edges->{$u}}) {
            my $v = $edge->{vertex2};
            print "V=$v" if $debug > 0;
            next unless exists $Q{$v};
            my $alt = $dist{$u}{path} . $edge->{path};
            my $altCost = length($alt);
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

    return $dist{$destination}{path};
}


sub findVisited
{
    my $path = shift;
    print $path if $debug > 0;
    my @visited;
    my $x = 0;
    my $y = 0;

    my %directions = (
        '>' => { x => 1, y => 0 },
        '<' => { x =>-1, y => 0 },
        'v' => { x => 0, y => 1 },
        '^' => { x => 0, y =>-1 },
    );

    push @visited, join ',', $x, $y;
    for my $direction (split //, $path) {
        my $delta = $directions{$direction};
        $x += $delta->{x};
        $y += $delta->{y};
        push @visited, join ',', $x, $y;
    }

    return \@visited;
}


sub printPath
{
    my ($map, $visited, $drop) = @_;

    my @mapCopy;
    push @mapCopy, [@$_] for @$map;

    print join '; ', sort @$visited if $debug > 0;
    for (@$visited) {
        my ($x, $y) = split /,/, $_;
        $mapCopy[$y][$x] = 'O';
    }

    if ($drop) {
        my ($x, $y) = split /,/, $drop;
        $mapCopy[$y][$x] = '*';
    }

    printmap(\@mapCopy);
}


sub main
{
    my ($size, $readBytes, $fname) = @_;
    my ($map, $extra) = readmap($size, $readBytes, $fname);
    printmap($map) if $debug > 0;
    my $origin = join ',', 0, 0;
    my $destination = join ',', $size-1, $size-1;

####

    my $lastOnPath;
    while (@$extra) {
        my $vertices = findVertices($map);
        print join '; ', sort @$vertices if $debug > 0;
        my $edges = findEdges($map, $vertices);
        print Dumper $edges if $debug > 0;

        my $path = dijkstra($origin, $destination, $vertices, $edges);
        print $path if $debug > 0;
        last unless $path;

        my $visited = findVisited($path);
        printPath($map, $visited) if $debug > 0;

        my %visited;
        @visited{@$visited} = (undef) x scalar @$visited;
        for my $drop (@$extra) {
            print $drop if $debug > 1;
            my ($x, $y) = split /,/, $drop;
            $map->[$y][$x] = '#';
            if (exists $visited{$drop}) {
                $lastOnPath = $drop;
                print "On path" if $debug > 1;
                printPath($map, $visited, $drop) if $debug > 1;
                last;
            }
        }
    }

    print $lastOnPath;
}


