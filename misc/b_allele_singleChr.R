args =  commandArgs(TRUE)
aaf_file=args[1]
baf_plot=args[2]

if(length(args) < 2)
{
  stop("Not enough arguments. Please supply 2 arguments.")
}
aaf_table <- read.table(aaf_file, sep="\t",header=T,stringsAsFactor=F)
png(baf_plot,width=2560,height=1920,res=300)
plot(aaf_table[aaf_table$Chr=="chrX",2],aaf_table[aaf_table$Chr=="chrX",4],main="B Allele Frequency for ChrX",xlab="Chr Coordinates",ylab="BAF")
dev.off()

