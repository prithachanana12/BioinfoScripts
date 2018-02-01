##create box plot using only expressed genes (same list as used for DE analysis)
##raw counts
raw <- read.table("/data2/bsi/tertiary/Ahlquist_David_daa02/mrnaseq/171213_K00316_0132_AHNCHJBBXX_rerun/allsamples_counts_exp.txt", header=TRUE, row.names=1)
rawlog <- log2(raw+1)
png("/data2/bsi/tertiary/Ahlquist_David_daa02/mrnaseq/171213_K00316_0132_AHNCHJBBXX_rerun/boxplot_raw.png", units="in", width=7, height=7, res=600)
boxplot(rawlog[1:length(rawlog)], names=colnames(raw)[1:length(raw)], xlab="Samples", ylab="log2(raw_counts)", las=2, cex.axis=0.6)
#dev.copy(png,"/data2/bsi/tertiary/Ahlquist_David_daa02/mrnaseq/171213_K00316_0132_AHNCHJBBXX_rerun/boxplot_raw.png")
dev.off()

##rpkms
rpkms <- read.table("/data2/bsi/tertiary/Ahlquist_David_daa02/mrnaseq/171213_K00316_0132_AHNCHJBBXX_rerun/allsamples_rpkm_exp.txt", header=TRUE, row.names=1)
logfile <- log2(rpkms+1)
png("/data2/bsi/tertiary/Ahlquist_David_daa02/mrnaseq/171213_K00316_0132_AHNCHJBBXX_rerun/boxplot_rpkm.png", units="in", width=7, height=7, res=600)
boxplot(logfile[1:length(logfile)], names=colnames(rpkms)[1:length(rpkms)], xlab="Samples", ylab="log2(rpkms)", las=2, cex.axis=0.6)
#dev.copy(png,"/data2/bsi/tertiary/Ahlquist_David_daa02/mrnaseq/171213_K00316_0132_AHNCHJBBXX_rerun/boxplot_rpkm.png")
dev.off()
