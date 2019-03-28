args =  commandArgs(TRUE)
fileName=args[1]
#outfile=args[2]

if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript spearman_rank_cor.R pathToinputFile\nInput file should be of the following format:\nCoord\tRPKM\tOutcome\tSample");
  quit()
}

#library(ggplot2)
#library(reshape2)
op <- options(warn = (-1))
mydat<-read.table(fileName,header=TRUE,sep="\t")
test.res <- cor.test(mydat$RPKM,mydat$Outcome,method="spearman")
test.res$p.value
test.res$estimate
