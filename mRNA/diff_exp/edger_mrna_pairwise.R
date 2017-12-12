args =  commandArgs(TRUE)
fileName=args[1]
pairs=args[2]
groups=args[3]
num_of_ctrl=args[4]
num_of_case=args[5]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript  edgeR_pipe.R filePath pairs(comma_separated_in-order) groups(comma_separated_in-order) num_of_ctrl num_of_case \n");
  quit()
}

library(edgeR)

data=read.table(file=fileName, header=TRUE)
new.data=data[,-1]
rownames(new.data)=data[,1]

pair=factor(unlist(strsplit(pairs,',')))
group=factor(unlist(strsplit(groups,',')))
g1=unique(group)[1]
g2=unique(group)[2]
cds=DGEList(counts=new.data,genes=data[,1],group=group)

cds=calcNormFactors(cds)

grp_color<- c (rep("red",num_of_ctrl),rep("blue",num_of_case))
png(file="MDS_plot.png")
plotMDS(cds, top=1000, labels=colnames(cds$counts), main="MDS Plot for Count Data", ndim=2, dim.plot=c(1,2), cex=0.7, col=grp_color)
dev.off()

data.frame(Sample=colnames(new.data),pair, group)
design=model.matrix(~pair+group)
rownames(design)=colnames(cds)

cds<-estimateGLMCommonDisp(cds,design, verbose=TRUE)
cds<-estimateGLMTrendedDisp(cds,design)
cds<-estimateGLMTagwiseDisp(cds,design)

cv=sqrt(cds$tagwise.dispersion)
hist(sqrt(cds$tagwise.dispersion))

fit<-glmFit(cds,design)
lrt=glmLRT(fit)

topTags(lrt)

summary(de<-decideTestsDGE(lrt))
detags<-rownames(cds)[as.logical(de)]
pic=paste(g1,"_",g2,"_var.png")
png(file=pic)
plotSmear(lrt,de.tags=detags)
abline(h=c(-1, 1), col="blue")
dev.off()
resultsTbl.tgw <- topTags( lrt , n = nrow( lrt$table ) )$table
outFile=paste("edgeR_",g1,"_",g2,".csv")
write.table(resultsTbl.tgw, file=outFile, sep = "," , row.names = TRUE )

