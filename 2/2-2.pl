#!perl -wnl
use strict;
use warnings FATAL => 'all';

sub issafe {
	my @data = (@_);
	
	my $sign = $data[1]-$data[0];
	return unless $sign;
	$sign = $sign/abs($sign);
	while (my $d = shift @data) {
		return 1 unless defined $data[0];
		my $delta = ($data[0]-$d) / $sign;
		last unless 1 <= $delta && $delta <= 3;
	}
	
	return;
}

my @line = split /\s+/, $_;
my $len = scalar @line;
our $safe;
++$safe, next if issafe(@line);

for (0..$len-1) {
	my @temp = @line;
	splice @temp, $_, 1;
	++$safe, last if issafe(@temp);
}

END { print $safe }