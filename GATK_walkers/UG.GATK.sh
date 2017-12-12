#!/bin/sh
## run unified genotyper on RNA seq bams 

if [ $# != 3 ] 
then
	echo "USAGE: UG.GATK.sh path_to_bam full_path_output_dir sample_name"
else
	set -x
	echo `date`
	
	rna_bam=$1
	output=$2
	sample=$3
	mkdir -p $output/temp
	/usr/local/biotools/java/jdk1.7.0_67/bin/java -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx4g -Xms2g -Djava.io.tmpdir=$output/temp -jar /projects/bsi/bictools/apps/variant_detection/rvboost/RVboost_0.1/bin/gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -I $rna_bam -o $output/$sample.raw.vcf -R /projects/bsi/bictools/apps/variant_detection/rvboost/RVboost_0.1/resources/reference.fa -nt 1 -L /projects/bsi/bictools/apps/variant_detection/rvboost/RVboost_0.1/resources/coding.bed -dfrac 0.25 -stand_call_conf 0 -stand_emit_conf 0 > $output/logs/UnifiedGenotyper.raw.log 2>&1	

fi
