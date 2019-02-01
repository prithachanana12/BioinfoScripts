#!/bin/sh
##create bamlist input files for UG using DNA-RNA sample mapping file

if [ $# != 3 ]
then
        echo "Usage: map_samples.sh mapping_file.txt path_to_bamlist_dir path_to_exome_bams_dir"
        exit 1;
fi

set -x
echo `date`
map_file=$1
output=$2
bam_files=$3

dna=$(awk -F"\t" '{print $1}' $map_file)
rna=$(awk -F"\t" '{print $2}' $map_file)
N=$(echo $dna | wc -w)
for i in $(seq 1 $N); do 
	samp=$(echo $dna | cut -f $i -d" ")
	outfile=$(echo $rna | cut -f $i -d" ")
	ls ${bam_files}/${samp}*bam > ${output}/${outfile}.list
done
