#!/bin/bash
wd=$1
out_dir=$2

cd $wd
for file in $(ls *.vcf)
do
sample=$(basename $file .vcf)
cat ${sample}.vcf|grep -v "##SAMPLE=<ID" |sed 's/VCFv4.2/VCFv4.1/g' > ${sample}_v4.1.vcf
if [[ -s ${sample}_v4.1.vcf ]] 
then
/projects/bsi/bictools/apps/alignment/tabix/0.2.5/bgzip ${sample}_v4.1.vcf
/projects/bsi/bictools/apps/alignment/tabix/0.2.5/tabix -p vcf ${sample}_v4.1.vcf.gz
fi
done

#cat_in=$(echo $(for file in $(ls *v4.1.vcf.gz);do echo "-v" $file ;done))
#echo $cat_in
#/projects/bsi/bictools/scripts/dnaseq/GENOME_GPS/tags/3.0.2/CatVariants.sh  $cat_in -t /data2/bsi/secondary/Braggio_Esteban_m037525/exome/tum-germ-20170302/docs/config/tool_info.txt -m /data2/bsi/secondary/Braggio_Esteban_m037525/exome/tum-germ-20170302/docs/config/memory_info.txt -o ${out}.vcf
for file in $(ls *v4.1.vcf.gz)
do
sample=$(basename $file _v4.1.vcf.gz) 
zcat ${file} | perl /data2/bsi/staff_analysis/m078940/projects/braggio/fixDP.pl > ${sample}_DP.vcf
/projects/bsi/bictools/apps/alignment/tabix/0.2.5/bgzip ${sample}_DP.vcf
/projects/bsi/bictools/apps/alignment/tabix/0.2.5/tabix -p vcf ${sample}_DP.vcf.gz
/data5/bsi/bictools/scripts/bior_annotate/v2.8.4/trunk/bior_annotate.sh -o ${sample}_annot -v ${sample}_DP.vcf.gz -O ${out_dir} -T /projects/bsi/bictools/scripts/dnaseq/GENOME_GPS/tags/4.0.1/config/tool_info.hg19.txt -M /projects/bsi/bictools/scripts/dnaseq/GENOME_GPS/tags/4.0.1/config/memory_info.txt -c /projects/bsi/bictools/scripts/dnaseq/GENOME_GPS/tags/3.0/annotation/catalog_file -L -d /projects/bsi/bictools/scripts/dnaseq/GENOME_GPS/tags/3.0/annotation/drill_file
perl /data2/bsi/staff_analysis/m133293/scripts/mutect2/bior_vcf2xls_editted_noGQ.pl -i ${out_dir}/${sample}_annot.vcf -o ${out_dir}/${sample}_annot.xls -c /data2/bsi/staff_analysis/m133293/scripts/mutect2/drill.table.mutect2
done 

