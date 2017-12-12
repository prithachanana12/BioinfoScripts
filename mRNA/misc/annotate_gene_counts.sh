in_file=$1
out_file=$2

echo -e `head -1 ${in_file}`"\t"Description"\t"Type > ${out_file}
cat ${in_file} | bior_lookup -d /data5/bsi/catalogs/bior/v1/hgnc/20160422_GRCh38/genes.v1/hgnc_complete_set_ensembl_gtf.tsv.bgz -c 3 -p symbol | bior_drill -p name | grep -v ^# | sort | uniq >> ${out_file}

