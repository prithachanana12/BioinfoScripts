#!/usr/bin/python
##convert stringtie GTF files to tab delimited files

import argparse
import os.path

def main(gtf,out_file):
	out_f=open(out_file,'w')
	out_f.write('Chr'+'\t'+'Start'+'\t'+'Stop'+'\t'+'GeneID'+'\t'+'TranscriptID'+'\t'+'FPKM'+'\t'+'TPM'+'\n')
	with open (gtf,'r') as f:
		for line in f:
			if (not line.startswith('#') and (line.split('\t')[2] == 'transcript')):
				coords=str(line.rstrip().split('\t')[0])+'\t'+str(line.rstrip().split('\t')[3])+'\t'+str(line.rstrip().split('\t')[4])
				gene_meta=str(line.rstrip().split('\t')[8].split(';')[0].split(' ')[1].strip('"'))+'\t'+str(line.rstrip().split('\t')[8].split(';')[1].split(' ')[2].strip('"'))+'\t'+str(line.rstrip().split('\t')[8].split(';')[-3].split(' ')[2].strip('"'))+'\t'+str(line.rstrip().split('\t')[8].split(';')[-2].split(' ')[2].strip('"'))
				out_f.write(coords.rstrip()+'\t'+gene_meta.rstrip()+'\n')
	out_f.close()
	f.close()
				

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("-g", metavar="GTF file from stringtie", required=True)
	parser.add_argument("-o", metavar="path to output directory", required=True)
	parser.add_argument("-s", metavar="sample name", required=True)
	args=parser.parse_args()
	out_file=os.path.join(args.o,str(args.s)+'_quant.txt')
	main(args.g,out_file)
