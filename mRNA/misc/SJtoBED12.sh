#!/bin/bash
##run from results directory
##Output BED file is sorted for indexing and loading into IGV
##awk for converting SJ.out.tab to bed12 format
##based on code originally published by frymor at http://seqanswers.com/forums/showthread.php?t=62896
if [ $# != 3 ];
then
        echo "usage: <input dir> <sample> <output_dir>";
else
        set -x
        in_dir=$1
        samp=$2
        out_dir=$3

for sj in ${in_dir}/${samp}/${samp}.SJ.out.tab
do
echo ${sj}
echo "Converting..."
awk \
{'if($4=="2") print ""$1"\t"$2-$9-1"\t"$3+$9"\tJUNC000"NR"\t"$8"\t-\t"$2-$9-1"\t"$3+$9"\t255,0,0\t2\t"$9","$9"\t","0,"$3-$2+$9+1; \
else \
if($4=="1") print ""$1"\t"$2-$9-1"\t"$3+$9"\tJUNC000"NR"\t"$8"\t+\t"$2-$9-1"\t"$3+$9"\t0,0,255\t2\t"$9","$9"\t","0,"$3-$2+$9+1'} \
${sj} > ${out_dir}/${samp}.bed12
echo "Sorting..."
sort -V -o ${out_dir}/${samp}.sort.bed ${out_dir}/${samp}.bed12
done
echo "Complete"
fi
