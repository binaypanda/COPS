#!/usr/bin/perl
$in=$ARGV[0];
open (IN,"<$in");
$out=$ARGV[1];
open(OUT,">$out");
$bin_size=50;
$step_size=4;
while (<IN>) {
	if ($_ !~ /bin/i && $_ !~ /start/i) {
		chomp $_;
		@W=split(/[\s]+/,$_);
		$l{$W[1]}=$W[5];
		$c{$W[1]}=$W[0];
		push (@s,$W[1]);
	}
}

$k=$step_size;
while ($k < $#s-$step_size) {
	$m=$s[$k]-($step_size*$bin_size);$tl=0;
	while ($m < ($s[$k]+($step_size*$bin_size))) {
		$tl+=$l{$m};
		$m+=$bin_size;	
	}
	$tl /= (2*$step_size+1);
	print OUT "$c{$s[$k]}\t$s[$k]\t$tl\n";
	$k++;
}
