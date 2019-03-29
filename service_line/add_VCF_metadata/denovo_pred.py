#!/usr/bin/python
##predicts whether each variant in VCF is denovo or not
##usage: python denovo_pred.py input_variants.vcf.gz output_file.vcf

import argparse
import gzip
import re


def trio(x,y,z):
	if x and y and z:
		return "its a trio"


def main(invcf,outvcf):
	f=open(outvcf,'w')

	proband=''
	mom=''
	dad=''
	denovo=-1
	
	with gzip.open(invcf,'r') as vcf:
		for line in vcf:
			if line.startswith("##"):
				f.write(line)
				if line.startswith("##PROBAND="):
					proband=line.rstrip().split("=")[1]
				elif line.startswith("##MOTHER="):
					mom=line.rstrip().split("=")[1]
				elif line.startswith("##FATHER="):
					dad=line.rstrip().split("=")[1]
			elif line.startswith("#CHROM"):
				if trio(proband,mom,dad):
					f.write("##INFO=<ID=DENOVO,Number=1,Type=Integer,Description=\"denovo status of variant\">\n")
				f.write(line)
				global pid
				global mid
				global did
				pid=line.rstrip().split("\t").index(proband)
				try:
					mid=line.rstrip().split("\t").index(mom)
				except:
					pass
				try:
					did=line.rstrip().split("\t").index(dad)
				except:
					pass
			else:
				if not trio(proband,mom,dad):
					f.write(line)
				else:
					pro_g=line.rstrip().split("\t")[pid].split(":")[0]
					mom_g=line.rstrip().split("\t")[mid].split(":")[0]
					dad_g=line.rstrip().split("\t")[did].split(":")[0]
					if re.match('0[/\|]1|1[/\|]0|1[/\|]1|\./1',pro_g) and re.match('0[/\|]0',mom_g) and re.match('0[/\|]0',dad_g):
						denovo=1
					elif re.match('0[/\|]0',pro_g) or (re.match('0[/\|]1|1[/\|]0|1[/\|]1|\./1|\./\.',pro_g) and (re.match('0[/\|]1|1[/\|]0|1[/\|]1|\./1',mom_g) or re.match('0[/\|]1|1[/\|]0|1[/\|]1|\./1',dad_g))):
						denovo=0
					elif re.match('0[/\|]1|1[/\|]0|1[/\|]1|\./1',pro_g) and re.match('\./[0\.]',mom_g) and re.match('\./[0\.]',dad_g):
						denovo=2
					elif re.match('0[/\|]1|1[/\|]0|1[/\|]1|\./1',pro_g) and re.match('\./[0\.]',mom_g) and re.match('0[/\|]0',dad_g):
						denovo=3
					elif re.match('0[/\|]1|1[/\|]0|1[/\|]1|\./1',pro_g) and re.match('0[/\|]0',mom_g) and re.match('\./[0\.]',dad_g):
						denovo=4
					elif re.match('\./[0\.]',pro_g) and re.match('0[/\|]0',mom_g) and re.match('0[/\|]0',dad_g):
						denovo=5
					part1='\t'.join(line.rstrip().split('\t')[0:7])
					part2=str(line.rstrip().split('\t')[7])+";"+"DENOVO="+str(denovo)
					part3='\t'.join(line.rstrip().split('\t')[8:len(line)-1])
					f.write(part1.rstrip('\n')+'\t'+part2.rstrip('\n')+'\t'+part3.rstrip()+'\n')

	f.close()
	vcf.close()			
				

if __name__ == "__main__":
	parser=argparse.ArgumentParser(description="This script adds denovo flag to each variant based on the genotypes of the proband, father and mother.")
	parser.add_argument("-i",metavar="input vcf.gz file output from add_metadata.sh")
        parser.add_argument("-o",metavar="output vcf file")
	args=parser.parse_args()
	
	main(args.i,args.o)

