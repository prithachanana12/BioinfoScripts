#!/usr/bin/python

import argparse

def main(in_fuse,out):
	samples={}
	genes={}
	g_s={}
	f=open(in_fuse,"r")
	for line in f:
		if line.split("\t")[1] not in g_s:
			g_s[line.split("\t")[1]]=[line.split("\t")[0]]
		elif line.split("\t")[1] in g_s and line.split("\t")[0] not in g_s[line.split("\t")[1]]:
			g_s[line.split("\t")[1]].append(line.split("\t")[0])
		if line.split("\t")[4] not in g_s:
                        g_s[line.split("\t")[4]]=[line.split("\t")[0]]
                elif line.split("\t")[4] in g_s and line.split("\t")[0] not in g_s[line.split("\t")[4]]:
                        g_s[line.split("\t")[4]].append(line.split("\t")[0])
		if line.split("\t")[0] not in samples:
			samples[line.split("\t")[0]]=1
			genes[line.split("\t")[0]]={}
			genes[line.split("\t")[0]][line.split("\t")[1]]=1
			genes[line.split("\t")[0]][line.split("\t")[4]]=1
		else:
			samples[line.split("\t")[0]]+=1
			if line.split("\t")[1] in genes[line.split("\t")[0]]:
				genes[line.split("\t")[0]][line.split("\t")[1]]+=1
			else:
				genes[line.split("\t")[0]][line.split("\t")[1]]=1
			if line.split("\t")[4] in genes[line.split("\t")[0]]:
                                genes[line.split("\t")[0]][line.split("\t")[4]]+=1
                        else:
                                genes[line.split("\t")[0]][line.split("\t")[4]]=1
	out_summary=out+".fusion_summary.txt"
	out_genes=out+".fusion_genes.txt"
	gene_stats=out+".gene_summary.txt"
	fo1=open(out_summary,"w")
	fo1.write("Sample"+"\t"+"TotalFusions"+"\n")
	fo2=open(out_genes,"w")
	fo2.write("Sample"+"\t"+"Gene"+"\t"+"Occurences"+"\n")
	fo3=open(gene_stats,"w")
	fo3.write("Gene"+"\t"+"NumSamples"+"\n")
	for key in samples:
		fo1.write(key+"\t"+str(samples[key])+"\n")
	for s in genes:
		for g in genes[s]:
			fo2.write(s+"\t"+g+"\t"+str(genes[s][g])+"\n")
	for gene in g_s:
		fo3.write(gene+"\t"+str(len(g_s[gene]))+"\n")
	fo1.close()
	fo2.close()
	fo3.close()

if __name__ == "__main__":
	parser=argparse.ArgumentParser(description="Calculates frequency of fusions per-gene per-sample")
	parser.add_argument("-i",metavar="result.txt from fusion directory of MAPRseq")
	parser.add_argument("-o",metavar="path to output file basename")
	args=parser.parse_args()
	main(args.i,args.o)
