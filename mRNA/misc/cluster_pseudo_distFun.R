#use Rowv="none" if clustering and re-ordering of genes is not required; this overrides the dendrogram option, dendrogram will not be created
#cexCol/cexRow adjust height of row and column labels
##script calculates pseudo counts and  uses pearson coeff as distance function for heatmap

library(gplots)
library(edgeR)

normcounts <- function(counts.filter, group.names) {
  cds<-DGEList(counts=counts.filter,group=group.names)
  cds<-calcNormFactors(cds)
  cds<-estimateCommonDisp(cds)
  cds<-estimateTagwiseDisp(cds)
  pseudo.counts<-cds$pseudo.counts

  return (pseudo.counts)
}

##provide raw counts here - script will normalize and calculate pseudo counts
expression <- read.table("/data2/bsi/tertiary/Ordog_Tamas_m038357/mrna/160805-MS-TO/cluster/all/counts_heat.txt",sep="\t",header=T,stringsAsFactor=F,row.names=1)
#group.names=c(rep("DMSO.T1",3),rep("IM1000.T1",3),rep("IM125.T1",3),rep("DMSO.430",3),rep("IM1000.430",3),rep("IM50.430",3),rep("DMSO.48B",3),rep("IM1000.48B",3),rep("DMSO.48",3),rep("IM1000.48",3),rep("IM50.48",3),rep("DMSO.54",3),rep("IM1000.54",3),rep("DMSO.882",3),rep("IM1000.882",3),rep("IM500.882",3))
group.names=c(rep("grp1",9),rep("grp2",9),rep("grp3",6),rep("grp2",9),rep("grp3",6),rep("grp1",9))
pseudo.counts=normcounts(expression,group.names)
png("/data2/bsi/tertiary/Ordog_Tamas_m038357/mrna/160805-MS-TO/cluster/all/heatmap2.png",units="in",width=9,height=10,res=300)
distCor <- function(x) as.dist(1-cor(t(x)))
hclustAvg <- function(x) hclust(x, method="average")
tissue_color=c(rep("indianred",9),rep("skyblue",9),rep("yellowgreen",6),rep("skyblue",9),rep("yellowgreen",6),rep("indianred",9))
heatmap.2(pseudo.counts,scale="row",col=redgreen(75),trace="none",density.info="histogram",margins=c(7,5),cexCol=0.8,labRow="",dendrogram="both",ColSideColors=tissue_color,hclust=hclustAvg,distfun=distCor)

par(lend = 1)           # square line ends for the color legend
legend("topright",      # location of the legend on the heatmap plot
    legend = c("KIT+IM-", "KIT+IM+","KIT-IM+" ), # category labels
    col = c("indianred", "skyblue","yellowgreen"),  # color key
    lty= 1,             # line style
    lwd = 10            # line width
)

dev.off()

