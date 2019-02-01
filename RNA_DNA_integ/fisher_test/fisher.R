##Calculates log-odds ratio and p-value for each mutated gene
#input.txt is the file with case and control numbers for each gene - output from get_nums.sh


args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) < 2){
  writeLines ("Usage:\nRscript fisher.R input.txt output.txt\n");
  quit()
}

dat <- read.table(fileName, sep="\t")
#head(dat)
dat[is.na(dat)] <- 0
head(dat)
dat <- dat + 1 
head(dat)
dat <- dat[-c(1249),]
#getPvals <- function(x){
# gene <- cbind(c(as.numeric(x$V2),250-as.numeric(x$V2)),c(as.numeric(x$V3),108-as.numeric(x$V3)))
# res <- paste(x$V1,fisher.test(gene)$p.value,fisher.test(gene)$estimate,sep=" ")
# write.table(res,file=outFile,append=TRUE,sep=' ')
#}

#apply(dat, 1, getPvals)
for(i in 1:nrow(dat)) {
	row <- dat[i,]
	gene<-cbind(c(as.numeric(row$V2),250-as.numeric(row$V2)),c(as.numeric(row$V3),108-as.numeric(row$V3)))
	res <- paste(row$V1,fisher.test(gene)$p.value,fisher.test(gene)$estimate,sep=" ")
	write.table(res,file=outFile,append=TRUE,sep=' ')
}	
