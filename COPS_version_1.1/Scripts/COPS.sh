#!bin/bash

if [ $# -ne 3 ]
then
	echo
	echo "Usage is:	bash COPS.sh <input file-type> <test file-name> <ref file-name>"
	echo 
	echo "		input file-type  :	0 for .bam file and 1 for .sam"
	echo "		test file-name	 :	file name of test/tumor sample (providing complete path)"
	echo "		ref file-name	 :	file name of reference/normal sample (providing complete path)"
	echo "		NOTE: PLEASE GIVE ARGUMENTS IN THE SAME ORDER"
	exit
fi

a=$1
tes=$2
ref=$3

mkdir ../COPS_output
#######################################################################################################################

if test $a -eq 1
then

# Chopping sam fields from sam

	testsam=$tes
	refsam=$ref
	if test -e $testsam && test -e $refsam
	then
		if test -e List_test.name && test -e List_ref.name
		then
			cat List_test.name | while read chr1
			do
				echo "Processing Test $chr1"
				samtools pileup -S $testsam $chr1 | awk "{if (\$1 == \"$chr1\") print \$1\"\t\"int(\$2/50)+1\"\t\"\$4}" > Test.$chr1
				echo "Processing Test $chr1 is done"
			done

			cat List_ref.name | while read chr2
			do
				echo "Processing Ref $chr2"
				samtools pileup -S $refsam $chr2 | awk "{if (\$1 == \"$chr2\") print \$1\"\t\"int(\$2/50)+1\"\t\"\$4}" > Ref.$chr2
				echo "Processing Ref $chr2 is done"
			done
		
		else
			echo "You are missing List_test.name or List_ref.name (files having chromosome names)"
			exit
		fi
	else
		echo "Incorrect filename"
		exit
	fi
	
elif test $a -eq 0
then


#######################################################################################################################
# Chopping sam fields from bam

	testbam=$tes
	refbam=$ref
	
	if test -e $testbam && test -e $refbam
	then	
	
		if test -e List_test.name && test -e List_ref.name
		then
		echo "Input files are $testbam $refbam"
			cat List_test.name | while read chr1
			do
				echo "Processing Test $chr1"
				samtools pileup $testbam $chr1 | awk "{if (\$1 == \"$chr1\") print \$1\"\t\"int(\$2/50)+1\"\t\"\$4}" > Test.$chr1
				echo "Processing Test $chr1 is done"
			done
			cat List_ref.name | while read chr2
			do
				echo "Processing Ref $chr2"
				samtools pileup $refbam $chr2 | awk "{if (\$1 == \"$chr2\") print \$1\"\t\"int(\$2/50)+1\"\t\"\$4}" > Ref.$chr2
				echo "Processing Ref $chr2 is done"
			done
			
		else
			echo "You are missing List_test.name or List_ref.name (files having chromosome names)"
			exit
		fi
	else
		echo "Incorrect filename"
		exit
	fi
else
	echo "Incorrect input file-type"
fi

#######################################################################################################################
# Summing up Read Depth

ls Test.* > log_test
ls Ref.* > log_ref

if test -e log_test
then
	cat log_test | while read input
	do
		nice -20 perl covgcF2.pl $input $input.binned.rd
		echo "Summed up the binned Test reads" 
	done
else
	echo "You are missing log_test OR covgcF2.pl(RD summing script)"
	exit
fi

if test -e log_ref
then
	cat log_ref | while read input
	do
		nice -20 perl covgcF2.pl $input $input.binned.rd
		echo "Summed up the binned Ref reads" 
	done
else
	echo "You are missing log_ref OR covgcF2.pl(RD summing script)"
	exit
fi

#######################################################################################################################
# Aligning files


if test -e List_test.name && test -e aligning.pl
then
	cat List_test.name | while read input
	do
		nice -20 perl aligning.pl Test.$input.binned.rd Ref.$input.binned.rd
		echo "Aligning the Test and Ref Bin IDs for Pairwise comparisons" 
	done
else
	echo "You are missing List_test.name or aligning.pl"
	exit
fi
 
#######################################################################################################################
# Calculating ratios, log

if test -e List_test.name 
then
	cat List_test.name | while read input
	do
	paste -d"\t" Test.$input.binned.rd.aligned Ref.$input.binned.rd.aligned | awk '{if ($3 != 0 && $6 != 0 && ($3/$6 > 1.414)) print $1"\t"$2"\t"$3/$6"\t"(log($3/$6)/log(2))"\tInsertion"; else if ($3 != 0 && $6 != 0 && ($6/$3 > 1.414)) print $1"\t"$2"\t"$3/$6"\t"(log($3/$6)/log(2))"\tDeletion"; else if ($3 != 0 && $6 != 0 && (($3/$6 <= 1.414) || ($6/$3 <= 1.414))) print $1"\t"$2"\t"$3/$6"\t"(log($3/$6)/log(2))"\tNeutral"; else if ($3 != 0 && $6 == 0) print $1"\t"$2"\tudef\tudef\tInsertion"; else if ($3 == 0 && $6 != 0) print $1"\t"$2"\t0\t-4\tDeletion"; else if ($3 == 0 && $6 == 0) print $1"\t"$2"\tudef\tudef\tNeutral";}' > Paired.$input.binned_rd	
	echo "Pairwise RD Ratios Calculated" 
	done
else
	echo "You are missing Test.$input.binned.rd.aligned or Ref.$input.binned.rd.aligned"
	exit
fi

#######################################################################################################################
# Removing Undef's

ls Paired.* > log_pair
if test -e log_pair
then
	cat log_pair | while read input
	do
		nice -20 perl RemoveUndef.pl $input $input.removedUdef
		echo "Removing undefined events is done" 
	done
else
	echo "You are missing log_pair OR RemoveUndef.pl (Script to remove undefined events)"
	exit
fi

#######################################################################################################################
# Averaging

ls *.removedUdef > log_Rm_undef

if test -e log_Rm_undef
then
	cat log_Rm_undef | while read input
	do
		nice -20 perl averaging.pl $input $input.avg
		echo "Averaging is done" 
	done
else
	echo "You are missing log_Rm_undef OR averaging.pl (Script to smooth ratios)"
	exit
fi

#######################################################################################################################
# Calculating P value

ls *.avg > log_Avg

if test -e log_Avg
then
	cat log_Avg | while read input
	do
		nice -20 perl pvalueMerge.pl $input $input.pval
		echo "P-value based merging and filtering of false positives is done" 
	done
else
	echo "You are missing log_Avg OR pvalueMerge.pl (Script to merge binned pairwise ratios and filter false positives based on P value cut off of 0.001)"
	exit
fi

#######################################################################################################################
# Concatenating

ls *.pval > log_P

if test -e log_P
then
	cat List_test.name | while read input
	do
		nice -20 perl Concat.pl Paired.$input.binned_rd.removedUdef.avg.pval $input.COPS
		echo "Concatenated Overlapping/Adjacent SCNAs" 
	done
else
	echo "You are missing log_P OR Concat.pl(Concat script)"
	exit
fi

#######################################################################################################################
mv *.COPS ../COPS_output
#rm *.chr* log_*
#######################################################################################################################
