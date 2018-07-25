args = commandArgs(TRUE)
phen_info = args[1]
input_dir = args[2]
pattern = args[3]

if (length(args) < 3){
  writeLines ("Please check arguments!\nUsage:\nRscript ballgown.R pheotypeData inputDir patternForSampleNames \n");
  quit()
}

#source("http://bioconductor.org/biocLite.R")
#biocLite("ballgown")
library(ballgown)
library(genefilter)
library(dplyr)

pheno_data = read.csv(phen_info)
#head(pheno_data)
bg = ballgown(dataDir = input_dir, samplePattern = pattern, pData = pheno_data, meas = "all")
bg_filt = subset(bg,"rowVars(texpr(bg,'FPKM'))>1",genomesubset=TRUE)
#head (bg_filt@structure)
#head(bg@dirs)
transcript_de = stattest (bg_filt, feature = "transcript", covariate = "group", getFC=TRUE, meas="FPKM")
transcript_de = data.frame(geneNames=ballgown::geneNames(bg_filt), geneIDs=ballgown::geneIDs(bg_filt), transcriptIDs=ballgown::transcriptIDs(bg_filt), transcript_de)
#head(transcript_de)

transcript_de=arrange(transcript_de,pval)
out_file=paste(input_dir,"transcript_DE.txt",sep="/")
write.table(transcript_de,file = out_file,sep = "\t",row.names=FALSE)
