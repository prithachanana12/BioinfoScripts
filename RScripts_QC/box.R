##create box plot using only expressed genes (same list as used for DE analysis)
##raw counts
raw <- read.table("/data2/bsi/secondary/Radisky_Derek_m025888/config/170821_MayoClinic_RNASeq_NotreDame/v1.2.1.5_SE_trimmed/diff_exp/expressed_counts_uniq.txt", header=TRUE, row.names=1)
rawlog <- log2(raw+1)
boxplot(rawlog[,1],rawlog[,2],rawlog[,3],rawlog[,4], names=c("s_50170","s_54038","s_53530","s_58484"), xlab="Samples", ylab="log2(raw_counts)")
dev.copy(png,"/data2/bsi/secondary/Radisky_Derek_m025888/config/170821_MayoClinic_RNASeq_NotreDame/v1.2.1.5_SE_trimmed/diff_exp/box_plot_raw.png")
dev.off()

##rpkms
rpkms <- read.table("/data2/bsi/secondary/Radisky_Derek_m025888/config/170821_MayoClinic_RNASeq_NotreDame/v1.2.1.5_SE_trimmed/diff_exp/expressed_rpkms_uniq.txt", header=TRUE, row.names=1)
logfile <- log2(rpkms+1)
boxplot(logfile[,1],logfile[,2],logfile[,3],logfile[,4], names=c("s_50170","s_54038","s_53530","s_58484"), xlab="Samples", ylab="log2(rpkms)")
dev.copy(png,"/data2/bsi/secondary/Radisky_Derek_m025888/config/170821_MayoClinic_RNASeq_NotreDame/v1.2.1.5_SE_trimmed/diff_exp/box_plot_rpkm.png")
dev.off()
