#!/bin/sh
# split a VCF: tumor-normal pairs

if [ $# != 5 ];
then
	echo "usage: <input vcf> <output_dir> <normal_sample> <tumor_sample> <output_vcf>";
	exit 1;
fi
	set -x
	input_vcf=$1
	output_dir=$2
	normal=$3
	tumor=$4
	out_vcf=$5

	/usr/local/biotools/java/jdk1.7.0_67/bin/java -jar /data5/bsi/bictools/alignment/gatk/3.3-0/GenomeAnalysisTK.jar -T SelectVariants -R /data2/bsi/reference/sequence/human/ncbi/hg19/allchr.fa -V $input_vcf -sn $normal -sn $tumor -o $output_dir/$out_vcf --excludeNonVariants

	bgzip $output_dir/$out_vcf
	tabix -p vcf $output_dir/${out_vcf}.gz


echo $(date)

