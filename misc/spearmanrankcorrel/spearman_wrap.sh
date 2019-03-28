#!/bin/sh

if [ $# != 2 ];
then
	echo "USAGE: spearman_wrap.sh input_file output_file"
	exit 1;
else
	echo `date`
	infile=$1
	outfile=$2

	echo -e Gene"\t"pval"\t"rho > $outfile	
	tail -n +2 ${infile} | cut -f1 | sort | uniq > genes.txt
	for gene in $(cat genes.txt); do
		head -1 ${infile} > tmp.txt
		cat ${infile} | grep $gene >> tmp.txt
		pval=$(Rscript /data2/bsi/tertiary/Weroha_Saravut_m045639/mrnaseq/Genentech_single_RNA/spearman_rank_cor.R tmp.txt | grep "[1]" | cut -f2 -d" ")
		rho=$(Rscript /data2/bsi/tertiary/Weroha_Saravut_m045639/mrnaseq/Genentech_single_RNA/spearman_rank_cor.R tmp.txt | grep -A1 rho | tail -1)
		echo -e $gene"\t"$pval"\t"$rho >> $outfile
	done
	rm tmp.txt	
		
fi	
