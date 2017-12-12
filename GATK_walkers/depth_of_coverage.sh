#!/bin/sh

# run GATK DepthOfCoverage

if [ $# != 3 ]
then
	echo "Usage: <input bams (colon sep)> <output_file> <bed interval>"
	exit 1;
fi

set -x
echo `date`
input_bams=$1
output=$2
bed=$3
input="-I $(echo $input_bams | sed 's/:/ -I /g')"
gatk=/data5/bsi/bictools/alignment/gatk/3.3-0/GenomeAnalysisTK.jar
java=/usr/local/biotools/java/jdk1.7.0_67/bin/java
ref=/data2/bsi/reference/sequence/human/ncbi/37.1/indexed/allchr.fa

$java -Xmx14g -Xms14g -jar $gatk -T DepthOfCoverage -dt NONE -R $ref $input -o $output -L $bed --summaryCoverageThreshold 1 --summaryCoverageThreshold 5 --summaryCoverageThreshold 10 --summaryCoverageThreshold 15 --summaryCoverageThreshold 20 --summaryCoverageThreshold 25 --summaryCoverageThreshold 30 --summaryCoverageThreshold 40 --summaryCoverageThreshold 50 --summaryCoverageThreshold 75 --summaryCoverageThreshold 100 --summaryCoverageThreshold 200 --summaryCoverageThreshold 500 --summaryCoverageThreshold 1000 -omitBaseOutput -omitIntervals
echo `date`

