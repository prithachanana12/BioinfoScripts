#!/bin/bash

if [ $# != 4 ]
then
	echo "USAGE: merge_novel_mirna.sh <samples (colon sep)> <flowcell> <input_dir> <output_dir>"
else 
	set -x
	samples=$1
	flowcell=$2
	input_dir=$3
	output_dir=$4
	bowtie_logs=/data2/bsi/secondary/Kennedy_Richard_rbk04/mirna/
	bedtools_path=/data5/bsi/bictools/alignment/bedtools/2.20.1/bin/
	script_path=/home/m088341/tmp_checkout/miRNA/tags/1.2
	tool_info=/home/m088341/tmp_checkout/miRNA/tags/1.2/config/tool_info_hg19.txt
	
	for sample in $(echo $samples | tr ":" " ")
	do
	
		# extract total reads for novel mirna normalization
        	total_reads=$(grep "reads processed:" ${bowtie_logs}/${flowcell}/bams/${sample}.bowtie.log | cut -d ":" -f2 | sed -e 's/^[ \t]*//')
        	echo -e "${sample}\t${total_reads}" >> ${output_dir}/tmp.total_read_stats.txt
	
		# extract novel miRNA
        	grep novel ${input_dir}/mirdeep2/${sample}/result_*.bed | cut -f4 | sed 's/novel://g' > $output_dir/tmp.$sample.novel.ids
        	grep -wf $output_dir/tmp.$sample.novel.ids $input_dir/mirdeep2/$sample/result_*.csv | awk -F"\t" -v sample=$sample '{split($17,coordinates,":"); split(coordinates[2],positions,"."); print coordinates[1]"\t"positions[1]"\t"positions[3]"\t"coordinates[3]"\t"sample"\t"$2"\t"$6"\t"$14"\t"$4}' >> $output_dir/all_samples.novel.bed
        	rm $output_dir/tmp.$sample.novel.ids
	
	done
	
	# merge novel miRNA
	cat $output_dir/all_samples.novel.bed | $bedtools_path/sortBed > $output_dir/all_samples.novel.bed.sort
	mv $output_dir/all_samples.novel.bed.sort $output_dir/all_samples.novel.bed
	/data2/bsi/staff_analysis/m088341/tmp/kennedy_novel_mirna/add_individual_scores/merge_novel_mirna.pl -i $output_dir/all_samples.novel.bed -o $output_dir/all_samples_novel_miRNA_merged.txt

	# add BLAST annotation columns
	$script_path/blast_mirna.sh $output_dir/all_samples_novel_miRNA_merged.txt $output_dir novel_miRNA_raw.xls $tool_info

	# normalize novel miRNA table
	$script_path/normalize_counts.pl -i $output_dir/novel_miRNA_raw.xls -r $output_dir/tmp.total_read_stats.txt -o $output_dir/novel_miRNA_norm.xls

fi


