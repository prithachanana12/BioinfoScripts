args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript plot_PCA.R fileName<RPKMS> path_to_outfilepng\n");
  quit()
}

library("ggplot2")
library("ggrepel")

dat <- read.table(fileName, sep="\t", header=TRUE, stringsAsFactors=FALSE, row.names=1)
pca_data <- prcomp(t(dat))
pca_data_perc <- round(100*pca_data$sdev^2/sum(pca_data$sdev^2),1)
#df_pca_data <- data.frame(PC1=pca_data$x[,1], PC2=pca_data$x[,2], sample=colnames(dat), condition=c("orig","rep","orig","orig","rep","orig","orig","rep","orig","orig","rep","orig","orig","rep","orig","rep","orig","orig"))
df_pca_data <- data.frame(PC1=pca_data$x[,1], PC2=pca_data$x[,2], sample=colnames(dat), condition=rep(c("rep","orig"),6))
head(df_pca_data)

ggplot(df_pca_data,aes(PC1,PC2, color=condition)) + geom_point(size=4) + labs(x=paste0("PC1(",pca_data_perc[1],")"), y=paste0("PC2(",pca_data_perc[2],")")) + geom_text_repel(data=df_pca_data, aes(PC1, PC2, label=row.names(df_pca_data)))
#+ geom_text_repel(aes(label=rownames(data)))
ggsave(outFile)
