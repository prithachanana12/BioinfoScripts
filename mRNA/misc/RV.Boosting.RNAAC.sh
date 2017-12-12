#!/bin/bash

#  RV.Boosting.sh
#  
#
#  Created by M078940 on 3/3/14.
#

function check_variable()	{
    message=$1
    if [[ "$2" == "" ]]
    then
        echo "$message is not set correctly."
        exit 1
    fi
}

####################
## Script Options ##
####################
usage ()
{
cat << EOF
######################################################################
##	wrapper script to run the RV.Boosting method
##	if the DNA BAM file is provided then it will backfill all the raw calls from DNA bam file
##	If capture kit is porvided then it will run the variant calling on that region otherwise whole coding region will be used
##	if you want to run the script on cluster then you need to run as using these memory requirements 
##	qsub -cwd -q 7-days -pe threaded 2 -l h_stack=10M -l h_vmem=8G 
##
## Script Options:
##	-R  <RNA bam>   -   (REQUIRED)	/path/to/input directory of the input RNA BAM file; BAM file should be sorted and Read Group Information should be available in it.
##	-s  <samplename>    -   (REQUIRED)	sample Name
##	-c  <config file>   -   (REQUIRED)	/full path/to configuration file
##	-o  <output_dir>    -   (REQUIRED)	/full path/to output dir
##	-D  <DNA bam>   -   /path/to/input directory of the DNA BAM file for the same sample
##	-b  <bed_file>  -   /path/to/capture BED file for DNA sample
##  	-T  <threads>   -   number of threads (default 1)
##	-d  <debug mode>    -   if this flag is passed then temporary files will be kept at each step
##	-h			-	Display this usage/help text (No arg)
#############################################################################
##
## Authors:             Saurabh Baheti
## Creation Date:       March 03 2014
## Last Modified:       May 16 2014
##
## For questions, comments, or concerns, contact Saurabh (baheti.saurabh@mayo.edu)
##
#################################################################################################################
EOF
}
echo "Options specified: $@"

while getopts "R:s:o:c:D:b:T:dh" OPTION; do
    case $OPTION in
        D) dna_bam=$OPTARG ;;
        T) threads=$OPTARG ;;
        b) range=$OPTARG ;;
        d) debug="YES";;
        h) usage
        exit ;;
        R) rna_bam=$OPTARG ;;
        s) sample=$OPTARG ;;
        o) output=$OPTARG ;;
        c) config=$OPTARG ;;
        \?) echo "Invalid option: -$OPTARG. See output file for usage." >&2
            usage
            exit ;;
        :) echo "Option -$OPTARG requires an argument. See output file for usage." >&2
            usage
            exit ;;
    esac
done

if [ -z "$rna_bam" ] || [ -z "$sample" ] || [ -z "$config" ] ;
then
    echo "Must provide at least required options. See output file for usage." >&2
    usage
    exit 1;
fi

#set -x
START=$(date +%s)
echo -e "\n Started the process .... "

if [ ! -d $output ]; then echo -e "creating the output directory : $output"; mkdir $output; fi

### check if output folder is having correct permisisons.
if [[ ! -r $output || ! -w $output || ! -x $output ]]
then
    echo -e "Read/write/execute access permission denied on $output Directory"
    exit 1;
fi
###check wether output directory is empty or not
if [[ "$(ls -A $output)" ]]; then echo -e "Directory : $output is not empty, please cleanup the diretcory and proceed"; exit 1; fi

##### make sure the config and bam file exist
if [ ! -s $config ]
then
	echo -e "configuration file : $config doesn't exist"
	exit 1;
fi
if [ ! -s $rna_bam ]
then
        echo -e "RNA bam file : $rna_bam doesn't exist"
        exit 1;
else
	if [ ! -s $rna_bam.bai ]
	then
		echo -e "Indexing the BAM file ...."
		SAMTOOLS=$( cat $config | grep -w '^SAMTOOLS' | cut -d '=' -f2)
		check_variable "$configo:SAMTOOLS" $SAMTOOLS
		$SAMTOOLS/samtools index $rna_bam
	fi 	
fi
### copying the config file to the user directory
cp $config $output/config.txt 
cat $output/config.txt | sed 's/^[ \t]*//;s/[ \t]*$//' > $output/config.txt.tmp
mv $output/config.txt.tmp $output/config.txt
config=$output/config.txt

### getting parameters from the configuration file
JAVA=$( cat $config | grep -w '^JAVA' | cut -d '=' -f2)
check_variable "$config:JAVA" $JAVA
PERL=$( cat $config | grep -w '^PERL' | cut -d '=' -f2)
check_variable "$config:PERL" $PERL
#SNPir_SCRIPTS=$( cat $config | grep -w '^SNPir_SCRIPTS' | cut -d '=' -f2)
#check_variable "$configo:SNPir_SCRIPTS" $SNPir_SCRIPTS
MAYO_scripts=$( cat $config | grep -w '^RVboost_scripts' | cut -d '=' -f2)
check_variable "$config:RV-Boost_scripts" $MAYO_scripts
GATK=$( cat $config | grep -w '^GATK' | cut -d '=' -f2)
check_variable "$config:GATK" $GATK
BEDTOOLS=$( cat $config | grep -w '^BEDTOOLS' | cut -d '=' -f2)
check_variable "$config:BEDTOOLS" $BEDTOOLS
SNPEFF=$( cat $config | grep -w '^SNPEFF' | cut -d '=' -f2)
check_variable "$config:SNPEFF" $SNPEFF
RNAEDITTING=$( cat $config | grep -w '^RNAEDITTING' | cut -d '=' -f2)
check_variable "$config:RNAEDITTING" $RNAEDITTING
SAMTOOLS=$( cat $config | grep -w '^SAMTOOLS' | cut -d '=' -f2)
check_variable "$configo:SAMTOOLS" $SAMTOOLS
UnifiedGenotyper_params=$( cat $config | grep -w '^UnifiedGenotyper_params' |sed -e 's/UnifiedGenotyper_params=//g')
#VQSR_params=$( cat $config | grep -w '^VQSR_params' |sed -e 's/VQSR_params=//g')
#DBSNP_VCF=$( cat $config | grep -w '^DBSNP_VCF' | cut -d '=' -f2)
#check_variable "$config:DBSNP_VCF" $DBSNP_VCF
REF_GENOME=$( cat $config | grep -w '^REF_GENOME' | cut -d '=' -f2)
check_variable "$config:REF_GENOME" $REF_GENOME
#HAPMAP_VCF=$( cat $config | grep -w '^HAPMAP_VCF' | cut -d '=' -f2)
#check_variable "$config:HAPMAP_VCF" $HAPMAP_VCF
#OMNI_VCF=$( cat $config | grep -w '^OMNI_VCF' | cut -d '=' -f2)
#check_variable "$config:OMNI_VCF" $OMNI_VCF
CODING=$( cat $config | grep -w '^CODING' | cut -d '=' -f2)
check_variable "$config:CODING" $CODING
#RNAEDITTING=$( cat $config | grep -w '^RNAEDITTING' | cut -d '=' -f2)
#check_variable "$config:RNAEDITTING" $RNAEDITTING
BLAT=$( cat $config | grep -w '^BLAT' | cut -d '=' -f2)
check_variable "$config:BLAT" $BLAT
GENEBED=$( cat $config | grep -w '^GENEBED' | cut -d '=' -f2)
check_variable "$config:GENEBED" $GENEBED
#RMSK=$( cat $config | grep -w '^RMSK' | cut -d '=' -f2)
#check_variable "$config:RMSK" $RMSK
#GENEFILE=$( cat $config | grep -w '^GENEFILE' | cut -d '=' -f2)
#check_variable "$config:GENEFILE" $GENEFILE
R=$( cat $config | grep -w '^R=' | cut -d '=' -f2)
check_variable "$config:R" $R
HAPMAP=$( cat $config | grep -w '^HAPMAP' | cut -d '=' -f2)
check_variable "$config:HAPMAP" $HAPMAP
Rlib=$( cat $config | grep -w '^Rlib' | cut -d '=' -f2)
check_variable "$config:Rlib" $Rlib

### make sure the output diretcory is empty



if [ ! -d $output/temp ]; then mkdir $output/temp;fi

if [ ! -d $output/logs ]; then mkdir $output/logs;fi

### call the variants using GATK

if [ ! "$threads" ]
then
    let threads=1
fi
if [ "$range" ]
then
    UnifiedGenotyper_arguments="-nt $threads -L $range $UnifiedGenotyper_params"
else
    UnifiedGenotyper_arguments="-nt $threads -L $CODING -stand_call_conf 0 -stand_emit_conf 0 -dfrac 0.30"
fi
### checks to validate the BAM file
### sorted
### read group
### platform
SORT_FLAG=`$PERL $MAYO_scripts/checkBAMsorted.pl -i $rna_bam -s $SAMTOOLS`
if [ $SORT_FLAG != 1 ] 
then
	echo -e "RNA bam file : $rna_bam is not sorted, BAM file should be coordinate sorted to run the pipeline"
	exit 1;
fi 

RG_ID=`$SAMTOOLS/samtools view -H $rna_bam | grep "^@RG" | tr '\t' '\n' | grep "^ID"| cut -f 2 -d ":"`
if [ "$RG_ID" != "$sample" ]
then
    echo -e "RNA bam file : Read Group = $RG_ID which is different from sample name: $sample"
	exit 1;
fi

#### running GATK raw calling
echo " Running GATK for Variant calling on RNA BAM file ....."
# $JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx4g -Xms2g -Djava.io.tmpdir=$output/temp -jar $GATK/GenomeAnalysisTK.jar -T UnifiedGenotyper -I $rna_bam -D $DBSNP_VCF -o $output/$sample.raw.vcf -R $REF_GENOME $UnifiedGenotyper_arguments > $output/logs/UnifiedGenotyper.raw.log 2>&1
$JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx4g -Xms2g -Djava.io.tmpdir=$output/temp -jar $GATK/GenomeAnalysisTK.jar -T UnifiedGenotyper -I $rna_bam -o $output/$sample.raw.vcf -R $REF_GENOME $UnifiedGenotyper_arguments > $output/logs/UnifiedGenotyper.raw.log 2>&1
if [ $? -ne 0 ]; then echo -e "Unifiedgenotyper failed to run on RNA bam file,\n please check $output/logs/UnifiedGenotyper.raw.log"; exit 1;fi 
echo -e "ok"
### making all the filter fields as PASS
rm $output/$sample.raw.vcf.idx
cat $output/$sample.raw.vcf | awk '{if($0 !~/^#/){$7="PASS"}} 1' OFS="\t" FS="\t" > $output/tmp.vcf
mv $output/tmp.vcf $output/$sample.raw.vcf

#### ADD DJ to the vcf file
echo -e " Adding Distance to Junction to the VCF file from RNA BAM file ......"
$PERL $MAYO_scripts/get_exon_cvg.pl $GENEBED $output/$sample.raw.vcf $BEDTOOLS > $output/$sample.DJ.vcf
mv  $output/$sample.DJ.vcf $output/$sample.raw.vcf
echo -e "ok"
### ADD ED to the VCF file
echo -e " Adding Edit Distance (blat field) to the VCF file from RNA BAM file ......"
$PERL $MAYO_scripts/vcf_blat_verify.pl -i $output/$sample.raw.vcf -r $REF_GENOME -o $output/$sample.ED.vcf -w 50 -b $BLAT -sam $SAMTOOLS -br $REF_GENOME 
mv $output/$sample.ED.vcf $output/$sample.raw.vcf
echo -e "ok"
### add the flag to say if it is coding or not
echo -e " Adding Coding/NonCoding Flag to the VCF file from RNA BAM file ......"
$BEDTOOLS/intersectBed -a $output/$sample.raw.vcf -b $CODING -c -header | awk '{if($NF == 1) {$8= $8";CODING=1"} else if ($NF == 0){$8= $8";CODING=0"}} 1' OFS="\t" FS="\t" | awk 'BEGIN{FS=OFS="\t"}{if ($0 ~ /^#/){print } else {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}}' > $output/temp.vcf
echo -e "ok"
### fix the header issue
cat $output/temp.vcf | grep '##' > $output/$sample.header
cat $output/temp.vcf | grep -v '##' > $output/$sample.value

echo -e "##INFO=<ID=CODING,Number=1,Type=Integer,Description=\"Variant in Coding region\">" > $output/header
cat $output/$sample.header $output/header $output/$sample.value > $output/$sample.raw.vcf
rm $output/$sample.header $output/$sample.value $output/temp.vcf $output/header

### Run RV Boosting algorithm
echo -e "Run the RV-Boost algorithm to filter the variants ...."
$R/Rscript $MAYO_scripts/RVboost.R $output/$sample.raw.vcf $Rlib $MAYO_scripts $HAPMAP adaboost $output
cat $output/$sample.raw.vcf | grep '##' > $output/header
cat $output/$sample.raw.vcf | grep -v '##' | grep '#' > $output/chr
echo -e "##INFO=<ID=OrgScore,Number=1,Type=Float,Description=\"RV Boosting algorithm Original score\">" >> $output/header
echo -e "##INFO=<ID=QScore,Number=1,Type=Float,Description=\"RV Boosting algorithm Q-Score\">" >> $output/header

cat $output/original_score.txt | awk '{$1=sprintf ("%.5f", $1);print "OrgScore="$1}' > $output/original_score.txt.tmp
mv $output/original_score.txt.tmp $output/original_score.txt
cat $output/RV.Qscore.txt | awk '{$1=sprintf ("%.5f", $1);print "QScore="$1}' > $output/RV.Qscore.txt.tmp
mv $output/RV.Qscore.txt.tmp $output/RV.Qscore.txt

paste -d ";" $output/original_score.txt $output/RV.Qscore.txt  > $output/info.txt 
rm $output/original_score.txt $output/RV.Qscore.txt

cat $output/$sample.raw.vcf | grep -v '#' | paste - $output/info.txt | awk '{$8=$NF";"$8} 1' OFS="\t" IFS="\t" | cut -f 1-10 | cat $output/header $output/chr - > $output/$sample.filter.vcf
rm $output/header $output/chr $output/info.txt 
echo -e "ok"

echo -e "Run snpefff on the VCF file"
$JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx4g -Xms2g -Djava.io.tmpdir=$output/temp -jar $SNPEFF/snpEff.jar eff -o vcf -chr chr -noStats -noLog -c $SNPEFF/snpEff.config hg19 $output/$sample.filter.vcf | awk '{if ($0 ~ /##SnpEffVersion/) print "##SnpEffVersion=\"3.0c (build 2012-07-30), by Pablo Cingolani\""; else print $0;}' > $output/$sample.filter.eff.vcf

$JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx4g -Xms2g -Djava.io.tmpdir=$output/temp -jar $GATK/GenomeAnalysisTK.jar -T VariantAnnotator -R $REF_GENOME -A SnpEff --variant $output/$sample.filter.vcf --snpEffFile $output/$sample.filter.eff.vcf -L $output/$sample.filter.vcf -o $output/$sample.filter.annot.vcf > $output/logs/VariantAnnotator.SnpEff.log  2>&1
if [ $? -eq 0 ]; then rm $output/$sample.filter.eff.vcf;mv $output/$sample.filter.annot.vcf $output/$sample.filter.vcf;fi
rm $output/$sample.filter.eff.vcf.idx
rm $output/$sample.filter.annot.vcf.idx
echo -e "ok"
echo -e "Add RNA editing columns to the INFO fields"
$JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx4g -Xms2g -Djava.io.tmpdir=$output/temp -jar $GATK/GenomeAnalysisTK.jar -T VariantAnnotator -R $REF_GENOME -V $output/$sample.filter.vcf -L $output/$sample.filter.vcf --out $output/$sample.filter.edit.vcf -E RNAEDIT.ALU -E RNAEDIT.NON_ALU -E RNAEDIT.EDITING_LEVEL -resource:RNAEDIT $RNAEDITTING > $output/logs/VariantAnnotator.edit.log  2>&1

if [ $? -eq 0 ]; then mv $output/$sample.filter.edit.vcf $output/$sample.filter.vcf; fi
rm $output/$sample.filter.edit.vcf.idx
echo -e "ok"
rm $output/$sample.filter.vcf.idx
### add TRAIN flag to the VCF file
cat $output/$sample.filter.vcf | grep '##' > $output/header
cat $output/$sample.raw.vcf | grep -v '##' | grep '#' > $output/chr
echo -e "##INFO=<ID=TRAIN,Number=0,Type=Flag,Description=\"Variant in Training Set\">" >> $output/header
zcat $HAPMAP | awk -F ':' '{print $1"\t"$2-1"\t"$2}' | $BEDTOOLS/intersectBed -a $output/$sample.filter.vcf -b stdin -c | awk -F'\t' '{if ($NF==1) {$8="TRAIN;"$8}} 1' OFS="\t" IFS="\t" | cut -f 1-10 | cat $output/header $output/chr - > $output/$sample.filter.vcf.tmp.vcf 
rm $output/header $output/chr 
mv $output/$sample.filter.vcf.tmp.vcf $output/$sample.filter.vcf

$R/Rscript $MAYO_scripts/display.R $output/$sample.filter.vcf $Rlib $MAYO_scripts $output/$sample.png

###########################
###
### we can comment out this after testing is done
### saurabh baheti
#### added to test the SNPir strategy
#### running SNPir on the VCF file
#echo " Running the SNPir filtering on the VCF file ......"
#SNPir=$output/SNPir
#mkdir $SNPir

#echo "convert vcf format into custom SNPiR format and filter variants with quality <20 ....."
# $SNPir_SCRIPTS/convertVCF.sh $output/$sample.raw.vcf $SNPir/$sample.txt 20

#echo "filter mismatches at read ends ....."
# $PERL $SNPir_SCRIPTS/filter_mismatch_first6bp.pl -infile $SNPir/$sample.txt -outfile $SNPir/$sample.rmhex.txt -bamfile $rna_bam

#echo "filter variants in repetitive regions ....."
#awk '{OFS="\t";$2=$2-1"\t"$2;print $0}' $SNPir/$sample.rmhex.txt | $BEDTOOLS/intersectBed -a stdin -b $RMSK -v | cut -f1,3-7 > $SNPir/$sample.rmhex.rmsk.txt

#echo "filter intronic sites that are within 4bp of splicing junctions ....."
# $PERL $SNPir_SCRIPTS/filter_intron_near_splicejuncts.pl -infile $SNPir/$sample.rmhex.rmsk.txt -outfile $SNPir/$sample.rmhex.rmsk.rmintron.txt -genefile $GENEFILE

# echo "filter variants in homopolymers ....."
# $PERL $SNPir_SCRIPTS/filter_homopolymer_nucleotides.pl -infile $SNPir/$sample.rmhex.rmsk.rmintron.txt -outfile $SNPir/$sample.rmhex.rmsk.rmintron.homopoly.txt -refgenome $REF_GENOME

#echo "filter variants that were caused by mismapped reads ....."
# $PERL $SNPir_SCRIPTS/BLAT_candidates.pl -infile $SNPir/$sample.rmhex.rmsk.rmintron.homopoly.txt -outfile $SNPir/$sample.rmhex.rmsk.rmintron.homopoly.rmblat.txt -bamfile $rna_bam -refgenome $REF_GENOME

#echo "remove known RNA editing sites...."
#awk '{OFS="\t";$2=$2-1"\t"$2;print $0}' $SNPir/$sample.rmhex.rmsk.rmintron.homopoly.rmblat.txt | $BEDTOOLS/intersectBed -a stdin -b $RNAEDITTING -v > $SNPir/$sample.rmhex.rmsk.rmintron.homopoly.rmblat.rmedit.bed

# $BEDTOOLS/intersectBed -a $output/$sample.raw.vcf -b $SNPir/$sample.rmhex.rmsk.rmintron.homopoly.rmblat.rmedit.bed -header > $output/$sample.SNPir.filter.vcf
#######################
#########
### removing SNPir directory
# if [ ! "$debug" ]; then rm -Rf $SNPir; fi
################################
### Saurabh Baheti
### remove this part after evaluation
##########

### VQSR on the RAW VCF FILE
#export PATH=$R/$PATH
#echo "Running VQSR - VariantRecalibrator on the raw VCF file ...."
# $JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx10g -Xms5g -Djava.io.tmpdir=$output/temp -jar $GATK/GenomeAnalysisTK.jar -T VariantRecalibrator -R $REF_GENOME --input $output/$sample.raw.vcf -recalFile $output/temp/$sample.recal -tranchesFile $output/temp/$sample.tranches -rscriptFile $output/temp/$sample.R -resource:hapmap,known=false,training=true,truth=true,prior=15.0 $HAPMAP_VCF -resource:omni,known=false,training=true,truth=false,prior=12.0 $OMNI_VCF -resource:dbsnp,known=true,training=false,truth=false,prior=8.0 $DBSNP_VCF -mode SNP $VQSR_params > $output/logs/VariantRecalibrator.log 2>&1 
# if [ $? -ne 0 ]; then echo -e "VariantRecalibrator failed for $sample,\nplease check $output/logs/VariantRecalibrator.log"; exit 1;fi

# mv $output/temp/$sample.tranches.pdf $output/$sample.tranches.pdf
#echo "Applying VQSR - ApplyRecalibration on the raw VCF file ...."
# $JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx10g -Xms5g -Djava.io.tmpdir=$output/temp -jar $GATK/GenomeAnalysisTK.jar -T ApplyRecalibration -R $REF_GENOME --input $output/$sample.raw.vcf -mode SNP -recalFile $output/temp/$sample.recal -tranchesFile $output/temp/$sample.tranches -o $output/$sample.VQSR.vcf > $output/logs/ApplyRecalibration.log 2>&1 
#if [ $? -ne 0 ]; then echo -e "ApplyRecalibration failed for $sample,\nplease check $output/logs/ApplyRecalibration.log"; exit 1;fi

### backfill the VCF file

#if [ "$dna_bam" ]
#then
#	if [ ! -s $dna_bam ]; then echo -e "DNA bam file : $dna_bam doesn't exist"; exit 1;
#	else
#       	if [ ! -s $dna_bam.bai ]; then $SAMTOOLS/samtools index $dna_bam; fi
#fi
#    echo "Running Backfilling from DNA bam file on all the RAW variants ...."
  #  $JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx4g -Xms2g -Djava.io.tmpdir=$output/temp -jar $GATK/GenomeAnalysisTK.jar -T UnifiedGenotyper -I $dna_bam -L $output/$sample.raw.vcf -D $DBSNP_VCF -nt $threads --output_mode EMIT_ALL_SITES --genotyping_mode GENOTYPE_GIVEN_ALLELES -alleles $output/$sample.raw.vcf -o $output/$sample.dna.vcf -R $REF_GENOME $UnifiedGenotyper_params > $output/logs/UnifiedGenotyper.DNA.log 2>&1 
#	$JAVA -XX:CompileThreshold=1000 -XX:ReservedCodeCacheSize=128m -Xmx4g -Xms2g -Djava.io.tmpdir=$output/temp -jar $GATK/GenomeAnalysisTK.jar -T UnifiedGenotyper -I $dna_bam -L $output/$sample.raw.vcf -nt $threads --output_mode EMIT_ALL_SITES --genotyping_mode GENOTYPE_GIVEN_ALLELES -alleles $output/$sample.raw.vcf -o $output/$sample.dna.vcf -R $REF_GENOME $UnifiedGenotyper_params > $output/logs/UnifiedGenotyper.DNA.log 2>&1
#	if [ $? -ne 0 ]; then echo -e "unifiedGenotyper failed to backfill DNA variants,\n please check $output/logs/UnifiedGenotyper.DNA.log"; exit 1; fi
#fi

gzip $output/$sample.raw.vcf
gzip $output/$sample.filter.vcf

#if [ ! "$debug"  ]; then rm -Rf $output/temp; fi

#if [ ! "$debug"  ]; then rm -Rf $output/logs; fi

END=$(date +%s)
DIFF=$(( $END - $START ))
echo -e "RNA seq variant calling with filtering uisng RV-Boost v0.1 for $sample took $DIFF seconds"




