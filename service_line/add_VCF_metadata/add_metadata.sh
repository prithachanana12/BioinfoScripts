#!/bin/sh

if [ $# != 2 ]
then
	echo -e "USAGE: add_metadata.sh <path to annotated variants.vcf> <runinfo.txt>"
	echo -e ".ped file should have all individuals assigned to a family (-9 not accepted)"
	exit 
else
	set -x 
	echo `date`
	vcf=$1
	runinfo=$2
	source $runinfo

	##check if ped file is peachy
	flag=$(cat $PEDFILE | grep "\-9\t")
	if [ ! -z "$flag" ]; then
		echo "Please remove the -9 families from the ped file and assign each sample a family."
		exit
	fi
	
	out_dir=$(dirname $vcf)
	touch ${out_dir}/files.list.txt
	for fam in $(cut -f1 $PEDFILE | sort | uniq); do
		samps=$(cat $PEDFILE | grep ${fam} | cut -f2 | tr '\n' ',' | sed 's/,$//')
		/research/bsi/tools/biotools/vcftools/0.1.14/bin/vcf-subset -e -c ${samps} $vcf > ${out_dir}/variants.${fam}.vcf
		ls ${out_dir}/variants.${fam}.vcf >> ${out_dir}/files.list.txt
	done	
	
	for i in $(cat ${out_dir}/files.list.txt); do
		fam=$(basename ${i} | cut -f2 -d".")
		cat ${i} | grep "^##" > ${out_dir}/header.${fam}.tmp
		proband=$(cat $PEDFILE | grep ${fam} | cut -f2 | grep -vE '*[A-Za-z]$')
		mother=$(cat $PEDFILE | grep ${fam} | cut -f2 | grep -E '*[Aa]$')
		father=$(cat $PEDFILE | grep ${fam} | cut -f2 | grep -E '*[Bb]$')
		if [[ ( ! -z $proband ) && ( ! -z $mother ) && (! -z $father ) ]]; then trio=Yes; else trio=No; fi
		if [[ $trio == "Yes" ]]; then
			echo -e "##SAMPLE_SET=trio" >> ${out_dir}/header.${fam}.tmp
		fi
		if [[ ( ! -z $proband ) && ( -z $mother ) && ( -z $father ) ]]; then single=Yes; else single=No; fi
		if [[ $single == "Yes" ]]; then
                	echo -e "##SAMPLE_SET=singleton" >> ${out_dir}/header.${fam}.tmp
                fi
		if [[ $trio == "No" && $single == "No" ]]; then 
			echo -e "##SAMPLE_SET=other" >> ${out_dir}/header.${fam}.tmp
		fi
		#echo -e "##trio_${fam}=${trio}" >> ${out_dir}/header.tmp
		echo -e "##PROBAND=${proband}" >> ${out_dir}/header.${fam}.tmp
		if [ $(cat $PEDFILE | grep -w ${proband} | cut -f5) == 1 ]; then sex=M; else sex=F; fi
		echo -e "##PROBAND_SEX=${sex}" >> ${out_dir}/header.${fam}.tmp
		if [ ! -z "${mother}" ]; then 
			echo -e "##MOTHER=${mother}" >> ${out_dir}/header.${fam}.tmp
			if [[ $(cat $PEDFILE | awk -v mot="$mother" '$2==mot {print $0}' | cut -f6) == 1 ]]; then phenM=False; else phenM=True; fi
			echo -e "##MOTHER_PHENOTYPE_AFFECTED=${phenM}" >> ${out_dir}/header.${fam}.tmp
		fi
		if [ ! -z "${father}" ]; then
                        echo -e "##FATHER=${father}" >> ${out_dir}/header.${fam}.tmp
			if [[ $(cat $PEDFILE | awk -v fat="$father" '$2==fat {print $0}' | cut -f6) == 1 ]]; then phenF=False; else phenF=True; fi
                        echo -e "##FATHER_PHENOTYPE_AFFECTED=${phenF}" >> ${out_dir}/header.${fam}.tmp
                fi
	done
	
#	if [ ! -z "$(cat $runinfo | grep ^REL)" ]; then
#		for samp in $(cat $runinfo | grep ^REL); do 
#			fam=$(cat $PEDFILE | grep -w $(echo $samp | cut -f1 -d"=" | cut -f1 --complement -d"_") | cut -f1)
#			rel=$(echo $samp | cut -f2 -d"=")
#			echo -e "##${fam}_${rel}=$(echo $samp | cut -f1 -d'=' | cut -f1 --complement -d'_')" >> ${out_dir}/header.tmp
#		done
#	fi
	
	for moi in $(cat $runinfo | grep ^MOI); do
		fam=$(echo $moi | cut -f1 -d"=" |cut -f2 -d"_")
		echo -e "##MODE_OF_INHERITANCE=[$(echo $moi | cut -f2 -d'=')]" >> ${out_dir}/header.${fam}.tmp
	done

#	for inherit in $(cat $runinfo | grep ^INHERIT); do
#		fam=$(echo $inherit | cut -f1 -d"=" |cut -f2 -d"_")
#		echo -e "##${fam}_probandInherited=$(echo $inherit | cut -f2 -d'=')" >> ${out_dir}/header.tmp
#	done	

	for i in $(cat ${out_dir}/files.list.txt); do
                fam=$(basename ${i} | cut -f2 -d".")
		cat ${i} | grep "^#CHROM" >> ${out_dir}/header.${fam}.tmp
		cat ${i} | grep -v "^#" >> ${out_dir}/header.${fam}.tmp
		mv ${out_dir}/header.${fam}.tmp ${out_dir}/variants.${fam}.metadata.vcf
		bgzip ${out_dir}/variants.${fam}.metadata.vcf
		tabix -p vcf ${out_dir}/variants.${fam}.metadata.vcf.gz
	done
		
#	zcat $vcf | grep "^#CHROM" >> ${out_dir}/header.tmp
#	zcat $vcf | grep -v "^#" >> ${out_dir}/header.tmp
#	mv ${out_dir}/header.tmp ${out_dir}/variants.metadata.vcf
#	bgzip ${out_dir}/variants.metadata.vcf
#	tabix -p vcf ${out_dir}/variants.metadata.vcf.gz
	rm ${out_dir}/files.list.txt
	
fi

