library(gplots)
expression<-read.table("pseudocounts.txt",sep="\t",header=T,stringsAsFactor=F,row.names=1)
png("heatmap2.png",width=5120,height=3840,res=600)
tissue_color=c(rep("gray",11),"indianred","indianred","gray","indianred","indianred","gray","indianred","indianred","indianred","indianred","gray","gray","indianred","gray","indianred","indianred","indianred")
heatmap.2(log(1+as.matrix(expression[,1:28])),scale="row",col="greenred",cexCol=1.0,trace="none",margins=c(5,10),density.info="none",ColSideColors=tissue_color,labRow=NA)

par(lend = 1)           # square line ends for the color legend
legend("topright",      # location of the legend on the heatmap plot
    legend = c("Bone Marrow", "Peripheral blood"), # category labels
    col = c("gray", "indianred"),  # color key
    lty= 1,             # line style
    lwd = 7            # line width
)

dev.off()

expression<-read.table("counts.bm.txt",sep="\t",header=T,stringsAsFactor=F,row.names=1)
png("heatmap.bm.png",width=5120,height=3840,res=600)

heatmap.2(log(1+as.matrix(expression[,1:16])),scale="row",col="greenred",cexCol=1.0,trace="none",margins=c(5,10),density.info="none",labRow=NA)

dev.off()

expression<-read.table("counts.bm_mut.txt",sep="\t",header=T,stringsAsFactor=F,row.names=1)
#png("heatmap.bm_mut.png",width=5120,height=3840,res=600)

mut_color=c(rep("gray",11),"khaki","sienna","purple")

heatmap.2(log(1+as.matrix(expression[,1:14])),scale="row",col="greenred",cexCol=1.0,trace="none",margins=c(5,10),density.info="none",labRow=NA,ColSideColors=mut_color)

par(lend = 1)           # square line ends for the color legend
legend("topright",      # location of the legend on the heatmap plot
    legend = c("ASXL1", "TET2", "ASXL1+TET2", "No"), # category labels
    col = c("sienna", "khaki", "purple","gray"),  # color key
    lty= 1,             # line style
    lwd = 10            # line width
)



dev.off()






