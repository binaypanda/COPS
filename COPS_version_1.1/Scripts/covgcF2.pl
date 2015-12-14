open (O,"$ARGV[0]");
open (OUT1,">$ARGV[1]");
$first=1;
while (<O>) {
	chomp $_;
	@W=split(/[\s]+/,$_);
	$chr=$W[0];
	if (! $first) {
		if ($W[1] == $prevI) {
			$cov+=$W[2];
		}
		else {
			print OUT1 "$chr\t$prevI\t$cov\n";
			while (($W[1]-$prevI) > 1) {
			#	print "$W[1]\t$prevI\n";
				$prevI++;
				print OUT1 "$chr\t$prevI\t0\n";
			}
			$prevI=$W[1];
	                $cov=$W[2];
		}
	}
	else {
		$prevI=$W[1];
		$cov=$W[2];
	}
	$first=0;
}

print OUT1 "$chr\t$prevI\t$cov\n";

