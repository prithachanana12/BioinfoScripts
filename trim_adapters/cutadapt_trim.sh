#!/bin/sh

if [ $# != 5 ]
then 
	echo "USAGE:cutadapt_trim.sh <input_dir> <read1> <read2> <output_dir> <outfile_base>"
else
	set -x 
	echo `date`

	input_dir=$1
	r1=$2
	r2=$3
	output_dir=$4
	outfile=$5
	logs=${output_dir}/logs/
	sample=`echo ${r1} | cut -f1,2 -d"."` 

	mkdir -p ${logs}
	qsub -N trim_${sample} -V -q 4-days -m a -M chanana.pritha@mayo.edu -b y -l h_vmem=5G -l h_stack=10M -wd ${logs} /projects/bsi/bictools/apps/alignment/cutadapt/1.8.1/bin/cutadapt -m 32 -a AGATCGGAAGAGC -A AGATCGGAAGAGC -o ${output_dir}/${outfile}.R1.fastq.gz -p ${output_dir}/${outfile}.R2.fastq.gz ${input_dir}/${r1} ${input_dir}/${r2} 

fi
