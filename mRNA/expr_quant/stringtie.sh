#!/bin/sh

exec &> $4/logfile.txt
if [ $# != 4 ]
then
	echo -e "Usage: Run StringTie in batch mode\n StringTie.sh <path to BAM> <samples (colon separated)> <reference annotation file> <path to output directory>"
else
    set -x
    echo `date`
	bam=$1
	sample=$2
	ref_gtf=$3
	out_dir=$4

	stringtie=/data5/bsi/bictools/src/stringtie/1.3.3/
	email=`finger $USER | awk -F ';' '{print $2}' | head -n1`
	logs=$out_dir/logs
	mkdir -p $logs
	hold_jobs=''
	for i in `echo $sample | tr ':' ' '`; do
	mkdir -p $out_dir/${i}
	qsub -N string_pass1_${i} -m a -M $email -q 1-day -l h_vmem=5G -l h_stack=10M -wd $logs -b y $stringtie/stringtie $bam/${i}/${i}.Aligned.sortedByCoord.out.bam -G $ref_gtf -l $i -o $out_dir/${i}/${i}.gtf
	hold_jobs+="string_pass1_${i},"
	echo $out_dir/${i}/${i}.gtf >> $out_dir/mergelist.txt
	done

	job_id=$(qsub -N string_merge -m a -M $email -hold_jid ${hold_jobs%?} -q 1-day -l h_vmem=5G -l h_stack=10M -wd $logs -terse -b y $stringtie/stringtie --merge -G $ref_gtf -o $out_dir/stringtie_merged.gtf $out_dir/mergelist.txt)
	
	for i in `echo $sample | tr ':' ' '`; do 
	qsub -N string_pass2_${i} -m a -M $email -wd $logs -q 1-day -l h_vmem=5G -l h_stack=10M -hold_jid $job_id -b y $stringtie/stringtie $bam/${i}/${i}.Aligned.sortedByCoord.out.bam -G $out_dir/stringtie_merged.gtf -e -B -l $i -o $out_dir/${i}/${i}_mergedTrans.gtf
	done


fi
