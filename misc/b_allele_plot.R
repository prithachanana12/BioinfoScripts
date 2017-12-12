args =  commandArgs(TRUE)
aaf_file=args[1]
baf_plot=args[2]
baf_histo=args[3]

if(length(args) < 3)
{
  stop("Not enough arguments. Please supply 3 arguments.")
}

aaf_table <- read.table(aaf_file, sep="\t",header=T,stringsAsFactor=F)
png(baf_plot,width=2560,height=1920,res=300)
plot(aaf_table[,5],aaf_table[,4],main="B Allele Frequency (BAF)",xlab="1000 Genomes MAF",ylab="BAF")
dev.off()

png(baf_histo,width=2560,height=1920,res=300)
hist(aaf_table[,4],xlab="B Allele Frequency (BAF)",main="BAF Histogram")
#plot(density(aaf_table[,4]),col=1,pch=1,main="B Allele Frequency for SL2-381A",xlab="B Allele Frequency",lwd=2)
dev.off()
