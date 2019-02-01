#!/bin/sh
##create master table from RNA variants and backfilled DNA variants 

if [ $# != 4 ]
then
        echo "Usage: get_read_support_RNA_DNA.sh samplename path_to_DNAvcf path_to_RNAvcf path_to_outfile"
        exit 1;
fi

set -x
echo `date`
sample=$1
dna=$2
rna=$3
outfile=$4

touch $outfile
if [ ! -s $outfile ]
then
	echo -e Sample'\t'Chr'\t'Pos'\t'Ref'\t'Alt'\t'Gene'\t'RNA-Ref'\t'RNA-Alt'\t'TumGT'\t'TumGQ'\t'TumDNA-Ref'\t'TumDNA-Alt'\t'NorGT'\t'NorGQ'\t'NorDNA-Ref'\t'NorDNA-Alt > $outfile
fi
tmp_dir=$(dirname $outfile)
cat $dna | grep -v ^# | cut -f2 > $tmp_dir/temp_pos.txt
for i in $(cat $tmp_dir/temp_pos.txt); do
	chr=$(cat $dna | grep -v ^# | grep -w $i | cut -f1)
	ref=$(cat $dna | grep -v ^# | grep -w $i | cut -f4)
	alt=$(cat $dna | grep -v ^# | grep -w $i | cut -f5)
	gene=$(cat $rna | grep -v ^# | grep -w $i | cut -f8 | tr ';' '\n' | grep SNPEFF_GENE_NAME | cut -f2 -d"=")
	rnaref=$(cat $rna | grep -v ^# | grep -w $i | cut -f10 | cut -f2 -d":" | cut -f1 -d",")
	rnaalt=$(cat $rna | grep -v ^# | grep -w $i | cut -f10 | cut -f2 -d":" | cut -f2 -d",")
	if [ $(cat $dna | grep -v ^# | grep -w $i | cut -f10) == "./." ]; then
		tumref=0
                tumalt=0
		tumgt="."
		tumgq="."
        else
		tumref=$(cat $dna | grep -v ^# | grep -w $i | cut -f10 | cut -f2 -d":" | cut -f1 -d",")
		tumalt=$(cat $dna | grep -v ^# | grep -w $i | cut -f10 | cut -f2 -d":" | cut -f2 -d",")
		tumgt=$(cat $dna | grep -v ^# | grep -w $i | cut -f10 | cut -f1 -d":")
		tumgq=$(cat $dna | grep -v ^# | grep -w $i | cut -f10 | cut -f4 -d":")	
	fi
	if [ $(cat $dna | grep -v ^# | grep -w $i | cut -f11) == "./." ]; then
		norref=0
		noralt=0
		norgt="."
		norgq="."
	else
		norref=$(cat $dna | grep -v ^# | grep -w $i | cut -f11 | cut -f2 -d":" | cut -f1 -d",")
		noralt=$(cat $dna | grep -v ^# | grep -w $i | cut -f11 | cut -f2 -d":" | cut -f2 -d",")
		norgt=$(cat $dna | grep -v ^# | grep -w $i | cut -f11 | cut -f1 -d":")
		norgq=$(cat $dna | grep -v ^# | grep -w $i | cut -f11 | cut -f4 -d":")
	fi
	echo -e $sample'\t'$chr'\t'$i'\t'$ref'\t'$alt'\t'$gene'\t'$rnaref'\t'$rnaalt'\t'$tumgt'\t'$tumgq'\t'$tumref'\t'$tumalt'\t'$norgt'\t'$norgq'\t'$norref'\t'$noralt >> $outfile
done
rm $tmp_dir/temp_pos.txt
