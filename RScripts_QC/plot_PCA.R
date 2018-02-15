args =  commandArgs(TRUE)
fileName=args[1]
out_png=args[2]
#groups=args[2]
#num_of_ctrl=args[3]
#case=args[4]
#num_of_case=args[5]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript  edgeR_pipe.R filePath outFilePath\n");
  quit()
}
library(edgeR)
data=read.table(file=fileName, header=TRUE)
counts=data[,-c(1,1)]
#head(counts)
rownames(counts)=data[,1]
group <- c("Nm","Hy","Nm","Hy","Nm","Hy")
print(group)
cds=DGEList(counts, group=group)
keep <- rowSums(cpm(cds)>1) >= 3
cds <- cds[keep, ,keep.lib.sizes=FALSE]
cds <- calcNormFactors( cds )
grp_color<- c("red","blue","red","blue","red","blue")
png(file=out_png,units="in",width=8,height=8,res=800)
plotMDS(cds, top=1000, pch=20,labels=colnames(cds) ,main="MDS Plot for Count Data", ndim=2, dim.plot=c(1,2), cex=0.7, col=grp_color, xlab="Component 1", ylab="Component 2")
legend("topright", legend = c("Normoxia","Hypoxia"), col = c("red","blue"), lty=1,lwd=10)
dev.off()
