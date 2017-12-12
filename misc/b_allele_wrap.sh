#!/bin/sh
##variant calling using UG, generate B allele freq plots on called variants

if [ $# != 3 ]
then 
	echo "USAGE: b_allele_wrap.sh <input dir> <sample name> <out_dir>"
	exit 1
else
	in_dir=$1
	sample=$2
	out_dir=$3

	##call common SNPs	
	/usr/local/biotools/java/jdk1.8.0_20/bin/java -jar /data5/bsi/bictools/src/gatk/3.4-46/GenomeAnalysisTK.jar -T UnifiedGenotyper -R /data2/bsi/reference/sequence/human/ncbi/37.1/allchr.fa -L /data2/bsi/staff_analysis/m088341/Olson/B_Allele_Freq/SL2_QC/common_dbsnp_variants.agilentv5UTR.snv.chr.vcf -I ${in_dir}/${sample}.*.bam -glm SNP --output_mode EMIT_ALL_SITES -gt_mode GENOTYPE_GIVEN_ALLELES --alleles /data2/bsi/staff_analysis/m088341/Olson/B_Allele_Freq/SL2_QC/common_dbsnp_variants.agilentv5UTR.snv.chr.vcf -o ${out_dir}/${sample}.vcf
	
	##filter variants with DP < 5
	/usr/local/biotools/java/jdk1.8.0_20/bin/java -jar /data5/bsi/bictools/src/gatk/3.4-46/GenomeAnalysisTK.jar -T VariantFiltration -R /data2/bsi/reference/sequence/human/ncbi/37.1/allchr.fa -o ${out_dir}/${sample}.filter.vcf -V ${out_dir}/${sample}.vcf --genotypeFilterExpression "DP < 5" --genotypeFilterName "DP_filter"

	##remove filtered variants
	cat ${out_dir}/${sample}.filter.vcf | grep -v "DP_filter" > ${out_dir}/${sample}.filterDP.vcf

	##convert VCF to table
	/usr/local/biotools/java/jdk1.8.0_20/bin/java -jar /data5/bsi/bictools/src/gatk/3.4-46/GenomeAnalysisTK.jar -T VariantsToTable -R /data2/bsi/reference/sequence/human/ncbi/37.1/allchr.fa -V ${out_dir}/${sample}.filterDP.vcf -F CHROM -F POS -F ID -F REF -F ALT -GF AD -GF GQ -raw -o ${out_dir}/${sample}.filterDP.vcf.txt

	##calculate BAF, add MAF, reformat
	/data2/bsi/staff_analysis/m088341/Olson/B_Allele_Freq/SL2_QC/add_maf.vcf.pl ${out_dir}/${sample}.filterDP.vcf.txt /data2/bsi/staff_analysis/m088341/Olson/B_Allele_Freq/SL2_QC/common_dbsnp_variants.agilentv5UTR.snv.chr.vcf ${out_dir}/${sample}.filterDP.vcf.txt.aaf

	##create plots dir
	mkdir -p ${out_dir}/plots/

	##plot BAF and histogram
	/usr/local/biotools/r/R-3.2.3/bin/Rscript /data2/bsi/staff_analysis/m133293/scripts/b_allele_singleChr.R ${out_dir}/${sample}.filterDP.vcf.txt.aaf ${out_dir}/plots/${sample}.BAF.png

fi
