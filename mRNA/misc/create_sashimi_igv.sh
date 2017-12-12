#!/bin/sh
##junction sashimi plots for Dr. Ordog

if [ $# != 3 ]
then
	echo "USAGE: create_xml.sh <bed_dir> <output_dir> <samples (: sep)>"
	echo "ftp delivery paths are needed"
else
	
	#bigwigs=$1
	junctions=$1
	out_dir=$2
	samples=$3

	touch ${out_dir}/wig_sashimi.xml
	echo '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' >> ${out_dir}/wig_sashimi.xml
	echo '<Global genome="mm10" locus="All" version="4">' >> ${out_dir}/wig_sashimi.xml
	echo '<Resources>' >> ${out_dir}/wig_sashimi.xml
	for sample in `echo $samples | tr ':' ' '`; do
		#echo -e "\t<Resource name=\"${sample}.bw\" path=\"${bigwigs}/${sample}.bw\" />" >> ${out_dir}/wig_session.xml
		echo -e "\t<Resource name=\"${sample}_junctions\" path=\"${junctions}/${sample}.junctions_sorted.bed\" />" >> ${out_dir}/wig_sashimi.xml
	done

	echo '</Resources>' >> ${out_dir}/wig_sashimi.xml
	echo '</Global>' >> ${out_dir}/wig_sashimi.xml
fi 

