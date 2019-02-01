args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
sample=args[3]
if (file.exists(fileName) == FALSE || length(args) < 3){
  writeLines ("Usage:\nRscript scatter.R fileName path_to_outfile(*.png) sample\n");
  quit()
}

library("ggplot2")

dat <- read.table(fileName,header=TRUE,sep='\t')
samp_tpm <- paste("log2tpm_",sample,sep="")
samp_tpm
scatter <- ggplot(dat, aes_string(y = "log2conc", x = samp_tpm))
fit <- lm(paste(samp_tpm,"~ log2conc"), data=dat)
summary(fit)
scatter + geom_point(color="gray") + geom_smooth(method=lm) + geom_rug(color="gray") + xlab(label = paste(sample,"log2 TPM",sep=" ")) + ylab(label = "log2 spike-in concentration") + ggtitle( sample ,subtitle = paste("R_square=", format(summary(fit)$adj.r.squared,digits=2),sep=""))
ggsave(outFile, width=8, height=8)
