#!/bin/sh
# generate fastqs from bams

if [ $# != 4 ];
then
	echo "usage: <input dir> <input bam> <output_dir> <ref_fasta>";
else					
	set -x
	input_dir=$1
	input_bam=$2
	output_dir=$3
	ref=$4
	
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools view -bh -F 2048 -F 256 ${input_dir}/${input_bam} > ${output_dir}/${input_bam}.tmp.bam
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools sort -o ${output_dir}/${input_bam}.sorted.bam -n ${output_dir}/${input_bam}.tmp.bam
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools fastq -1 ${output_dir}/${input_bam}.R1.fastq -2 ${output_dir}/${input_bam}.R2.fastq --reference $ref ${output_dir}/${input_bam}.sorted.bam
	
	gzip $output_dir/$input_bam.R1.fastq
	gzip $output_dir/$input_bam.R2.fastq
	rm ${output_dir}/${input_bam}.tmp.bam
	rm ${output_dir}/${input_bam}.sorted.bam
fi	

