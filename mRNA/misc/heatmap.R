##scaling data (using z-score instead of rpkms)
##scale on rows(genes)[force each gene to have zero mean and std dev 1 thereby throwing away info about means and std. devs of genes] if difference between samples/groups needs to be seen
#do the same on cols instead if differences between genes are needed

##heatmap options
#use Rowv="none" if clustering and re-ordering of genes is not required; this overrides the dendrogram option, dendrogram will not be created
#cexCol/cexRow adjust height of row and column labels
library(gplots)
expression <- read.table("/data2/bsi/secondary/Khazaie_Khashayarsha_m123285/mrnaseq/KLF11-10_Apr17/heatmaps/tgfb_RPKM.txt",sep="\t",header=T,stringsAsFactor=F,row.names=1)
#pdf("/data2/bsi/secondary/Khazaie_Khashayarsha_m123285/mrnaseq/KLF11-10_Apr17/heatmaps/th17_all.pdf",width=6,height=7,bg="gray")
png("/data2/bsi/secondary/Khazaie_Khashayarsha_m123285/mrnaseq/KLF11-10_Apr17/heatmaps/tgfb_all.png",units="in",width=10,height=13,res=800,bg="gray")
##use log2 of rpkms if the rpkm range is too big and tightening is required
#heatmap.2(as.matrix(log2(expression+1)),scale="none",Rowv="none",col="greenred",trace="none",margins=c(3,5),dendrogram="none",density.info="histogram",cexCol=1.2,cexRow=0.8)
grp_colors=c(rep("sienna",3),rep("thistle4",3),rep("palevioletred4",3),rep("skyblue4",3),rep("slateblue4",3),rep("seagreen4",3))
heatmap.2(as.matrix(expression),scale="row",col="greenred",trace="none",margins=c(3,4),density.info="histogram",cexRow=1,cexCol=0.8,srtCol=45,dendrogram="both",ColSideColors=grp_colors)
par(lend = 1)           # square line ends for the color legend
legend(0.8, 1,      # location of the legend on the heatmap plot
    legend = c("Peri_WT", "Peri_klf11","Peri_klf10","Im_WT","Im_klf11","Im_klf10"), # category labels
    col = c("sienna","thistle4","palevioletred4","skyblue4","slateblue4","seagreen4"),  # color key
    lty= 1,             # line style
    lwd = 10            # line width
)
dev.off()
