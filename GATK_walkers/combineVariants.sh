#!/bin/sh
# combine variants

if [ $# != 2 ];
then
	echo "usage: <input_vcf_colon_sep> <output_vcf_full_path>";
	exit 1;
fi
	set -x
	input_vcf=$1
	output_vcf=$2
	in_var="-V $(echo $input_vcf | sed 's/:/ -V /g')"


	/usr/local/biotools/java/jdk1.7.0_67/bin/java -jar /data5/bsi/bictools/alignment/gatk/3.3-0/GenomeAnalysisTK.jar -T CombineVariants -R /data2/bsi/reference/sequence/human/ncbi/hg19/allchr.fa $in_var -o $output_vcf -env -genotypeMergeOptions UNIQUIFY

	bgzip $output_vcf
	tabix -p vcf ${output_vcf}.gz

echo $(date)

