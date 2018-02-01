args =  commandArgs(TRUE)
fileName=args[1]
#groups=args[2]
#num_of_ctrl=args[3]
#case=args[4]
#num_of_case=args[5]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript  edgeR_pipe.R filePath groups(comma_separated)\n");
  quit()
}
library(edgeR)
data=read.table(file=fileName, header=TRUE)
counts=data[,-c(1,1)]
#head(counts)
rownames(counts)=data[,1]
group <- c("ED","ED","ED","EV","EV","EV","VD","VD","VD","VV","VV","VV")
print(group)
cds=DGEList(counts, group=group)
cds <- calcNormFactors( cds )
grp_color<- c(rep("red",3), rep("blue",3), rep("green",3), rep("gold",3))
png(file="MDS_plot.png",units="in",width=8,height=8,res=800)
plotMDS(cds, top=1000, pch=20, main="MDS Plot for Count Data", ndim=2, dim.plot=c(1,2), cex=0.7, col=grp_color, xlab="Component 1", ylab="Component 2")
legend("topright", legend = c("End_Dex","End_Veh","Veh_Dex","Veh_Veh"), col = c("red","blue","green","gold"), lty=1,lwd=10)
dev.off()
