#!/usr/bin/perl
$in=$ARGV[0];
open (IN,"<$in") || die "$in cannot be opened";
$out=$ARGV[1];
open (OUT,">$out") || die "$out cannot be opened";
$bin_size=50;
$first=1;
while (<IN>) {
	chomp $_;
	if ($_ !~ /bin/i && $_ !~ /start/i) {
		@W=split(/[\s]+/,$_);
		$cnvELR{$W[1]}=$W[4]."_".$W[3]."_".$W[0];
		push(@bins,$W[1]);
	}
}
$k=0;
while ($k < $#bins+1) {
	if ($k > 0) {
		($event1,$logr1,$chr) = split (/[_]+/,$cnvELR{$bins[$k-1]});
		($event2,$logr2,$chr) = split (/[_]+/,$cnvELR{$bins[$k]});
		($event3,$logr3,$chr) = split (/[_]+/,$cnvELR{$bins[$k+1]});		
		#print "$chr\n";exit(0);
		if ($logr2 =~ /udef/  && $event2 !~ /Insertion/) {
			if ($event2 =~ /$event1/ && $event2 !~ /$event3/) {
				$logr2 = $logr1;
			}
			elsif ($event2 !~ /$event1/ && $event2 =~ /$event3/) {
				$logr2 = $logr3;
			}
			elsif ($event2 =~ /$event1/ && $event2 =~ /$event3/) {
				if (abs($logr1) > abs($logr3)) {
					$logr2=$logr1;			
				}
				elsif (abs($logr3) >= abs($logr1)) {
					$logr2=$logr3;			
				}
			}
			elsif ($event2 !~ /$event1/ && $event2 !~ /$event3/) {

				if ($event2 =~ /deletion/i) {
					if ($logr1 < 0 && $logr3 < 0) {
						if (abs($logr1) > abs($logr3)) {					
							$logr2=$logr1;	
						}
						elsif (abs($logr3) >= abs($logr1)) {
							$logr2=$logr3;						
						}
					}
					elsif ($logr1 < 0 && $logr3 >= 0) {
						$logr2=$logr1;					
					}
					elsif ($logr3 < 0 && $logr1 >= 0) {
						$logr2=$logr3;					
					}
					elsif ($logr1 >=0 && $logr3 >=0) {
						$logr2="-1";
					}
				}
				elsif ($event2 =~ /insertion/i) {
					if ($logr1 > 0 && $logr3 > 0) {
						if (abs($logr1) > abs($logr3)) {					
							$logr2=$logr1;	
						}
						elsif (abs($logr3) >= abs($logr1)) {
							$logr2=$logr3;						
						}
					}
					elsif ($logr1 <= 0 && $logr3 > 0) {
						$logr2=$logr3;					
					}
					elsif ($logr3 <= 0 && $logr1 > 0) {
						$logr2=$logr1;					
					}
					elsif ($logr1 <=0 && $logr3 <=0) {
						$logr2="1";
					}
				}
				elsif ($event2 =~ /neutral/i) {
					if ($logr1 < 0 && $logr3 <0) {
						if (abs($logr1)>abs($logr3)) {
							$logr2=$logr1;
						}
						elsif (abs($logr3) >= abs($logr1)){
							$logr2=$logr3;
						}
						$event2="Deletion";					
					}
					elsif ($logr1 >0  && $logr3 > 0) {
						 if (abs($logr1)>abs($logr3)) {
							$logr2=$logr1;
						}
						elsif (abs($logr3)>=abs($logr1)){
							$logr2=$logr3;
						}
						$event2="Insertion";					
					}
					else {
						$logr2=0;					
					}
				}
			}
			elsif  ($event2 =~ /Insertion/ && $logr2 =~ /udef/ ){
				$logr2=0;
				$event2="Neutral";			
			}		
			if ($logr1 =~ /udef/i ) {
				$l=$k-1;
				while ($cnvELR{$bins[$l]} =~ /udef/) {
					($event1,$logr1,$chr) = split (/[_]+/,$cnvELR{$bins[$l]});
					if ($event1 =~ /$event2/) {
						if ($logr2 !~ /udef/) {
							$logr1=$logr2;
						}
						else {
							if ($event1 =~ /deletion/i) {
								$logr1=-1;
							}
							elsif ($event1 =~ /insertion/i) {
								$logr1=1;
							}
							elsif ($event1 =~ /neutral/i) {
								$logr1=0;							
							}				
						}
					}
					else {
						if ($event1 =~ /deletion/i) {
							$logr1=-1;
						}				
						elsif ($event1 =~ /insertion/i) {
							$logr1=1;
						}
						elsif ($event1 =~ /neutral/i) {
							$logr1=0;
						}
					}
					$cnvELR{$bins[$l]} = $event1."_".$logr1."_".$chr;
					$l--;				
				}
				if ($logr2 =~ /udef/ && $event2 !~ /$event3/) {
					if ($event2 =~ /deletion/i) {
						$logr2=-1;
					}
					elsif ($event2 =~ /insertion/i) {
						$logr2=1;
					}
					elsif ($event2 =~ /neutral/i) {
						$logr2=0;							
					}
				}
			}
			$cnvELR{$bins[$k]} = $event2."_".$logr2."_".$chr;	
		}
	}
	else {
		($event2,$logr2,$chr) = split (/[_]+/,$cnvELR{$bins[$k]});
		($event3,$logr3,$chr) = split (/[_]+/,$cnvELR{$bins[$k+1]});			
		if ($logr2 =~ /udef/)  {
			if ($event2 =~ /$event3/) {
				$logr2 = $logr3;
				$cnvELR{$bins[$k]} = $event2."_".$logr2."_".$chr;
			}
			elsif ($event2 !~ /$event3/) {
				if ($event2 =~ /deletion/i) {
					if ($logr3 <0 ) {
						$logr2=$logr3;				
					}				
					else {
						$logr2="-1";				
					}
				}
				elsif ($event2 =~ /insertion/i) {
					if ($logr3 > 0) {
						$logr2=$logr3;
					}
					else {
						$logr2="1";
					}
				}
				elsif ($event2 =~ /neutral/i) {
					$logr2="0";
				}
				$cnvELR{$bins[$k]} = $event2."_".$logr2."_".$chr;
			}		
		}
	}
	$k++;
}
$k=0;
while ($k < $#bins+1) {
	$l1=$bin_size*$bins[$k];
	$l2=($bin_size*$bins[$k])-1+$bin_size;
	($e,$lr,$ch)=split(/[_]+/,$cnvELR{$bins[$k]});
#	print "lr ===> $lr\n"; 
	if ($lr <= -4.5 && $lr > -6.5) {
		$c = -3;	
	}
	elsif ($lr <= -2.5 && $lr > -4.5) {
		$c = -2;	
	}
	if ($lr <= -0.5 && $lr > -2.5) {
		$c = -1;	
	}
	if ($lr <= 0.5 && $lr > -0.5) {
		$c = 0;	
	}
	elsif ($lr <= 2.5 && $lr > 0.5) {
		$c = 1;	
	}
	elsif ($lr <= 4.5 && $lr > 2.5) {
		$c = 2;	
	}
	elsif ($lr <= 6.5 && $lr > 4.5) {
		$c = 3;	
	}
	print OUT "$ch\t$l1\t$l2\t$c\t$e\t$lr\n";
	$k++;
}



