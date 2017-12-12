args =  commandArgs(TRUE)
fileName=args[1]
control=args[2]
num_of_ctrl=args[3]
case=args[4]
num_of_case=args[5]
outFile=args[6]

if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript  edgeR_pipe.R filePath controlName numSamplesInControl caseName numSamplesIncase outputFileName\n");
  quit()
}

#source("http://www.bioconductor.org/biocLite.R")
#biocLite("edgeR")
library(edgeR)

##load data
data=read.table(file=fileName, header=TRUE)
counts=data[,-c(1,1)]
rownames(counts)=data[,1]
group <- c(rep(control, num_of_ctrl) , rep(case, num_of_case))

##define BCV (square root of dispersion) - 0.4 for most human samples acc to edgeR vignette
bcv <- 0.4

# creating matrix with sample info, counts and group info
#normalize
cds=DGEList(counts, group=group)
cds <- calcNormFactors( cds )

##PCA plot- can't be created for two samples, need at least 3 to group
##grp_color<- c (rep("red",num_of_ctrl),rep("blue",num_of_case))
##png(file="MDS_plot.png")
##plotMDS(cds, top=1000, labels=colnames(cds$counts), main="MDS Plot for Count Data", ndim=2, dim.plot=c(1,2), cex=0.7, col=grp_color)
##dev.off()

##diff exp using pre-defined dispersion
de <- exactTest( cds, dispersion=bcv^2 ) 


resultsTbl <- topTags( de , n = nrow( de$table ) )$table
wh.rows <- match( rownames( resultsTbl ) , rownames( cds$counts ) )
combResults <- cbind( resultsTbl ,"UpDown" = decideTestsDGE( de , p.value = 0.05 )[wh.rows ] ,cds$counts[ wh.rows, ] )
write.table( combResults , file = outFile , sep = "," , row.names =TRUE )

