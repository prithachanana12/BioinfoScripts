#!/bin/sh

if [ $# != 3 ]
then
	echo "USAGE: deFuse.sh <sample> <results_dir> <input_dir>"
	echo "defuse does not handle .gz files"
	echo "Create ~/.Rprofile with following lines"
	echo "library(rlocal)"
	echo ".libPaths("/data5/bsi/bictools/src/R/3.1.1/lib/")"
	echo "addLibGentools(first=FALSE)"
else
	set -x 
	sample=$1
	out=$2
	fastq=$3
	log=${out}/logs/
	defuse=/data5/bsi/bictools/src/defuse/0.6.2/scripts/
	config=/data2/bsi/secondary/Borad_Mitesh_m057531/mrnaseq/star_fusions/deFuse/config.txt
	results=${out}/${sample}/
	
	mkdir -p ${log}
	mkdir -p ${results}
	qsub -N ${sample}_defuse -m a -M chanana.pritha@mayo.edu -pe threaded 4 -wd ${log} -q 4-days -l h_vmem=6G -l h_stack=10M -b y /usr/local/biotools/perl/5.10.0/bin/perl ${defuse}/defuse.pl -c ${config} -1 ${fastq}/${sample}.R1.fastq -2 ${fastq}/${sample}.R2.fastq -o ${results} -p 4
	echo `date`

fi
