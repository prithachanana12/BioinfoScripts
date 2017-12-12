#!/bin/sh
if [ $# != 1 ]
then
	echo "Usage:";
	echo "Please provide configuration file (include complete path)";
else
#	set -x
	echo `date`
	config=$1

	input_dir=$( cat $config | grep -w '^INPUT_DIR' | cut -d '=' -f2)
	output_dir=$( cat $config | grep -w '^OUTPUT_DIR' | cut -d '=' -f2)
	case_gene_list=$( cat $config | grep -w '^CLINICAL_GENE_LIST_CASE' | cut -d '=' -f2)
	control_gene_list=$( cat $config | grep -w '^CLINICAL_GENE_LIST_CONTROL' | cut -d '=' -f2)
	alias=$( cat $config | grep -w '^OUT_DIR_NAME' | cut -d '=' -f2)
	intron_len=$( cat $config | grep -w '^INTRON_LENGTH' | cut -d '=' -f2)
	supp_reads=$( cat $config | grep -w '^SUPPORTING_READS' | cut -d '=' -f2)
	exon_features_start_codon_list=$( cat $config | grep -w '^EXON_FEATURES_START_CODON' | cut -d '=' -f2)
	exon_features_stop_codon_list=$( cat $config | grep -w '^EXON_FEATURES_STOP_CODON' | cut -d '=' -f2)
	script_path=$( cat $config | grep -w '^SCRIPT_PATH' | cut -d '=' -f2)
	exon_start_list=$( cat $config | grep -w '^EXON_START_LIST' | cut -d '=' -f2)
	exon_end_list=$( cat $config | grep -w '^EXON_END_LIST' | cut -d '=' -f2)
	body_map_list=$( cat $config | grep -w '^FALSE_FUSIONS_LIST' | cut -d '=' -f2)
	sample=$( cat $config | grep -w '^SAMPLE_NAME' | cut -d '=' -f2)
	fusion_list=$( cat $config | grep -w '^PRIORITY_FUSIONS_LIST' | cut -d '=' -f2)
	sample_type=$( cat $config | grep -w '^SAMPLE_TYPE' | cut -d '=' -f2)
	bedtools=$( cat $config | grep -w '^BEDTOOLS' | cut -d '=' -f2)
	ref_genome=$( cat $config | grep -w '^REFERENCE_GENOME' | cut -d '=' -f2)
	exon_CDS_frame=$( cat $config | grep -w '^EXON_CDS_FRAME' | cut -d '=' -f2)


	mkdir $output_dir/$alias
	output_dir=$output_dir/$alias

echo "Reading in fusions ...";
	cat $input_dir/potential_fusion.txt | grep -A 2 $sample | sed 's/--//g'| awk NF | awk 'NR%3{printf $0" ";next;}1' | cut -f2,3,4,6,7,8,9,10,11,12,15 -d " " > $output_dir/$sample.potential_fusion.txt
	cat $output_dir/$sample.potential_fusion.txt | cut -f1,2,3,4,5,6,7 -d " " | tr " " "\t" | awk 'BEGIN{OFS="\t"}{print $1,($2+1),($3+1),$4,$5,$6,$7}'  > $output_dir/fusion_candidates

	# Gather 3 bases before and after the fusion breakpoint to avoid alignment artifacts, if any
	cat $output_dir/fusion_candidates | tr "-" "\t" | awk '{print $1"\t"($3-3)"\t"($3+3)"\t"$2"\t"($4-3)"\t"($4+3)"\t"$5"\t"$6"\t"$7"\t"$8}' > $output_dir/fusion_candidates.bedpe
echo "Overlapping fusions with Clinical Genes of interest ...";
	# Intersect with the clinical list of genes when either left and right ends overlap with the genes

	if [ $sample_type == 'control' ]
	then
		$bedtools/pairToBed -a $output_dir/fusion_candidates.bedpe -b $control_gene_list > $output_dir/$alias.overlap.bedpe
	else
		$bedtools/pairToBed -a $output_dir/fusion_candidates.bedpe -b $case_gene_list > $output_dir/$alias.overlap.bedpe
	fi

	# Format BEDPE results to report the gene-gene partners
	perl $script_path/get_gene_partners.pl $output_dir/$alias.overlap.bedpe $output_dir/$alias.overlap.formatted.bedpe
	rm $output_dir/$alias.overlap.bedpe
	mv $output_dir/$alias.overlap.formatted.bedpe $output_dir/$alias.overlap.bedpe
	# Intersect with the Exon list for all gemes to maks sure both breakpoints of the fusion lie on exons
	$bedtools/pairToBed -a $output_dir/$alias.overlap.bedpe -b $exon_start_list > $output_dir/$alias.exon_start.bedpe
	$bedtools/pairToBed -a $output_dir/$alias.overlap.bedpe -b $exon_end_list > $output_dir/$alias.exon_end.bedpe

echo "Obtaining exon annotations for genes involved in fusions ...";
	# Annotate the fusion breakpoints with exon-exon and exon-intron partners	
	perl $script_path/get_exon-exon_annotations.pl $output_dir/$alias.overlap.bedpe $output_dir/$alias.exon_start.bedpe $output_dir/$alias.exon_end.bedpe $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.txt $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Exon.txt $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Intron.txt 

	cat $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Exon.txt | grep -v "Read-Through" | grep -v "Homologs" >> $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Exon.fusion-candidates.txt
	# Annotate the Gene_Exon_Transcript_Annotation.All.txt file if the gene partners are observed in Body Map samples
echo "Searching for fusions reported in normal samples ...";
	perl $script_path/normal_fusion_database_annotation.pl $body_map_list $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.txt $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.BodyMapAnnot.txt

	# Calculate the frame for the 5' and 3' end of each fusion
echo "Calculating Reading Frame for all fusions ...";
	perl $script_path/frame_calculation.pl $exon_features_start_codon_list $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.BodyMapAnnot.txt $output_dir/$alias.fivePrime_Frame.txt $output_dir/$alias.threePrime_Frame.txt

	paste $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.BodyMapAnnot.txt $output_dir/$alias.fivePrime_Frame.txt $output_dir/$alias.threePrime_Frame.txt > $output_dir/$alias.tmp
	echo -e "Chr_5'\tCoordinate_5'\tChr_3'\tCoordinate_3'\tDistance_between_breakpoints\tSpanning\tSplit\tHybrid\tnon_supporting\t5'-3'Gene_Partners\tFusion_Location\tFusion_Annotation\tHuman_Tissues\tAverage_Expression\tTissue_Name\t5'_Exon_Annotation\t5'_Frame\t3'_Exon_Annotation\t3'_Frame" >> $output_dir/$alias.Final_Results.txt

	cat $output_dir/$alias.tmp | cut -f1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,18,19,20,21 | sed 's/~/|/g' >> $output_dir/$alias.Final_Results

	# Check for supporting reads and read-throughs
	cat $output_dir/$alias.Final_Results | awk '{if(($6+$7) >= '$supp_reads') print}' | awk '{ if($5 > '$intron_len')print}' >> $output_dir/$alias.confident.list

echo "Checking for fusions in the supplied priority list ...";
	# Check for any fusions that fall in the priority fusion list
	for i in `cat $fusion_list | grep -w $sample_type | cut -f1`; do cat $output_dir/$alias.Final_Results | grep -w $i >> $output_dir/priority; done
	cat $output_dir/$alias.confident.list >> $output_dir/$alias.Final_Results.txt

	# Add back the priority fusions that may have been filtered out by any of the filters
	perl $script_path/check_priority_fusions.pl $output_dir/priority $output_dir/$alias.confident.list >> $output_dir/$alias.Final_Results.txt
echo "Applying filter for supporting reads ...";
	cat $output_dir/$alias.Final_Results | awk '{if(($6+$7) >= '$supp_reads') print}' | awk 'BEGIN{OFS="_"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'|sort | uniq | tr "_" "\t" > $output_dir/filter1.supp_reads
echo "Applying filter for read-through events ...";
	cat $output_dir/$alias.Final_Results | awk '{if(($6+$7) >= '$supp_reads') print}' | awk '{ if($5 > '$intron_len')print}' | awk 'BEGIN{OFS="_"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'|sort | uniq | tr "_" "\t" > $output_dir/filter2.read_through_candidates
        cp $output_dir/$alias.Final_Results.txt $output_dir/$alias.for_numbers
        sed -i '1d' $output_dir/$alias.for_numbers
        cat $output_dir/$alias.for_numbers | grep -w "Exon-Exon_boundary" | awk 'BEGIN{OFS="_"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'|sort | uniq | tr "_" "\t" > $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Exon.tmp
        cat $output_dir/$alias.for_numbers | grep -w "Intron-Exon_boundary" | awk 'BEGIN{OFS="_"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'|sort | uniq | tr "_" "\t" >> $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Intron.tmp
        cat $output_dir/$alias.for_numbers | grep -w "Exon_boundary-Intron" | awk 'BEGIN{OFS="_"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'|sort | uniq | tr "_" "\t" >> $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Intron.tmp
        cat $output_dir/$alias.for_numbers | grep -w "Exon-Exon_boundary" | grep -w "Fusion-Candidate" | awk '{if ($13 ~ "-") print}' | awk 'BEGIN{OFS="_"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'|sort | uniq | tr "_" "\t" > $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.NotIn.BodyMap.txt

echo "Calculating Frame status for each fusion ...";
	# All frame combinations results
	perl $script_path/AllFrame_combinations.report.pl $output_dir/$alias.Final_Results.txt $output_dir/$alias.Final_Results.withFrame.txt
	# In-frame results
	cat $output_dir/$alias.Final_Results.withFrame.txt | grep -w "In-Frame" | grep -v "Read-Through" | awk 'BEGIN{OFS="_"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'|sort | uniq | tr "_" "\t" > $output_dir/$alias.In-Frame.results.tmp
	cat $output_dir/$alias.Final_Results.withFrame.txt | sed 's/~/|/g' >> $output_dir/$alias.frame.tmp
	mv $output_dir/$alias.frame.tmp $output_dir/$sample.All_Fusions.tmp

echo "Adding IGV links for visualization ...";
        # Prepare file for IGV visualization. This file will contain fusion candidates that have either 5' or 3' exon annotation, and both 5' and 3' exon annotation
	cp $output_dir/$sample.All_Fusions.tmp $output_dir/$sample.All_Fusions.viz.tmp
        perl $script_path/add_IGV_links.pl $output_dir/$sample.All_Fusions.viz.tmp $output_dir/$sample.All_Fusions.viz.tmp2
echo "Obtaining fusion sequence ...";
        # Obtain 5' and 3' sequence
	cat $output_dir/$sample.All_Fusions.viz.tmp2 | cut -f1,2,16 > $output_dir/$sample.5_prime.coor
	cat $output_dir/$sample.All_Fusions.viz.tmp2 | cut -f3,4,18 > $output_dir/$sample.3_prime.coor
        perl $script_path/check_seq.pl $output_dir/$sample.5_prime.coor $output_dir/$sample.3_prime.coor $exon_features_start_codon_list $output_dir/$sample.5_prime.coor.bed $output_dir/$sample.3_prime.coor.bed
	$bedtools/bedtools getfasta -fi $ref_genome -bed $output_dir/$sample.5_prime.coor.bed -name -s -fo $output_dir/$sample.5_prime.coor.fa -tab
	$bedtools/bedtools getfasta -fi $ref_genome -bed $output_dir/$sample.3_prime.coor.bed -name -s -fo $output_dir/$sample.3_prime.coor.fa -tab
	echo -e "Fusion_Sequence" > $output_dir/$sample.fusions.fa
	paste $output_dir/$sample.5_prime.coor.fa $output_dir/$sample.3_prime.coor.fa | cut -f2,4 | tr "\t" "-" >> $output_dir/$sample.fusions.fa
	paste $output_dir/$sample.All_Fusions.viz.tmp2 $output_dir/$sample.fusions.fa > $output_dir/$sample.All_Fusions.viz.seq.tmp
	# Add sequence for NA cases from input potential_fusion.txt file
	perl $script_path/add_NA_seq.pl $output_dir/$sample.All_Fusions.viz.seq.tmp $output_dir/$sample.potential_fusion.txt $output_dir/$sample.All_Fusions.viz.seq.txt potential

echo "Generating final reports and summary stats ...";
	# Re-format file for final report
	mkdir $output_dir/igv_tmp
	viz_dir=$output_dir/igv_tmp
	sed -i '1d' $output_dir/$sample.All_Fusions.viz.seq.txt

	echo -e "General_Information\t\t\t\t\tExon_Information\t\t\t\tRead_Information\t\t\t\tAdditional_Information\t\t\t\tFusion_coordinates" > $output_dir/$sample.All_Fusions.xls
	echo -e "5'-3'Gene_Partners\tFusion_Location\tFrame_Status\tIGV_link\tFusion_Sequence\t5'_Exon_Annotation\t5'_Frame\t3'_Exon_Annotation\t3'_Frame\tSpanning\tSplit\tHybrid\tNon_supporting\tFusion_Annotation\tHuman_Tissues\tAverage_Expression\tTissue_Name\tChr_5'\tCoordinate_5'\tChr_3'\tCoordinate_3'\tDistance_between_breakpoints" >> $output_dir/$sample.All_Fusions.xls
	echo -e "5'-3'Gene_Partners\tFusion_Location\tFrame_Status\tIGV_link\tFusion_Sequence\t5'_Exon_Annotation\t5'_Frame\t3'_Exon_Annotation\t3'_Frame\tSpanning\tSplit\tHybrid\tNon_supporting\tFusion_Annotation\tHuman_Tissues\tAverage_Expression\tTissue_Name\tChr_5'\tCoordinate_5'\tChr_3'\tCoordinate_3'\tDistance_between_breakpoints" > $viz_dir/$sample.Annotated_Fusions_for_visualization.tmp

	cat $output_dir/$sample.All_Fusions.viz.seq.txt | awk 'BEGIN{OFS="\t"}{print $10,$11,$20,$21,$22,$16,$17,$18,$19,$6,$7,$8,$9,$12,$13,$14,$15,$1,$2,$3,$4,$5}' > $output_dir/$sample.del
	cat $output_dir/$sample.del | awk '{if (match($18,$20))print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t-"}' >> $output_dir/$sample.All_Fusions.xls
	cat $output_dir/$sample.del | awk '{if (match($18,$20))print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t-"}' >> $viz_dir/$sample.Annotated_Fusions_for_visualization.tmp
	head -2 $output_dir/$sample.All_Fusions.xls > $output_dir/$sample.In-Frame_Fusions.xls
	cat $output_dir/$sample.All_Fusions.xls | grep -w "In-Frame" >> $output_dir/$sample.In-Frame_Fusions.xls
	cat $output_dir/$sample.All_Fusions.xls | grep -w "Exon-Exon_boundary" | grep -w "Promoter_Swap" >> $output_dir/$sample.In-Frame_Fusions.xls
	
	## Get frame of exon involved in fusion, also find their distance from the Start and Stop codons
	perl $script_path/start_codon_status.pl $output_dir/$sample.5_prime.coor.bed $exon_features_start_codon_list $exon_features_stop_codon_list $exon_CDS_frame $viz_dir/$sample.5_prime.start_codon_status
	perl $script_path/stop_codon_status.pl $output_dir/$sample.3_prime.coor.bed $exon_features_stop_codon_list $exon_features_start_codon_list $exon_CDS_frame $viz_dir/$sample.3_prime.stop_codon_status
	paste $viz_dir/$sample.Annotated_Fusions_for_visualization.tmp $viz_dir/$sample.5_prime.start_codon_status $viz_dir/$sample.3_prime.stop_codon_status > $viz_dir/$sample.Fusions_for_visualization.txt

	# Report number of candidates at each filter
	truncate -s 0 $output_dir/$sample.summary.txt
	echo -e "Number of Potential Fusions" >> $output_dir/$sample.summary.txt
	cat $output_dir/$sample.potential_fusion.txt | wc -l >> $output_dir/$sample.summary.txt
        echo -e "Number of Fusions that overlap the clinical genes of interest" >> $output_dir/$sample.summary.txt
        cat $output_dir/$alias.overlap.bedpe | wc -l >> $output_dir/$sample.summary.txt
	echo -e "Number of Fusions after filtering for supporting reads" >> $output_dir/$sample.summary.txt
	cat $output_dir/filter1.supp_reads | wc -l >> $output_dir/$sample.summary.txt
	echo -e "Number of Fusions after filtering for read-through events" >> $output_dir/$sample.summary.txt
	cat $output_dir/filter2.read_through_candidates | wc -l >> $output_dir/$sample.summary.txt
	echo -e "Number of Fusions at  Exon-Intron junctions" >> $output_dir/$sample.summary.txt
	cat $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Intron.tmp | wc -l >> $output_dir/$sample.summary.txt
        echo -e "Number of Fusions at Exon-Exon junctions" >> $output_dir/$sample.summary.txt
        cat $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Exon.tmp | wc -l >> $output_dir/$sample.summary.txt
	echo -e "Number of Exon-Exon junction Fusions not found in 16 Normal Tissues" >> $output_dir/$sample.summary.txt
	cat $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.NotIn.BodyMap.txt | wc -l >> $output_dir/$sample.summary.txt
	echo -e "Number of Fusions that are Exon-Exon and In-Frame" >> $output_dir/$sample.summary.txt
	cat $output_dir/$alias.In-Frame.results.tmp | wc -l >> $output_dir/$sample.summary.txt
	
	# remove temp files
	rm $output_dir/$sample.potential_fusion.txt $output_dir/filter1.supp_reads $output_dir/filter2.read_through_candidates $output_dir/$alias.overlap.bedpe $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.txt $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Exon.txt $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Intron.txt $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Exon.tmp $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Intron.tmp $output_dir/$alias.Gene_Exon_Transcript_Annotation.Exon-Exon.fusion-candidates.txt $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.BodyMapAnnot.txt $output_dir/$alias.In-Frame.results.tmp $output_dir/$alias.exon_start.bedpe $output_dir/$alias.exon_end.bedpe $output_dir/$alias.fivePrime_Frame.txt $output_dir/$alias.threePrime_Frame.txt $output_dir/$alias.tmp $output_dir/fusion_candidates.bedpe $output_dir/$alias.Gene_Exon_Transcript_Annotation.All.NotIn.BodyMap.txt $output_dir/$alias.Final_Results $output_dir/$alias.confident.list $output_dir/priority $output_dir/fusion_candidates $output_dir/$alias.for_numbers $output_dir/$alias.Final_Results.txt $output_dir/$alias.Final_Results.withFrame.txt $output_dir/$sample.5_prime.coor.bed $output_dir/$sample.3_prime.coor.bed $output_dir/$sample.5_prime.coor.fa $output_dir/$sample.3_prime.coor.fa $output_dir/$sample.fusions.fa $viz_dir/$sample.Annotated_Fusions_for_visualization.tmp $viz_dir/$sample.5_prime.start_codon_status $viz_dir/$sample.3_prime.stop_codon_status $output_dir/$sample.All_Fusions.viz.seq.txt $output_dir/$sample.All_Fusions.viz.tmp $output_dir/$sample.All_Fusions.viz.tmp2 $output_dir/$sample.All_Fusions.tmp $output_dir/$sample.del $output_dir/$sample.5_prime.coor $output_dir/$sample.3_prime.coor $output_dir/$sample.All_Fusions.viz.seq.tmp
echo "DONE"; 

fi
