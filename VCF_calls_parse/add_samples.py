#!/usr/bin/python
##adds two columns to info field of VCF - number of samples with the variant, and their names
##usage: python add_samples.py input_variants.vcf.gz output_file.vcf

import gzip
import sys

sample={}
last_col=[]
f=open(sys.argv[2],'w')
with gzip.open(sys.argv[1],'r') as vcf:
	for line in vcf:
		if line.startswith('##'):
			f.write(line)
		elif line.startswith('#CHROM'):
			#f.write(line.rstrip()+"\t"+"samples"+"\n")
			f.write(line)
			#print line
			samples=line.rstrip().split('\t')[9:len(line)-1]
			#print samples
			for i in range(1,len(samples)+1):
				#print i
				sample[i] = samples[i-1]
			#print sample				
		else:
			var=line.rstrip().split('\t')[9:len(line)-1]
			for genotype in var:
				if (not genotype.startswith('0/0')) and (not genotype.startswith('./.')) and (not genotype.startswith('./0')):
					last_col.append(sample[var.index(genotype)+1])
			pos=','.join(last_col)
			num_samples=len(pos.split(','))
			part1='\t'.join(line.rstrip().split('\t')[0:7])
			part2=str(line.rstrip().split('\t')[7])+';'+'samples='+pos+';'+'num_samples='+str(num_samples)
			part3='\t'.join(line.rstrip().split('\t')[8:len(line)-1])
			f.write(part1.rstrip('\n')+'\t'+part2.rstrip('\n')+'\t'+part3.rstrip()+'\n')
			#f.write(line.rstrip()+'\t'+pos+'\n')
			last_col=[]
f.close()
