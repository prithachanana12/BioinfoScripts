#!/bin/sh
## run haplotype caller and save realigned bams

if [ $# != 3 ] 
then
	echo "USAGE: HC_getBam.sh path_to_bam full_path_output_dir sample_name"
else
	set -x
	echo `date`
	
	dna_bam=$1
	output=$2
	sample=$3
	mkdir -p $output/temp

	/usr/local/biotools/java/jdk1.7.0_03/bin/java -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx10g -Xms5g -Djava.io.tmpdir=$output/temp -jar /data5/bsi/bictools/alignment/gatk/3.4-46/GenomeAnalysisTK.jar -T HaplotypeCaller -nct 1 --emitRefConfidence NONE -I $dna_bam -o $output/${sample}.HC.vcf -R /data2/bsi/reference/sequence/human/ncbi/hg19/allchr.fa -et NO_ET -K /data5/bsi/bictools/alignment/gatk/3.4-46/Hossain.Asif_mayo.edu.key -stand_call_conf 30 -stand_emit_conf 10 -GQB 20 --variant_index_type LINEAR --variant_index_parameter 128000 -bamout $output/${sample}.HCrealigned.bam

fi
