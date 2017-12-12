#!/bin/sh

if [ $# != 4 ]
then 
	echo "USAGE:cutadapt_trim.sh <input_dir> <read1> <output_dir> <outfile_base>"
else
	set -x 
	echo `date`

	input_dir=$1
	r1=$2
	#r2=$3
	output_dir=$3
	outfile=$4
	#logs=${output_dir}/logs/
	#sample=`echo ${r1} | cut -f1,2 -d"."` 

	#mkdir -p ${logs}
	/projects/bsi/bictools/apps/alignment/cutadapt/1.8.1/bin/cutadapt -m 25 -a TGGAATTCTCGGGTGCCAAGG -o ${output_dir}/${outfile}.R1.fastq.gz ${input_dir}/${r1}
	/projects/bsi/bictools/apps/alignment/cutadapt/1.8.1/bin/cutadapt -u 4 -u -4 -o ${output_dir}/${outfile}.R1.final.fastq.gz ${output_dir}/${outfile}.R1.fastq.gz

fi
