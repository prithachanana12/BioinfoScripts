args =  commandArgs(TRUE)
fileName=args[1]
outfile=args[2]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript lollipop.R pathToFreqMatrix pathTopngFile\n");
  quit()
}

library(rlocal)
#addLibGentools()
library(ggplot2)
library(plyr)
library(scales)
library(RColorBrewer)


gene = read.table(fileName, header=T)


png(outfile);
ggplot(data=gene,aes(pos,num))+
  geom_segment(aes(x=pos,y=0,xend=pos,yend=num))+
  geom_point (size=2,alpha=0.6)
dev.off();

