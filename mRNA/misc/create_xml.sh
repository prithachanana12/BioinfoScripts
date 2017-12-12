#!/bin/sh

if [ $# != 4 ]
then
	echo "USAGE: create_xml.sh <bw_dir> <alignment_dir> <output_dir> <samples (: sep)>"
	echo "ftp delivery paths are needed"
else
	
	bigwigs=$1
	junctions=$2
	out_dir=$3
	samples=$4

	touch ${out_dir}/wig_session.xml
	echo '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' >> ${out_dir}/wig_session.xml
	echo '<Global genome="hg19" locus="All" version="4">' >> ${out_dir}/wig_session.xml
	echo '<Resources>' >> ${out_dir}/wig_session.xml
	for sample in `echo $samples | tr ':' ' '`; do
		echo -e "\t<Resource name=\"${sample}.bw\" path=\"${bigwigs}/${sample}.bw\" />" >> ${out_dir}/wig_session.xml
		echo -e "\t<Resource name=\"${sample}_junctions\" path=\"${junctions}/tophat_${sample}/junctions.bed\" />" >> ${out_dir}/wig_session.xml
	done

	echo '</Resources>' >> ${out_dir}/wig_session.xml
	echo '</Global>' >> ${out_dir}/wig_session.xml
fi 

