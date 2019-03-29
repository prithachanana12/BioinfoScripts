args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript heatmap.R fileName path_to_outfile\n");
  quit()
}

data <- read.table(fileName, header=TRUE, sep="\t", row.names=NULL)
genes <- data$GeneID
#counts <- data[,-c(1,1)]
codlen <- data$CodingLength
drops <- c("Chr","GeneID","GeneName","Start","Stop","CodingLength") ##cols to be removed from main df
data <- data[,!names(data) %in% drops]
cS <- colSums(data)
#data <- apply(data,2,function(x) (x/sum(x))*1000000)
rpkm <- (10^9)*t(t(data/codlen)/cS)
write.table(rpkm,file=outFile,sep="\t", row.names=genes)
