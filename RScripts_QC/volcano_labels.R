args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) < 2){
  writeLines ("Usage:\nRscript volcano.R fileName outFile_basename\n");
  quit()
}

library(ggplot2)
library(ggrepel)

dataset <- read.table(fileName, sep='\t', header=T)
#dataset$threshp <- as.factor(abs(dataset$logFC)>1.5 & dataset$PValue <= 0.05)
dataset$threshf <- as.factor(dataset$FDR <= 0.13)

#volcanop <- ggplot(data=dataset, aes(x=logFC, y=(-log10(PValue)), color=threshp))+ theme(legend.position = "none") + geom_point(alpha=0.4, size=1.75) + xlab("log 2 Fold Change") + ylab("-log10 p-value")
#ggsave(paste(outFile,"_pval.png",sep=""))

volcanof <- ggplot(data=dataset, aes(x=logFC, y=(-log10(FDR)), color=threshf))+ theme(legend.position = "none") + geom_point(alpha=0.4, size=1.75) + xlab("log 2 Fold Change") + ylab("-log10 FDR") + geom_text_repel(aes(label=ifelse(threshf==TRUE,as.character(Mature.ID),'')),size=2.5) + ylim(0,3)
ggsave(paste(outFile,"_fdr.png",sep=""))
