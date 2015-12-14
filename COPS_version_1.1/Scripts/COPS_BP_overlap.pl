$in=$ARGV[0];
$out=$ARGV[1];
open(IN,"<$in");
open (OUT,">$out");
$first=1;
while (<IN>) {
	chomp $_;
	@W = split (/[\s]+/,$_);
	$nuc=$W[0];
	$event=$W[1];
	if (! $first) {
		if ($nuc =~ /$pnuc/ && $pnuc =~ /$nuc/) {
			if ($event !~ /D/ && $event !~ /I/) {
				print OUT "$nuc\t$event\n";
			}
		}
	}
	$pnuc=$nuc;
	$pevent=$event;	
	$first=0;
}

if (! $first) {
	if ($nuc =~ /$pnuc/ && $pnuc =~ /$nuc/) {
		if ($event !~ /D/ && $event !~ /I/) {
			print OUT "$nuc\t$event\n";
		}
	}
}
