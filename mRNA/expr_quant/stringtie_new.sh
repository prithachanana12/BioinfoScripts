#! /usr/bin/env bash
#trap "exit 100; exit" ERR
####################
## Script Options ##
####################

set -x
ulimit -n 3000
usage ()
{
cat << EOF
######################################################################
##      StringTie wrapper for post-MAPRSeq processing
## Script Options:
##      -b      <path_to_input_BAM_dir>      -       (REQUIRED)      location of BAM folder from MAPRSeq
##      -s      <samples>      -    (REQUIRED)         colon separated list of samples
##	-g 	<reference GTF>		- (REQUIRED)  reference GTF 
##	-o	<outputDir>	- (REQUIRED)  path to output directory, should be writable by user	
##      -h      - Display this usage/help text (No arg)
#############################################################################
EOF
exit
}
echo "Options specified: $@"

while getopts "b:s:g:o:h" OPTION; do
    case $OPTION in
                b) bamDir=$OPTARG ;;
                s) samples=$OPTARG ;;
		g) refGTF=$OPTARG ;;
		o) outDir=$OPTARG ;;
        h) usage
                exit ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$refGTF" ] || [ ! -d "$bamDir" ] || [ ! -d "$outDir" ] || [ -z "$samples" ]; then
    usage
fi

	exec &> $outDir/logfile.txt
    	set -x
    	echo `date`

	stringtie=/data5/bsi/bictools/src/stringtie/1.3.3/
	email=`finger $USER | awk -F ';' '{print $2}' | head -n1`
	logs=$outDir/logs
	mkdir -p $logs
	hold_jobs=''
	for i in `echo $sample | tr ':' ' '`; do
	mkdir -p $out_dir/${i}
	/home/oge/ge2011.11/bin/linux-x64/qsub -N string_pass1_${i} -m a -M $email -q 1-day -l h_vmem=5G -l h_stack=10M -wd $logs -b y $stringtie/stringtie $bam/${i}/${i}.Aligned.sortedByCoord.out.bam -G $ref_gtf -l $i -o $out_dir/${i}/${i}.gtf
	hold_jobs+="string_pass1_${i},"
	echo $out_dir/${i}/${i}.gtf >> $out_dir/mergelist.txt
	done

	job_id=$(/home/oge/ge2011.11/bin/linux-x64/qsub -N string_merge -m a -M $email -hold_jid ${hold_jobs%?} -q 1-day -l h_vmem=5G -l h_stack=10M -wd $logs -terse -b y $stringtie/stringtie --merge -G $ref_gtf -o $out_dir/stringtie_merged.gtf $out_dir/mergelist.txt)
	
	for i in `echo $sample | tr ':' ' '`; do 
	/home/oge/ge2011.11/bin/linux-x64/qsub -N string_pass2_${i} -m a -M $email -wd $logs -q 1-day -l h_vmem=5G -l h_stack=10M -hold_jid $job_id -b y $stringtie/stringtie $bam/${i}/${i}.Aligned.sortedByCoord.out.bam -G $out_dir/stringtie_merged.gtf -e -B -l $i -o $out_dir/${i}/${i}_mergedTrans.gtf
	done


fi
