#!/bin/bash

if [ $# != 3 ]
then 
	echo "USAGE: star_fusion.sh <sample> <in_dir> <out_dir>"
else
	set -x
	sample=$1
	inputDir=$2
	outputDir=$3
	logs=${outputDir}/log
	
	mkdir -p ${logs}

	export LD_LIBRARY_PATH=/data5/bsi/bictools/src/h5py/2.5.0/lib:/usr/local/biotools/misc/ver1/lib:/usr/local/biotools/hdf5/1.8.11/lib:/home/oge/ge2011.11/lib/linux-x64:/home/oge/ge2011.11/lib/linux-x64:/usr/local/biotools/subversion/1.7.4/lib:/usr/local/biotools/python/2.7.10/lib:

	export PERL5LIB=/data5/bsi/bictools/perl/perl5/lib/perl5:/data5/bsi/bictools/perl/perl5/lib/site_perl/5.16.2/x86_64-linux/

	export PATH=/usr/local/biotools/perl/5.16.2-centos6/bin/:$PATH

	qsub -N fusion_${sample} -m a -M chanana.pritha@mayo.edu -q 1-day -b y -l h_vmem=3G -l h_stack=10M -wd ${logs} /usr/local/biotools/perl/5.16.2-centos6/bin/perl /data5/bsi/bictools/src/STAR-Fusion/STAR-Fusion --genome_lib_dir /data2/bsi/staff_analysis/m081429/Hg19_CTAT_resource_lib -J ${inputDir}/Chimeric.out.junction --output_dir ${outputDir}/${sample}/

	echo `date`

fi 
