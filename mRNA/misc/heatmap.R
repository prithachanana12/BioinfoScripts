args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
sampleInfo=args[3]
if (file.exists(fileName) == FALSE || length(args) < 3){
  writeLines ("Usage:\nRscript heatmap.R fileName path_to_outfile(*.tiff) sampleInfoFile\n\nsampleInfo format(tab-separated values,same order as in fileName)\nSample'\\t'Group\nsampleID1'\\t'groupID1\nsampleID2'\\t'groupID2\n");
  quit()
}

#Rowv="none" if clustering and re-ordering of genes is not required; this overrides the dendrogram option, dendrogram will not be created
#cexCol/cexRow adjust height of row and column labels

library(gplots)
#library(RColorBrewer)

expression <- read.table(fileName,sep="\t",header=T,stringsAsFactor=F,row.names=1)
#ncol(expression)
samp.groups <- read.table(sampleInfo,sep="\t",header=T)
#pdf("/data2/bsi/secondary/Khazaie_Khashayarsha_m123285/mrnaseq/KLF11-10_Apr17/heatmaps/th17_all.pdf",width=6,height=7,bg="gray")
tiff(outFile,compression="lzw",units="in",width=10,height=13,res=800)
#heatmap.2(as.matrix(log2(expression+1)),scale="none",Rowv="none",col="greenred",trace="none",margins=c(3,5),dendrogram="none",density.info="histogram",cexCol=1.2,cexRow=0.8)
#grp_colors=c(rep("sienna",3),rep("thistle4",3),rep("palevioletred4",3),rep("skyblue4",3),rep("slateblue4",3),rep("seagreen4",3))
#groups <- factor(samp.groups$Group)
#length(samp.groups$Group)
vals<-heatmap.2(as.matrix(log2(expression+0.001)),scale="row",col="greenred",trace="none",margins=c(3,4),density.info="histogram",labRow=FALSE,cexCol=0.8,srtCol=45,dendrogram="col",ColSideColors=as.character(as.numeric(samp.groups$Group)))
par(lend = 1)           # square line ends for the color legend
legend(0.8, 1,      # location of the legend on the heatmap plot
    legend = unique(samp.groups$Group), # category labels
    col = unique(as.numeric(samp.groups$Group)),  # color key
    lty= 1,             # line style
    lwd = 10            # line width
)
dev.off()
gene.order.cluster <- log2(expression+0.001)[rev(vals$rowInd),vals$colInd]
write.table(gene.order.cluster,"genes_order.txt",quote=F,sep="\t")
