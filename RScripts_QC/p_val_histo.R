args =  commandArgs(TRUE)
fileName=args[1]
outfile=args[2]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript p_value_histo.R filePath pathTopngFile\n");
  quit()
}

library("ggplot2")
de<-read.table(fileName, header=TRUE, sep=",")

ggplot() + geom_histogram(aes(x = de$PValue), color="black", fill="red", alpha=0.25) + scale_y_continuous(name="Count") + scale_x_continuous(name="p-value")
ggsave(outfile)
