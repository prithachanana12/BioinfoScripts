#!/bin/sh

if [ $# != 3 ]
then
	echo "USAGE: HardTrim.sh <input fastq> <input dir> <output dir>";
else
	set -x 
	echo `date`
	out=$(echo $1 | sed s/'_R1_'/'_R3_'/g | sed s/'_R2_'/'_R4_'/g)
	input_dir=$2
	output_dir=$3
	cd ${input_dir}
	zcat $1 | awk --posix '{ if (NR % 2 == 0) { sub(/.{50}$/,""); print} else {print}}' | gzip > ${output_dir}/${out}

fi
