#!/bin/sh

if [ $# != 2 ]
then
	echo "USAGE: bam_index.sh <sample name> <input dir>"
else
	set -x
	echo `date`
	sample=$1
	input_dir=$2
	
	/projects/bsi/bictools/apps/alignment/samtools/latest/samtools index $input_dir/${sample}.bam

fi

