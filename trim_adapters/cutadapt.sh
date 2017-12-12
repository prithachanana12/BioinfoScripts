R1=$1
R2=`echo $R1 | sed -e 's/R1/R2/g'`
input=
output=
/projects/bsi/bictools/apps/alignment/cutadapt/1.8.1/bin/cutadapt -m 32 -a AGATCGGAAGAGC -A AGATCGGAAGAGC -o $output/$R1 -p $output/$R2 $input/$R1 $input/$R2
