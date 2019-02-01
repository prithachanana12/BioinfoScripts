#!/bin/sh

if [ $# != 2 ]
then
	echo "This script converts result xls file from RNA-DNA integration workflow to VCF format using original maprseq vcf header."
        echo "USAGE: res2vcf.sh <file with list of vcfs from maprseq> <input dir>"
else
        set -x
        echo `date`
        vcfs=$1
        input_dir=$2
	
	for i in $(cat $vcfs); do
		sample=$(basename ${i} .filter.vcf)
		cat ${i} | grep "^#" > ${sample}.mod.vcf
		cut -f1-10 ${input_dir}/${sample}.BIOR.filter.xls | awk -F"\t" '{if ($7 == "PASS" || $7 == "SIFT/Polyphen") print}' | tail -n +2 >> ${sample}.mod.vcf
	done
fi
