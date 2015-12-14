$in=$ARGV[0];
$bin_size=$ARGV[1];
open(IN,"$in");
$first=1;
while(<IN>) {
	chomp $_;
	@W=split(/[\s]+/,$_);
	$binID=$W[0];
	$arCount=$W[1];
	if ($first) {
		if ($prevARCount != 0) {
			$ratio=$arCount/$prevARCount;
			$p=$prevBinID;
			$b=$binID;
			if ($binID - $prevBinID == 1) {
				if ($ratio > 1.40 && $ratio < 1.60) {
					print "0.5 Copy Insertion BP [$p - $b]: $ratio\n";
				}
				elsif ($ratio > 1.90 && $ratio < 2.10) {
					print "1 Copy Insertion BP [$p - $b]: $ratio\n";
				}
				elsif ($ratio > 2.40 && $ratio < 2.60) {
					print "1.5 Copy Insertion BP [$p - $b]: $ratio\n";
				}
				elsif ($ratio > 2.90 && $ratio < 3.10) {
					print "2 Copy Insertion BP [$p - $b]: $ratio\n";
				}
				elsif ($ratio > 3.40 && $ratio < 3.60) {
					print "2.5 Copy Insertion BP [$p - $b]: $ratio\n";
				}
				elsif ($ratio > 3.90 && $ratio < 4.10) {
					print "3 Copy Insertion BP [$p - $b]: $ratio\n";
				}
				elsif ($ratio > 4.40 && $ratio < 4.60) {
					print "3.5 Copy Insertion BP [$p - $b]: $ratio\n";
				}
			}
		}

	}
	$prevBinID=$binID;
	$prevARCount=$arCount;
}
if ($first) { 		
	if ($prevARCount != 0) {
		$p=$prevBinID;
		$b=$binID;
		$ratio=$arCount/$prevARCount;
		if ($binID - $prevBinID == 1) {
			if ($ratio > 1.40 && $ratio < 1.60) {
				print "0.5 Copy Insertion BP [$p - $b]: $ratio\n";
			}
			elsif ($ratio > 1.90 && $ratio < 2.10) {
				print "1 Copy Insertion BP [$p - $b]: $ratio\n";
			}
			elsif ($ratio > 2.40 && $ratio < 2.60) {
				print "1.5 Copy Insertion BP [$p - $b]: $ratio\n";
			}
			elsif ($ratio > 2.90 && $ratio < 3.10) {
				print "2 Copy Insertion BP [$p - $b]: $ratio\n";
			}
			elsif ($ratio > 3.40 && $ratio < 3.60) {
				print "2.5 Copy Insertion BP [$p - $b]: $ratio\n";
			}
			elsif ($ratio > 3.90 && $ratio < 4.10) {
				print "3 Copy Insertion BP [$p - $b]: $ratio\n";
			}
			elsif ($ratio > 4.40 && $ratio < 4.60) {
				print "3.5 Copy Insertion BP [$p - $b]: $ratio\n";
			}
		}

	} 
}

