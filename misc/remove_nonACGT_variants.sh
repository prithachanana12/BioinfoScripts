#!/bin/sh
## remove non-canonical bases from Ref position in VCFs

if [ $# != 2 ]
then
	echo "USAGE: remove_nonACGT_variants.sh <input vcf> <output dir> "
else
	in_vcf=$1
	out_dir=$2
	out_vcf=`basename ${in_vcf} .gz`

	echo `date`
	set -x

	touch ${out_dir}/temp_vcf
	zcat ${in_vcf} | grep "^#" > ${out_dir}/temp_vcf
	zcat ${in_vcf} | grep -v "^#" | awk -F"\t" '$4~/[ACGT]/ {print}' - >> ${out_dir}/temp_vcf
	mv ${out_dir}/temp_vcf ${out_dir}/${out_vcf}
	bgzip ${out_vcf}
	tabix -p vcf ${out_vcf}.gz

fi
