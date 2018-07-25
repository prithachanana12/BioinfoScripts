args =  commandArgs(TRUE)
fileName=args[1]
outfile=args[2]
samples=args[3]
if (file.exists(fileName) == FALSE){
  writeLines ("Script to generate barplots of RPKM for single genes.\nUsage:\nRscript barplot.R pathToRPKMmatrix pathTopngFile listOfColnamesToPlot\n");
  quit()
}

library(ggplot2)
library(reshape2)

dat <- read.table(fileName, header=TRUE, sep="\t", row.names=NULL)
cols_inc <- scan(samples,character())
#cols_inc

dat.subset <- dat[c("GeneName",cols_inc)] ##samples needed in barplot
#head(dat.subset)
melted.dat.subset <- melt(dat.subset)
#head(melted.dat.subset)
drops <- c("Chr","GeneID","Start","Stop","CodingLength") ##cols to be removed from main df
dat <- dat[,!names(dat) %in% drops] ##df with all samples and genename 

a <- quantile(dat[,-c(1,1)],c(0.50,0.75)) ##quantile numbers to add ablines to barplot later
a[[1]]
a[[2]]
dat.bars <- ggplot(data=melted.dat.subset, aes(x=variable,y=value))+geom_bar(stat="identity")+theme(axis.text.x = element_text(angle=90, vjust=1, hjust=1), axis.title.x=element_blank(), plot.title = element_text(hjust=0.5))+labs(y="RPKM") + ggtitle("LRRC15 expression") + geom_hline(yintercept=c(a[[1]],a[[2]]), linetype="dashed", color="red")
dat.bars
ggsave(outfile)
