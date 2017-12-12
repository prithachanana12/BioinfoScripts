rpkms<-read.table("/data2/bsi/tertiary/Amadio_Peter_pca01/160106-MS-PA/rpkm.txt", header=TRUE, row.names=1)
logscale <- log2(rpkms+1)  ## convert to log2 to reduce scale
##create density plot using all genes
png("/data2//bsi//tertiary/Amadio_Peter_pca01/160106-MS-PA/DE/density.png")
plot (density(logscale[,1]), col='darkgreen', main="Density plot log2(RPKM)")
lines (density(logscale[,2]), col='darkmagenta')
lines (density(logscale[,3]), col='gold')
lines (density(logscale[,4]), col='deepskyblue')
lines (density(logscale[,5]), col='deeppink')
lines (density(logscale[,6]), col='darkseagreen1')
lines (density(logscale[,7]), col='firebrick1')
legend("topright", ## location in plot
       legend=c("c25","c27","p51","p52","p53","p54","p56"), ##categories
       lty=1, ##line style
       col=c("darkgreen","darkmagenta","gold","deepskyblue","deeppink","darkseagreen1","firebrick1")) ##colors
dev.off()

##create box plot using only expressed genes (same list as used for DE analysis)
##raw counts
raw <- read.table("/data2/bsi/tertiary/Amadio_Peter_pca01/160106-MS-PA/counts_expressed.txt", header=TRUE, row.names=1)
rawlog <- log2(raw+1)
boxplot(rawlog[,1],rawlog[,2],rawlog[,3],rawlog[,4],rawlog[,5],rawlog[,6],rawlog[,7], names=c("c25","c27","p51","p52","p53","p54","p56"), xlab="Samples", ylab="log2(raw_counts)")
dev.copy(png,"/data2//bsi//tertiary//Amadio_Peter_pca01//160106-MS-PA//DE/raw_boxplot.png")
dev.off()

##rpkms
rpkms <- read.table("/data2/bsi/tertiary/Amadio_Peter_pca01/160106-MS-PA/rpkms_expressed.txt", header=TRUE, row.names=1)
logfile <- log2(rpkms+1)
boxplot(logfile[,1],logfile[,2],logfile[,3],logfile[,4],logfile[,5],logfile[,6],logfile[,7], names=c("c25","c27","p51","p52","p53","p54","p56"), xlab="Samples", ylab="log2(rpkms)")
dev.copy(png,"/data2//bsi//tertiary//Amadio_Peter_pca01//160106-MS-PA//DE/rpkm_boxplot.png")
dev.off()
