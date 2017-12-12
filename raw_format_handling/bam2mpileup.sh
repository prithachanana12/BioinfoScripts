#!/bin/sh
##create mpileup files from sorted bams

if [ $# != 3 ];
then
        echo "usage: bam2mpileup.sh <sample name> <input dir> <output dir>";
else
        set -x
	echo `date`
	sample=$1
	input_dir=$2
	output_dir=$3
	
	
	/projects/bsi/bictools/apps/alignment/samtools/latest/samtools mpileup -f /data2/bsi/reference/sequence/human/ncbi/hg19/allchr.fa -l /data5/bsi/refdata/exomeCapture/GenomeGPS/3.0/Agilent_S04380219_SureSelect_Human_All_Exon_V5+UTRs_hg19.capture.bed ${input_dir}/${sample}.bam > ${output_dir}/${sample}.mpileup


fi
