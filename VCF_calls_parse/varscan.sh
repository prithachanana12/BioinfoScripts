#!/bin/sh
##run varscan

if [ $# != 4 ];
then
        echo "usage: varscan.sh <sample name> <input dir> <output dir> <min variant freq>";
else
        set -x
        echo `date`
	sample=$1
	input_dir=$2
	output_dir=$3	
	percent_freq=$4
	
	/usr/local/biotools/java/jdk1.7.0_67/bin/java -jar /data5/bsi/bictools/src/varscan/2.4.0/VarScan.v2.4.0.jar somatic ${input_dir}/${sample}_Ref.mpileup ${input_dir}/${sample}_TP1.mpileup ${output_dir}/${sample}_TP1_varscan --output-vcf --min-var-freq ${percent_freq} --min-coverage 8 --min-coverage-normal 8 --min-coverage-tumor 6 --min-freq-for-hom 0.01 --normal-purity 1.00 --tumor-purity 1.00 --p-value 0.99 --somatic-p-value 0.05 --strand-filter 0
	/usr/local/biotools/java/jdk1.7.0_67/bin/java -jar /data5/bsi/bictools/src/varscan/2.4.0/VarScan.v2.4.0.jar somatic ${input_dir}/${sample}_Ref.mpileup ${input_dir}/${sample}_TP2.mpileup ${output_dir}/${sample}_TP2_varscan --output-vcf --min-var-freq ${percent_freq} --min-coverage 8 --min-coverage-normal 8 --min-coverage-tumor 6 --min-freq-for-hom 0.01 --normal-purity 1.00 --tumor-purity 1.00 --p-value 0.99 --somatic-p-value 0.05 --strand-filter 0 


fi
