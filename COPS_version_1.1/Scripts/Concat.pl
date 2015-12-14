use Statistics::Distributions;

#!/bin/usr/perl
$in=$ARGV[0];
open (IN,"<$in") || die "$in cannot be opened";
$out=$ARGV[1];
open (OUT,">$out") || die "$out cannot be opened";
$bin_size=50;
$first=1;
while (<IN>) {
	chomp $_;
	@W = split (/[\s]+/,$_);
	$chr = $W[0];
	$start = $W[1];
	$end = $W[1]+$bin_size;
	$lrat = $W[2];
	$pval = $W[3];
	if ($first) {
		$cstart=$start;
		$l=$lrat;	
	}
	else {
		if ($start-$prevend <= 400 && (($prevl*$l)>0)) {
			#$prevend=$end;
			$l+=$lrat;
			$flag=1;
		}
		else {
			$tstat=sqrt(abs($l))/sqrt(0.5);
			$dof=$end-$cstart+1;
			$pval= Statistics::Distributions::tprob($dof,$tstat);
			if ($tstat > 22) {
				print OUT "$chr\t$cstart\t$prevend\t$l\t$tstat\t$pval\n";
			}
			$flag=0;
			$cstart=$start;
			$l=$lrat;
		}
	}
	$prevend=$end;
	$prevl=$lrat;
	$first=0;
}

if ($flag) {
	$tstat=sqrt(abs($l))/sqrt(0.5);
        $dof=$end-$cstart+1;
      	$pval= Statistics::Distributions::tprob($dof,$tstat);
       	if ($tstat > 22) {
              	print OUT "$chr\t$cstart\t$end\t$l\t$tstat\t$pval\n";
      	}
        $flag=0;
}
