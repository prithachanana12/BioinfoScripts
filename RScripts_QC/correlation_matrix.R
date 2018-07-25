args =  commandArgs(TRUE)
fileName=args[1]
outfile=args[2]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript correlation_matrix.R pathToRPKMmatrix pathTopngFile\n");
  quit()
}

library(ggplot2)
library(reshape2)

get_upper_tri <- function(cormat) {
   cormat[lower.tri(cormat)] <- NA
   return(cormat)
}

rpkms=read.table(fileName, header=TRUE, row.names=NULL, sep="\t")
rpkms.vals=rpkms[,-1]
rpkms.vals.scaled=sweep(rpkms.vals, 1, apply(rpkms.vals, 1, mean), '/')
#head(rpkms.vals)
head(rpkms.vals.scaled)

cormat=round(cor(rpkms.vals.scaled,method="spearman"),2)
upper_tri <- get_upper_tri(cormat)
#lower_tri
#head(cormat)
melted_cormat=melt(upper_tri, na.rm = TRUE)
#melted_cormat

heat <- ggplot(data=melted_cormat, aes(Var2, Var1, fill=value))+ geom_tile() + scale_fill_gradient2(low = "blue", high = "red", mid = "white" , midpoint = 0, limit=c(-1,1), space="Lab",name="Spearman Correlation") + coord_fixed() + theme(axis.text.x = element_text(angle=45, vjust=1, hjust=1), axis.title.x=element_blank(), axis.title.y=element_blank(), panel.background=element_blank(), panel.border=element_blank())
heat+geom_text(aes(Var2, Var1, label=value), color = "black", size=3) ##to print correlation vals on plot
ggsave(outfile)
