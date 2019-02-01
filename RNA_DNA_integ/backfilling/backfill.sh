#!/bin/sh

#backfill variants in DNA normals and tumors from RNA VCF

if [ $# != 4 ]
then
        echo "Usage: <file.list with each row having path of single bam file> <output_dir> <RNA VCF> <result_filename>"
        exit 1;
fi

set -x
echo `date`
bamlist=$1
output=$2
rna_vcf=$3
outfile=$4

#input="-I $(echo $input_bams | sed 's/:/ -I /g')"
gatk=/data5/bsi/bictools/alignment/gatk/3.3-0/GenomeAnalysisTK.jar
java=/usr/local/biotools/java/jdk1.7.0_67/bin/java
ref=/data2/bsi/reference/sequence/human/ncbi/37.1/indexed/allchr.fa

$java -Xmx10g -Djava.io.tmpdir=${output} -jar $gatk -T UnifiedGenotyper -R $ref -I ${bamlist} -L ${rna_vcf} --alleles ${rna_vcf} --genotyping_mode GENOTYPE_GIVEN_ALLELES --output_mode EMIT_ALL_SITES -glm SNP -o ${output}/${outfile}
