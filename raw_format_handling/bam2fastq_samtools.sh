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
	
	#/usr/local/biotools/java/jdk1.6.0_05/bin/java -Xmx15g -Xms512m -jar $picard/SamToFastq.jar INPUT=$input_dir/$input_bam FASTQ=$output_dir/$input_bam.R1.fastq SECOND_END_FASTQ=$output_dir/$input_bam.R2.fastq VALIDATION_STRINGENCY=SILENT TMP_DIR=$output_dir/
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools fastq -1 ${output_dir}/${input_bam}.R1.fastq -2 ${output_dir}/${input_bam}.R2.fastq --reference $ref ${input_dir}/${input_bam}
	
	gzip $output_dir/$input_bam.R1.fastq
	gzip $output_dir/$input_bam.R2.fastq
fi	

