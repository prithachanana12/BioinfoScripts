#~~~xenome synopsis~~~~
# xenome index -T 8 -P idx -H mouse.fa -G human.fa
# xenome classify -T 8 -P idx —pairs —host-name mouse —graft-name human -i in_1.fastq -i in_2.fastq
#~~~xenome synopsis~~~~
# run this from directory with input samples - so that script can recognize wildcards if looped for several samples 

#!/bin/sh

if [ $# != 5 ]
then	
    echo "Usage: <input dir> <R1 fastq name> <R2 fastq name> <sample name> <output dir>";
else
    set -x
    echo `date`	
	input=$1
	R1=$2
	R2=$3
	sample=$4
	out_dir=$5
	index=/data2/bsi/secondary/Urrutia_Raul_rxu01/config/tmp_fastq/xenome/index/
	HumanReference=/data2/bsi/reference/sequence/human/ncbi/hg19/indexed/allchr.fa
	MouseReference=/data2/bsi/reference/sequence/mouse/ncbi/mm10/genome.fa
	xenome=/projects/bsi/bictools/apps/alignment/xenome/1.0.1-r/
	
	mkdir $out_dir/$sample
	
	output=$out_dir/$sample
#	logs=$input/logs
	mkdir $output/tmp
	
	# To generate the indexes using the human and mouse reference genomes. This is a one time job. Once the indexes are created, the xenome classify command can be run on all the samples.
	#qsub -wd $logs -b y -q lg-mem -l h_vmem=24G -l h_stack=10M -m ae -M chanana.pritha@mayo.edu -pe threaded 16 $xenome/xenome index -P $index/index -H $MouseReference -G $HumanReference --tmp-dir $input/tmp
	cd $output
	qsub -wd $output -b y -q lg-mem -l h_vmem=5G -l h_stack=10M -m a -M chanana.pritha@mayo.edu -N classify_$sample -pe threaded 8 $xenome/xenome classify -T 8 -M 20 -P $index/index --pairs -i $input/$R1 -i $input/$R2 --tmp-dir $output/tmp --graft-name human --host-name mouse --output-filename-prefix $sample 

fi
