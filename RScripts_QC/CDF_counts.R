args =  commandArgs(TRUE)
fileName=args[1]
out_tiff=args[2]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript plotCDF.R filePath outFilePath\n");
  quit()
}
raw <- read.table(fileName, row.names=1, header=TRUE)
rawlog <- log2(raw+1)
tiff(out_tiff,units="in",compression="lzw",width=8,height=8,res=800)
plot(ecdf(rawlog[,1]),col="violetred3", main="Cumulative Distribution of Gene Counts", xlab="log2(raw_counts)", ylab="Proportion of genes")
plot(ecdf(rawlog[,2]),col="royalblue", add=T)
plot(ecdf(rawlog[,3]),col="plum", add=T)
plot(ecdf(rawlog[,4]),col="gold", add=T)
plot(ecdf(rawlog[,5]),col="green", add=T, pch=".")
plot(ecdf(rawlog[,6]),col="tomato", add=T)
legend("topright", c("s_50170","s_53530","s_54038","s_58484","s_59138","s_63601"), fill=c("violetred3","royalblue","plum","gold","green","tomato"))
dev.off()
