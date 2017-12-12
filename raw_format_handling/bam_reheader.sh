#!/bin/sh

if [ $# != 3 ]
then
	echo "USAGE: bam_reheader.sh <sample name> <input dir> <output dir>"
else
	set -x
	echo `date`
	sample=$1
	input_dir=$2
	output_dir=$3

	/data5/bsi/bictools/alignment/samtools/1.0/samtools view -H $input_dir/$sample.bam | sed -e 's/SN:\([0-9XYG]\)/SN:chr\1/' -e 's/SN:MT/SN:chrM/' | grep -v -E 'NC_|ERCC|hs37d5|U13369|FR872717|AF092932|chrGL' | /data5/bsi/bictools/alignment/samtools/1.0/samtools reheader - $input_dir/$sample.bam > $output_dir/$sample.bam

fi

