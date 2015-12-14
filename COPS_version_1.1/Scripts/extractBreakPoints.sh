#!bin/bash

if [$# -ne 6]
then
	echo
	echo "Usage is:	bash extractBreakPoints.sh <input file-type> <test file-name> <ref file-name> <insert size mean> <insert size stdev> <genome build>"
	echo 
	echo "		input file-type  :	0 for .bam file and 1 for .sam"
	echo "		test file-name	 :	File name of test/tumor sample (providing complete path)"
	echo "		ref file-name	 :	File name of reference/normal sample (providing complete path)"
	echo "		insert size mean :	library insert size in nucleotides"
	echo "		insert size stdev:	standard deviation of library insert size in nucleotides"
	echo "          genome build     :      0 for hg18 and 1 for hg19"
	echo "		NOTE: PLEASE GIVE ARGUMENTS IN THE SAME ORDER"
	exit
fi
a=$1
tes=$2
ref=$3
ism=$4
issd=$5
gb=$6

if test $a -eq 1
then


#######################################################################################################################
# Chop sam fields from sam

	testsam=$tes
	refsam=$ref
	mis=$ism
	sdis=$issd
	if test -e $testsam && test -e $refsam
	then
		if test -e List_test.name && test -e List_ref.name
		then
			cat List_test.name | while read chr1
			do
				echo "Processing $chr1 in Test Sample"
				samtools view -S $testsam $chr1 | awk "{if (\$3 == \"$chr1\" && \$7 == \"=\" && ((\$9 < ($mis-$sdis) && \$9 > 0) || (\$9 > (-$mis-$sdis) && \$9 < 0))) print \$4\"\\t\"\$8\"\\t\"\$9}" > Test.$chr1.Ins
				samtools view -S $testsam $chr1 | awk "{if (\$3 == \"$chr1\" && \$7 == \"=\" && ((\$9 > ($mis+$sdis) )|| (\$9 < (-$mis-$sdis)))) print \$4\"\\t\"\$8\"\\t\"\$9}" > Test.$chr1.Del
				echo "Processing $chr1 in Test Sample Done"
			done

			cat List_ref.name | while read chr2
			do
				echo "Processing $chr2 in Ref Sample"
				samtools view -S $refsam $chr2 | awk "{if (\$3 == \"$chr2\" && \$7 == \"=\" && ((\$9 < ($mis-$sdis) && \$9 > 0) || (\$9 > (-$mis-$sdis) && \$9 < 0))) print \$4\"\\t\"\$8\"\\t\"\$9}" > Ref.$chr2.Ins
				samtools view -S $refsam $chr2 | awk "{if (\$3 == \"$chr2\" && \$7 == \"=\" && ((\$9 > ($mis+$sdis)) || (\$9 < (-$mis-$sdis)))) print \$4\"\\t\"\$8\"\\t\"\$9}" > Ref.$chr2.Del
				echo "Processing $chr2 in Ref Sample Done"
			done
		
		else
			echo "You don't have List_test.name/List_ref.name(file having chromosome names)"
			exit
		fi
	else
		echo "Incorrect filename"
		exit
	fi
	
else 
	if test $a -eq 0
	then
#######################################################################################################################
# Chop sam fields from bam

		testbam=$tes
		refbam=$ref
		mis=$ism
		sdis=$issd
		if test -e $testbam && test -e $refbam
		then	
			if test -e List_test.name && test -e List_ref.name
			then
				echo "Input files are $testbam $refbam"
				cat List_test.name | while read chr1
				do
					echo "Processing $chr1 in Test Sample"
					samtools view $testbam $chr1 | awk "{if (\$3 == \"$chr1\" && \$7 == \"=\" && ((\$9 < ($mis-$sdis) && \$9 > 0) || (\$9 > (-$mis-$sdis) && \$9 < 0))) print \$4\"\\t\"\$8\"\\t\"\$9}" > Test.$chr1.Ins
					samtools view $testbam $chr1 | awk "{if (\$3 == \"$chr1\" && \$7 == \"=\" && (\$9 > ($mis+$sdis) || \$9 < (-$mis-$sdis))) print \$4\"\\t\"\$8\"\\t\"\$9}" > Test.$chr1.Del
					echo "Processing $chr1 in Test Sample Done"
				done
				cat List_ref.name | while read chr2
				do
					echo "Processing $chr2 in Ref Sample"
					samtools view $refbam $chr2 | awk "{if (\$3 == \"$chr2\" && \$7 == \"=\" && ((\$9 < ($mis-$sdis) && \$9 > 0) || (\$9 > (-$mis-$sdis) && \$9 < 0))) print \$4\"\\t\"\$8\"\\t\"\$9}" > Ref.$chr2.Ins
					samtools view $refbam $chr2 | awk "{if (\$3 == \"$chr2\" && \$7 == \"=\" && (\$9 > ($mis+$sdis) || \$9 < (-$mis-$sdis))) print \$4\"\\t\"\$8\"\\t\"\$9}" > Ref.$chr2.Del
					echo "Processing $chr2 in Ref Sample Done"
				done
			
			else
				echo "X: You don't have List_test.name/List_ref.name (files containing chromosome names)"
				exit
			fi
		else
			echo "Incorrect filename"
			exit
		fi
	else
		echo "Incorrect input file-type"
	fi
fi

#######################################################################################################################
# Bin anomalous reads

genb=$gb

ls Test.*.Ins > log_test_ins
ls Ref.*.Ins > log_ref_ins
ls Test.*.Del > log_test_del
ls Ref.*.Del > log_ref_del

if test $genb -eq 0
then
	paste -d"\t" List_test.name List_chr_hg18.size > List_test_chr_hg18.size
	if test -e List_test.name && test -e List_chr_hg18.size && test -e log_test_ins
	then
        	cat log_test_ins | while read input
        	do
        	  	nice -20 perl covAR2.pl $input $input.binned.cov 5000 $genb
       		        echo "Binned anomalous reads in Insertion category for Test sample"
        	done
	else
    		echo "You don't have log_test_ins OR List_chr_hg18.size OR covAR2.pl"
        	exit
	fi	
	if test -e List_test.name && test -e List_chr_hg18.size && test -e log_test_del
	then
	        cat log_test_del | while read input
	        do
	       	  	nice -20 perl covAR2.pl $input $input.binned.cov 5000 $genb
	                echo "Binned anomalous reads in Deletion category for Test sample"
	        done
	else
	    	echo "You don't have log_test_del OR List_chr_hg18.size OR covAR2.pl"
	        exit
	fi
	paste -d"\t" List_ref.name List_chr_hg18.size > List_ref_chr_hg18.size
	if test -e List_ref.name && test -e List_chr_hg18.size && test -e log_ref_ins
	then
	        cat log_ref_ins | while read input
	        do
	          	nice -20 perl covAR2.pl $input $input.binned.cov 5000 $genb
	                echo "Binned anomalous reads in Insertion category for Ref sample"
	        done
	else
	    	echo "You don't have log_ref_ins OR List_chr_hg18.size OR covAR2.pl"
	        exit
	fi
	if test -e List_ref.name && test -e List_chr_hg18.size && test -e log_ref_del
	then
	        cat log_ref_del | while read input
        	do
        	  	nice -20 perl covAR2.pl $input $input.binned.cov 5000 $genb
       		        echo "Binned anomalous reads in Deletion category for Ref sample"
        	done
	else
    		echo "You don't have log_ref_del OR List_chr_hg18.size OR covAR2.pl"
        	exit
	fi
elif test $genb -eq 1
then
	paste -d"\t" List_test.name List_chr_hg19.size > List_test_chr_hg19.size
	if test -e List_test.name && test -e List_chr_hg19.size && test -e log_test_ins
	then
        	cat log_test_ins | while read input
        	do
        	  	nice -20 perl covAR2.pl $input $input.binned.cov 5000 $genb
        	        echo "Binned anomalous reads in Insertion category for Test sample"
        	done
	else
    		echo "You don't have log_test_ins OR List_chr_hg19.size OR covAR2.pl"
        	exit
	fi
	if test -e List_test.name && test -e List_chr_hg19.size && test -e log_test_del
	then
	        cat log_test_del | while read input
	        do
			nice -20 perl covAR2.pl $input $input.binned.cov 5000 $genb
	                echo "Binned anomalous reads in Deletion category for Test sample"
	        done
	else
	    	echo "You don't have log_test_del OR List_chr_hg19.size OR covAR2.pl"
	        exit
	fi

	paste -d"\t" List_ref.name List_chr_hg19.size > List_ref_chr_hg19.size
	if test -e List_ref.name && test -e List_chr_hg19.size && test -e log_ref_ins
	then
	        cat log_ref_ins | while read input
	        do
          		nice -20 perl covAR2.pl $input $input.binned.cov 5000 $genb
	                echo "Binned anomalous reads in Insertion category for Ref sample"
	        done
	else
	    	echo "You don't have log_ref_ins OR List_chr_hg19.size OR covAR2.pl"
	        exit
	fi
	if test -e List_ref.name && test -e List_chr_hg19.size && test -e log_ref_del
	then
	        cat log_ref_del | while read input
        	do
			nice -20 perl covAR2.pl $input $input.binned.cov 5000 $genb
	       	        echo "Binned anomalous reads in Deletion category for Ref sample"
        	done
	else
    		echo "You don't have log_ref_del OR List_chr_hg19.size OR covAR2.pl"
        	exit
	fi
else
	echo "You are missing the Genome Build information"
fi

#######################################################################################################################
# Extract breakpoints

ls Test.*.Ins.binned.cov > log_test_ins
ls Ref.*.Ins.binned.cov > log_ref_ins
ls Test.*.Del.binned.cov > log_test_del
ls Ref.*.Del.binned.cov > log_ref_del

if test -e log_test_ins
then
	cat log_test_ins | while read input
	do
		nice -20 perl ratioI.pl $input 5000 > $input.BPS
		echo "Extracted Breakpoints in Insertion category for Test sample" 
	done
else
	echo "You don't have log_test_ins OR ratioI.pl"
	exit
fi

if test -e log_test_del
then
	cat log_test_del | while read input
	do
		nice -20 perl ratioD.pl $input 5000 > $input.BPS
		echo "Extracted Breakpoints in Deletion category for Test sample" 
	done
else
	echo "You don't have log_test_del OR ratioD.pl"
	exit
fi

if test -e log_ref_ins
then
	cat log_ref_ins | while read input
	do
		nice -20 perl ratioI.pl $input 5000 > $input.BPS
		echo "Extracted Breakpoints in Insertion category for Ref sample" 
	done
else
	echo "You don't have log_ref_ins OR ratioI.pl"
	exit
fi

if test -e log_ref_del
then
	cat log_ref_del | while read input
	do
		nice -20 perl ratioD.pl $input 5000 > $input.BPS
		echo "Extracted Breakpoints in Deletion category for Ref sample" 
	done
else
	echo "You don't have log_ref_del OR ratioD.pl"
	exit
fi

#######################################################################################################################
# Extract SCNA Breakpoints

ls List_test.name > log_test
if test -e log_test
then
    	cat List_test.name | while read inputT
        do
          	comm -2 -3 Test.$inputT.Ins.binned.cov.BPS Ref.$inputT.Ins.binned.cov.BPS > Test.Specific.$inputT.Ins.BPS
                echo "Extracted Test Specific Breakpoints in Insertion category"
                comm -2 -3 Test.$inputT.Del.binned.cov.BPS Ref.$inputT.Del.binned.cov.BPS > Test.Specific.$inputT.Del.BPS
                echo "Extracted Test Specific Breakpoints in Deletion category"
        done
else
    	echo "You don't have log_test"
        exit
fi

ls List_test.name > log_test
ls ../COPS_output/*.COPS > log_cops

if test -e log_test && test -e log_cops
then
	cat List_test.name | while read input
	do
		cat Test.Specific.$input.Ins.BPS Test.Specific.$input.Del.BPS | sed 's/]://g' | sort -n -k1 > Test.Specific.$input.BPS
		awk < ../COPS_output/$input.COPS "{print \$2\"\\t\"\$4\"\\tS\"}" > $input.COPS.S
		awk < ../COPS_output/$input.COPS "{print \$3\"\\t\"\$4\"\\tE\"}" > $input.COPS.E
		awk < Test.Specific.$input.BPS "{print \$7\"\\t\"\$8\"\\t\"\$3}" > Test.Specific.$input.BPS.parsed
		cat $input.COPS.S $input.COPS.E Test.Specific.$input.BPS.parsed | sort -n -k1 > Test.Specific.$input.BPS.COPS.merge
		perl mapBPCOPS.pl Test.Specific.$input.BPS.COPS.merge > Test.Specific.$input.BPS.COPS.map
	done
else 
	echo "You are missing List_testname or COPS output file"
	exit
fi

ls *.map > log_map

if test -e log_map
then
	cat log_map | while read input
	do
		echo "Mapped Breakpoints to COPS SCNAs: $input"
		exit
	done
else 
	echo "Error somewhere. You could be missing mapBPCOPS.pl or the inputs to it."
	exit
fi
		
rm *merge *BPS *.S *.E *.cov *.Ins *.Del log* *parsed
mv *.map ../COPS_output
