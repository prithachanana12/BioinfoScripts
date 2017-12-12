#!/usr/bin/python

import argparse

def main(in_bed,out_bed):
	genes={}
	for line in in_bed:
		if line.split("\t")[3] not in genes:
			genes[line.split("\t")[3]]=[line.split("\t")[0]]
			genes[line.split("\t")[3]].append(line.split("\t")[1])
			genes[line.split("\t")[3]].append(line.split("\t")[2])
		else:
			line_min=int(line.split("\t")[1])
			gene_min=int(genes[line.split("\t")[3]][1])
			line_max=int(line.split("\t")[2])
			gene_max=int(genes[line.split("\t")[3]][2])
			if line_min < gene_min:
				genes[line.split("\t")[3]][1]=line.split("\t")[1]
			if line_max > gene_max:
				genes[line.split("\t")[3]][2]=line.split("\t")[2]
	out_f=open(out_bed,"w")
	for gene in genes:
		out_f.write(genes[gene][0]+"\t"+genes[gene][1]+"\t"+genes[gene][2]+"\t"+gene+"\n")

if __name__ == "__main__":
	parser=argparse.ArgumentParser(description="process exon bed file to get Gene start and stop coords.")
	parser.add_argument("-i",metavar="input bed file")
	parser.add_argument("-o",metavar="output bed file with path")
	args=parser.parse_args()
	with open(args.i) as f:	
		main(f,args.o)
