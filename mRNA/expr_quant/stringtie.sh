#!/bin/sh

if [ $# != 4 ]
then
	echo -e "Usage: Run StringTie in batch mode\n StringTie.sh <path to BAM> <sample name> <reference annotation file> <path to output directory>"
else
    set -x
    echo `date`
	bam=$1
	sample=$2
	ref_gtf=$3
	out_dir=$4
	

	stringtie=/data5/bsi/bictools/src/stringtie/1.3.0/
	#$stringtie/stringtie $bam/${sample}.Aligned.sortedByCoord.out.bam -G $ref_gtf -l $sample -o $out_dir/${sample}.gtf -p 5


	#ls $out_dir/${sample}.gtf >> $out_dir/mergelist.txt
	#$stringtie/stringtie --merge -G $ref_gtf -o $out_dir/stringtie_merged.gtf -p 4 $out_dir/mergelist.txt
	#for i in `echo $sample | tr ':' ' '`; do 
	$stringtie/stringtie $bam/${sample}.Aligned.sortedByCoord.out.bam -G $out_dir/stringtie_merged.gtf -e -B -l $sample -o $out_dir/${sample}_mergedTrans.gtf -p 4
	#done

    echo `date`
fi
