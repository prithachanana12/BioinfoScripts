#!/bin/sh

if [ $# != 4 ]
then
	echo "Usage:";
	echo "1. input directory";
	echo "2. output directory";
	echo "3. sample name";
	echo "4. GTF, full path";
else
	set -x
	echo `date`
	input_dir=$1
	output_dir=$2
	sample=$3
	gtf=$4
	
#        /projects/bsi/bictools/apps/mrnaseq/subread/current/featureCounts -a $gtf -o $output_dir/$sample.gene.count.tsv $input_dir/${sample}_sorted.bam 

	/projects/bsi/bictools/apps/alignment/subread/1.4.6/featureCounts -a $gtf -O -o $output_dir/$sample.gene.count.tsv $input_dir/$sample.bam
#	/projects/bsi/bictools/apps/alignment/subread/1.4.6/featureCounts -a $gtf -g exon_id -f -O -o $output_dir/$sample.exon.count.tsv $input_dir/$sample.bam

fi
