#!/bin/sh
# generate fastqs from bams

if [ $# != 3 ];
then
	echo "usage: <input dir> <input bam> <output_dir>";
else					
	set -x
	input_dir=$1
	input_bam=$2
	output_dir=$3
	picard=/projects/bsi/bictools/apps/alignment/picard/1.55/
	
	
	sample=$(echo $input_bam | cut -d"." -f1)

	#/usr/java/latest/bin/java -Xmx6g -Xms512m -jar $picard/RevertSam.jar INPUT=$output_dir/bams_links/$input_bam OUTPUT=$output_dir/reverted_bams3/$sample.bam VALIDATION_STRINGENCY=SILENT TMP_DIR=$output_dir/bams_links/ SORT_ORDER=unsorted

	/usr/local/biotools/java/jdk1.6.0_05/bin/java -Xmx15g -Xms512m -jar $picard/SamToFastq.jar INPUT=$input_dir/$input_bam FASTQ=$output_dir/$input_bam.R1.fastq SECOND_END_FASTQ=$output_dir/$input_bam.R2.fastq VALIDATION_STRINGENCY=SILENT TMP_DIR=$output_dir/

	gzip $output_dir/$input_bam.R1.fastq
	gzip $output_dir/$input_bam.R2.fastq
fi	

