#!/bin/sh
##convert CRAM files to FASTQs

if [ $# != 2 ] 
then
	echo "USAGE: cram2bam.sh <path_to_cram_file> <path_to_output_bam>"
else
	set -x
	echo `date`
	
	cram=$1
	ref=/data2/bsi/secondary/Klee_Eric_mrl2075/config/external_SL2/GeneDx/raw_data/hg19.fa
	bam=$2
	
	#/usr/local/biotools/java/jdk1.8.0_20/bin/java -jar /data5/bsi/bictools/src/cramtools/3.0/cramtools-3.0.jar bam --input-cram-file ${cram} --reference-fasta-file ${ref} --output-bam-file ${bam}
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools view -hb -T $ref $cram > $bam
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools index $bam
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools fastq -1 ${bam}.R1.fastq -2 ${bam}.R2.fastq --reference $ref ${bam}
	gzip ${bam}.R1.fastq
	gzip ${bam}.R2.fastq
		
fi
