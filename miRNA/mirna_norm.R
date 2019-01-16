args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript heatmap.R fileName path_to_outfile\n");
  quit()
}

data <- read.table(fileName, header=TRUE, sep="\t", row.names=1)
#counts <- data[,-c(1,1)]
data <- apply(data,2,function(x) (x/sum(x))*1000000)
write.table(data,file=outFile,sep="\t", row.names=TRUE)
