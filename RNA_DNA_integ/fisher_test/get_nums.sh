#!/bin/sh

#get stats from RNA-DNA pipeline
#provide _byGeneList summaries of cases and controls to get number of samples with mutation in each cohort
#pass output file to fisher.R

if [ $# != 3 ];
then
	echo "USAGE: get_nums.sh cases_by_gene.txt controls_by_gene.txt output.txt"
	exit;
fi 
	cases=$1
	controls=$2
	outfile=$3
	
	touch $outfile
	for gene in $(cut -f2 $cases)
	do
	num_ctrls=$(cat $controls | grep -w $gene | cut -f1 | paste -sd+ | bc)
	num_cases=$(cat $cases | grep -w $gene | cut -f1 | paste -sd+ | bc)
	echo -e $gene'\t'$num_cases'\t'$num_ctrls >> $outfile
	done
 
