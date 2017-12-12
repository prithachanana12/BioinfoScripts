args = commandArgs(TRUE)
fileName=args[1]
control=args[2]
case=args[3]
col1=args[4]
col2=args[5]
outfile=args[6]

if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript DESeq2_NoReplicates.R filePath controlName caseName colName_1_inFile colName_2_inFile outFilePath \n");
  quit()
}

library(DESeq2)
library(Biobase)


dataTable<-read.table(filename, sep="\t", header=TRUE, row.names=1)
#head(dataTable)

samples<-data.frame(row.names=c(col1,col2), condition=as.factor(c(rep(control,1),rep(case,1))))

#samples<-data.frame(row.names=c("Normal", "Tum"), condition=as.factor(c(rep("Normal",1),rep("Tum",1))))

dds <- DESeqDataSetFromMatrix(countData = dataTable, colData=samples, design=~condition)
#DSeqD_1<-DESeq(dds)

## Simon Anders : running comparisons without replicates ########

rld <- rlogTransformation(dds) #,blind = TRUE)
res <- data.frame(
  assay(rld), 
  avgLogExpr = ( assay(rld)[,2] + assay(rld)[,1] ) / 2,
  rLogFC = assay(rld)[,2] - assay(rld)[,1] )

my_result<-( res[ order(res$rLogFC), ] )
write.csv(my_result, file=outfile)
