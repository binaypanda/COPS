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
				if ($ratio < 0.10) {
					print "1 Copy Deletion BP [$p - $b]: $ratio\n";
				}
				elsif ($ratio > 0.40 && $ratio < 0.60) {
					print "0.5 Copy Deletion BP [$p - $b]: $ratio\n";
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
			if ($ratio < 0.10) {
				print "1 Copy Deletion BP [$p - $b]: $ratio\n";
			}
			elsif ($ratio > 0.40 && $ratio < 0.60) {
				print "0.5 Copy Deletion BP [$p - $b]: $ratio\n";
			}
		}
	} 
}
