#!/bin/sh
##run SnpEff on unannotated mouse VCFs

if [ $# != 2 ] 
then
	echo "USAGE: snpeff.sh <path to input vcf> <path to output vcf>"
else
	set -x
	echo `date`
	
	snpeff=/data5/bsi/bictools/src/snpeff/4.3g/
	java=/usr/local/biotools/java/jdk1.8.0_20/bin/
	in_vcf=$1
	out_vcf=$2
	
	$java/java -Xmx5g -jar $snpeff/snpEff.jar GRCm38.75 ${in_vcf} > ${out_vcf}

fi
