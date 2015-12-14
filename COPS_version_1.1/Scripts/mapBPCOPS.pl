$in=$ARGV[0];
open (IN,"<$in");
$first=1;
while (<IN>) {
	@W=split(/[\s]+/,$_);
	if ($_ =~ /Deletion/ || $_ =~ /Insertion/) {
		$flag="BP";
		chomp $_;
		$start=$W[0];
		$cn=$W[1];
		$event=$W[2];
	}
	else {
		$flag="COPS";
		if ($W[1] < 0) {
			$coord = $W[0];
			$se=$W[2];
			if (!$first && $prevflag =~ /BP/ && $prevevent =~ /Deletion/) {
				if (! $sflag && $se =~ /S/) {
					$sflag=1;
					$BPnewS=$prevstart;
					$BPnewCN=$prevcn;
					$BPnewEvent=$prevevent;
				}
				elsif ($se =~ /E/ && $sflag) {
					$sflag=0;
					$BPnewE=$prevstart;
					print "$BPnewS\t$BPnewE\t$BPnewCN\t$BPnewEvent\n";
				}
			}
		}
		else {
			$coord=$W[0];
			$se=$W[2];
			if (!$first && $prevflag =~ /BP/ && $prevevent =~ /Insertion/) {
				if (! $sflag && $se =~ /S/) {
					$sflag=1;
					$BPnewS=$prevstart;
					$BPnewCN=$prevcn;
					$BPnewEvent=$prevevent;
				}
				elsif ($se =~ /E/ && $sflag) {
					$sflag=0;
					$BPnewE=$prevstart;
					print "$BPnewS\t$BPnewE\t$BPnewCN\t$BPnewEvent\n";
				}
			}
		}
	}

	$prevflag=$flag;
	$prevstart=$start;
	$prevcn=$cn;
	$prevevent=$event;
	$prevcoord=$coord;
	$prevse=$se;
	$first=0;
}

