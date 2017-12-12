#!/bin/sh

if [ $# != 2 ]
then 
	echo "USAGE: ./syn_fusions_QC.sh <path to process dir> <path to tmp dir>"
else 
	res_dir=$1
	tmp_dir=$2
	samples=$( cut -f1 -d"=" $res_dir/../config/sample_info.txt | tr '\n' ' ' )
	ref_fuse=/data2/bsi/staff_analysis/m133293/fusion_list.txt
	#if [ -f $tmp_dir/run_summary.txt ]
	#then 
	#	read -p "file run_summary.txt already exists at output location. Delete it? [y/n]" OPT
	#	if [ $OPT == "y" ]
	#	then
	#		rm $tmp_dir/run_summary.txt
	#	else
	#		echo "Rename file and try again."
	#		exit 1
	#	fi
	#fi
	for sample in $samples
	do
		##used unfiltered file because *.mayo file has the non_ref fusions filtered out
		cat $res_dir/Star_Fusion/${sample}/${sample}.star-fusion.fusion_candidates.final.abridged | grep -wf $ref_fuse > $tmp_dir/list_sample
		false_negs=$(expr $(wc -l $ref_fuse | cut -f1 -d" ") - $(wc -l $tmp_dir/list_sample | cut -f1 -d" "))
		##filter the raw file to calculate false positives
		cat $res_dir/Star_Fusion/${sample}/${sample}.star-fusion.fusion_candidates.final.abridged | grep -v INCL_NON_REF_SPLICE | awk -F"\t" '{if (($2 + $3)>4) print}' - > $tmp_dir/filter_fusions.txt
		false_pos=$(cat $tmp_dir/filter_fusions.txt | grep -vwf $ref_fuse | wc -l)
		num=$(expr $(wc -l $tmp_dir/list_sample | cut -f1 -d" ") \* 100 )
		den_sens=$(expr $(wc -l $tmp_dir/list_sample | cut -f1 -d" ") + $false_negs )
		den_pres=$(expr $(wc -l $tmp_dir/list_sample | cut -f1 -d" ") + $false_pos )
		sensitivity=$(expr $num / $den_sens)
		precision=$(expr $num / $den_pres)
		if [ "$(wc -l $tmp_dir/list_sample | cut -f1 -d" ")" == "$(wc -l $ref_fuse | cut -f1 -d" ")" ]
		then
			echo "sample $sample pass"
			echo "Its sensitivity is $sensitivity% and precision is $precision%"
		else
			echo "sample $sample failed. Check for $false_negs missing fusions."
			echo "Its sensitivity is $sensitivity% and precision is $precision%"
			echo "QC failed because $sample does not meet sensitivity and precision criteria."
			exit 1
		fi
	done 	
	rm $tmp_dir/list_sample
	rm $tmp_dir/filter_fusions.txt
fi
