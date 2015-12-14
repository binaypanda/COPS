#!/usr/bin/perl
use Data::Dumper;
open(IN,"$ARGV[0]");
while($line = <IN>)
{
	chomp($line);
	($chr1, $key1, $val) = split(/\t/,$line);
	$hash1{"$key1"} = $val;
}
close IN;
open(IN,"$ARGV[1]");
while($line = <IN>)
{
	chomp($line);
	($chr2, $key, $val) = split(/\t/,$line);
	$hash2{"$key"} = $val;
}
close IN;

@arr = sort { $a <=> $b }  keys %hash1;
($min1, $max1) = ($arr[0],$arr[-1]);

@arr = sort { $a <=> $b }  keys %hash2;
($min2, $max2) = ($arr[0],$arr[-1]);

$max = ($max1 > $max2)?$max1:$max2;
$min = ($min1 < $min2)?$min1:$min2;

open(OUT1,">$ARGV[0].aligned");
open(OUT2,">$ARGV[1].aligned");
foreach $key ($min..$max)
{
	if(!defined $hash1{$key})
	{   print OUT1 "$chr1\t$key\t0\n";  }
	else
	{   print OUT1 "$chr1\t$key\t$hash1{$key}\n";   }

	if(!defined $hash2{$key})
	{   print OUT2 "$chr2\t$key\t0\n";  }
	else
	{   print OUT2 "$chr2\t$key\t$hash2{$key}\n";}
}
close OUT1;
close OUT2;
