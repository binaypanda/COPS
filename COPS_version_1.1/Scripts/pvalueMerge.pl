use Statistics::Distributions;

$in=$ARGV[0];
open (IN,"<$in") || die "$in cannot be opened";
$out=$ARGV[1];
open (OUT,">$out") || die "$out cannot be opened";
$bin_size=50;
$first=1;
while (<IN>) {
	chomp $_;
	@W=split(/[\s]+/,$_);
	$chr=$W[0];
	$start=$W[1];
	$lrat=$W[2];
	push (@chrs,$chr);
	push (@starts,$start);
	push (@lrats,$lrat);
}

$k=0;
while ($k < $#lrats-9) {
	$l=($lrats[$k]+$lrats[$k+1]+$lrats[$k+2]+$lrats[$k+3]+$lrats[$k+4]+$lrats[$k+5]+$lrats[$k+6]+$lrats[$k+7]+$lrats[$k+8]+$lrats[$k+9]);
	$tstat=sqrt(abs($l))/sqrt(0.5);
	$dof=10*$bin_size;
        $pval= Statistics::Distributions::tprob($dof,$tstat);	
	if ($pval < 0.001) {
#	if ($l > 22) {
		print OUT "$chrs[$k]\t$starts[$k]\t$l\t$pval\n";
	}
	$k++;
}

