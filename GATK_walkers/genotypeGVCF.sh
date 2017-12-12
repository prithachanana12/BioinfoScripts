#!/bin/sh

if [ $# != 3 ]
then
	echo "USAGE: genotypeGVCF.sh <file with full paths to samples> <output_dir> <output_file>";
else
	set -x 
	sample=$1
	out_dir=$2
	out_file=$3
	gatk=/data5/bsi/bictools/alignment/gatk/3.3-0/GenomeAnalysisTK.jar
	java=/usr/local/biotools/java/jdk1.7.0_67/bin/java
	ref=/data2/bsi/reference/sequence/human/ncbi/37.1/indexed/allchr.fa
	vars="$(cat $sample | sed 's/^/-V /' | tr '\n' ' ')"

	$java -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx20g -Xms5g -jar $gatk -T GenotypeGVCFs -R $ref $vars -o ${out_dir}/${out_file}

fi
