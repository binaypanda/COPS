open (O,"$ARGV[0]");
open (OUT1,">$ARGV[1]");
$binSize=$ARGV[2];
$bS = 0;$Build = $ARGV[3]; $bE = $bS+$binSize; $cov=0;
print "$Build\t$ARGV[0]\n";
if ($Build == 0 && $ARGV[0] =~ /test/i) {
	$len="List_test_chr_hg18.size";
}
elsif ($Build == 0 && $ARGV[0] =~ /ref/i) {
	$len="List_ref_chr_hg18.size";
}
elsif ($Build == 1 && $ARGV[0] =~ /test/i) {
	$len="List_test_chr_hg19.size";
}
else {
	$len="List_ref_chr_hg19.size";
}

open (L,$len);
while (<L>) {
	chomp $_;
	@W=split(/[\s]+/,$_);
	if ($ARGV[0] =~ /$W[0]/) {
		$bFE=$W[1];
	}
}
close (L);
print "$bFE\n";
while (<O>) {
	chomp $_;
	@W = split(/[\s]+/,$_);
	if ($W[0] >= $bS && $W[0] < $bE && $bE <= $bFE) {
		$cov++;
	}
	else {
		print OUT1 "$bS\t$cov\n";
		while ($W[0] >= $bE && $bE <= $bFE) {
			$bS++;
			$bE = $bS+$binSize;
			$cov=0;
		}
		if ($W[0] >= $bS && $W[0] < $bE) {
                	$cov++;
        	}
	}
}
print OUT1 "$bS\t$cov\n";
