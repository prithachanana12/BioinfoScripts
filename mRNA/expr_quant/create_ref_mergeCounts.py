#!/usr/bin/python
##create ref file with Chr,Gene,start,stop for using with merge.expression.featureCounts.pl/merge.expression.htseq.pl
##usage: python create_ref_mergeCounts.py <feature_counts_file> <output_file>

import sys

f=open(sys.argv[2],'w')
with open(sys.argv[1],'r') as counts:
	for line in counts:
		if (not line.startswith('Geneid')) and (not line.startswith('#')):
			cols=line.rstrip().split('\t')
			chrom=cols[1].split(';')[0]
			start=cols[2].split(';')[0]
			stop=cols[3].split(';')[-1]
			#strand=cols[4].split(';')[0]
			f.write(str(chrom)+'\t'+cols[0]+'\t'+str(start)+'\t'+str(stop)+'\t'+str(cols[5])+'\n')

f.close()
counts.close()		
