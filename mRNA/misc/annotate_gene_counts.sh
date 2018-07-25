in_file=$1
out_file=$2

echo -e `head -1 ${in_file}`"\t"Description"\t"LocusGroup"\t"LocusType > ${out_file}
cat ${in_file} | bior_lookup -d /data5/bsi/catalogs/bior/v1/hgnc/20160422_GRCh37.p13/genes.v1/hgnc_complete_set_ensembl_gtf.tsv.bgz -c 3 -p symbol | bior_drill -p name -p locus_group -p locus_type | grep -v ^# | sort | uniq >> ${out_file}

