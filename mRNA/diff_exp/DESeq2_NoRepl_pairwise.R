##source("http://bioconductor.org/biocLite.R")
##biocLite("DESeq2")

library(DESeq2)
library(Biobase)

dataTable<-read.table("/data2/bsi/tertiary/Dong_Haidong_dongh/mrnaseq/150424_SN414_0438_BC73WHACXX_DE/GeneCount_0h.expressed.tsv", sep="\t", header=TRUE, row.names=1)
myvars <- c("WT-0_GeneCount","KO-0_GeneCount")
dataTable <- dataTable[myvars]

samples<-data.frame(row.names=c("WT-0_GeneCount","KO-0_GeneCount"), condition=as.factor(c(rep("wild",1),rep("knockout",1))))

dds <- DESeqDataSetFromMatrix(countData = dataTable, colData=samples, design=~condition)

rld <- rlogTransformation(dds) #,blind = TRUE)
res <- data.frame(
  assay(rld), 
  avgLogExpr = ( assay(rld)[,2] + assay(rld)[,1] ) / 2,
  rLogFC = assay(rld)[,2] - assay(rld)[,1] )

my_result<-( res[ order(res$rLogFC), ] )
write.csv(my_result, file="/data2/bsi/tertiary/Dong_Haidong_dongh/mrnaseq/150424_SN414_0438_BC73WHACXX_DE/test_0h.txt")
