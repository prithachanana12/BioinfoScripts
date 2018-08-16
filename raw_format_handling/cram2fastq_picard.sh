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
	picard=/projects/bsi/bictools/apps/alignment/picard/1.55/
	output_dir=$(dirname $bam)
	
	#/usr/local/biotools/java/jdk1.8.0_20/bin/java -jar /data5/bsi/bictools/src/cramtools/3.0/cramtools-3.0.jar bam --input-cram-file ${cram} --reference-fasta-file ${ref} --output-bam-file ${bam}
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools view -hb -f 1 -F 2048 -F 256 -T $ref $cram > $bam
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools index $bam
	/data5/bsi/bictools/alignment/samtools/1.3.1/samtools sort -o ${bam}.sorted.bam -n $bam
	#/data5/bsi/bictools/alignment/samtools/1.3.1/samtools fastq -f 1 -F 2048 -F 256 -1 ${bam}.R1.fastq -2 ${bam}.R2.fastq --reference $ref ${bam}.sorted.bam
	/usr/local/biotools/java/jdk1.6.0_05/bin/java -Xmx15g -Xms512m -jar $picard/SamToFastq.jar INPUT=${bam}.sorted.bam FASTQ=${bam}.R1.fastq SECOND_END_FASTQ=${bam}.R2.fastq VALIDATION_STRINGENCY=SILENT TMP_DIR=$output_dir/

	gzip ${bam}.R1.fastq
	gzip ${bam}.R2.fastq
		
fi
