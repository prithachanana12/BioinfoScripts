args =  commandArgs(TRUE)
fileName=args[1]
control=args[2]
num_of_ctrl=args[3]
case=args[4]
num_of_case=args[5]
#Gets the long names of jobs in the queue with a given status (r,qw,hqwi
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript  edgeR_pipe.R filePath controlName numSamplesInControl caseName numSamplesIncase\n");
  quit()
}
#cat(fileName,control,num_of_ctrl,case,num_of_case)
#quit()
#######################   edger from Asha ##################
## plotMDS.DGEList didnt work for 2 samples. said 'too few samples'
#source("http://www.bioconductor.org/biocLite.R")
#biocLite("edgeR")
library(edgeR)
#setwd ("/data2/bsi/RandD/mrnaseq/edgeR")
data=read.table(file=fileName, header=TRUE)
#data=read.table(file="GeneCountUniq.txt", header=TRUE)
#head(data)
counts=data[,-c(1,1)]
rownames(counts)=data[,1]
#colnames(counts)
#head(counts)
#dim(counts)
#colSums(counts)
group <- c(rep(control, num_of_ctrl) , rep(case, num_of_case))
#group <- c(rep("DC", 6), rep ("DDG", 5))
#group <- c(rep("DDG", 5), rep ("I", 6))
#group <- c(rep("I", 6), rep ("N", 4))
#group <- c(rep("N", 4) , rep("DC", 6))
# creating matrix with sample info, counts and group info
cds=DGEList(counts, group=group)
keep <- rowSums(cpm(cds)>1) >= min(num_of_ctrl,num_of_case) 
cds <- cds[keep, ,keep.lib.sizes=FALSE]
#cds
# find number of genes with 0 counts
#sum(cds$all.zeros)
# filter out low count reads, ie, keep genes with at least 1 read per million
# in at least 3 samples
#cds=cds[rowSums(1e+06 * cds$counts/expandAsMatrix(cds$samples$lib.size,dim(cds)) > 1) >= 3, ]
# calculate normalization factors which correct for H69_NHCerent composition of
# samples
cds <- calcNormFactors( cds )
#cds$samples
#  effective library size / normalized counts
#cds$samples$lib.size * cds$samples$norm.factors
# MDS plot
# top 10 genes chosen that have the most variation b/w samples. distance
# between each pair of samples
# is the biological coefficient of variation. Default setting, top=500
grp_color<- c (rep("red",num_of_ctrl),rep("blue",num_of_case))
#png(file="MDS_plot.png")
#plotMDS(cds, top=1000, labels=colnames(cds$counts), main="MDS Plot for Count Data", ndim=2, dim.plot=c(1,2), cex=0.7, col=grp_color)
#dev.off()
# find the value for common dispersion across all samples
cds <- estimateCommonDisp( cds )
#cds$common.dispersion
# find value for tagwise dispersion for eacg gene. tagwise dispersion is
# squeezed towards common dispersion. 
# Amount of squeezing determined by parameter prior.n. recommendation for
# prior.n=50/(#samples-#groups)
# #samples=8, #groups=2, prior.n=8.33
cds <- estimateTagwiseDisp( cds)
#summary( cds$tagwise.dispersion )
# Mean - Variance plot
# grey dots=raw variances of counts
# light blue=variances using tagwise dispersion
# solid blue line=variances using common dispersion
# solid black line=poission variance where variance = mean
png(file="Mean_Variance_plot.png")
meanVarPlot <- plotMeanVar( cds , show.raw.vars=TRUE ,show.tagwise.vars=TRUE ,show.binned.common.disp.vars=FALSE ,show.ave.raw.vars=FALSE ,dispersion.method = "qcml" , NBline = TRUE ,nbins = 100 ,pch = 16 ,xlab="Mean Expression (Log10 Scale)" ,ylab = "Variance (Log10 Scale)" ,main ="Mean-Variance Plot" )
dev.off()
# perform pair-wise tests for H69_NHCerential experssion between two groups
# doesnt work --> de.cmn <- exactTest( cds , common.disp = TRUE , pair = c(
# "C" , "T" ) ) 
# doesnt work --> de.tgw <- exactTest( cds , common.disp = FALSE , pair = c(
# "C" , "T" ) )
de.cmn <- exactTest( cds, pair = c( control , case ), dispersion="common" ) 
de.tgw <- exactTest( cds, pair = c( control, case ),dispersion="tagwise" )
de.poi <- exactTest( cds , dispersion = 1e-06 , pair = c( control , case ) ) #
#works
# top H69_NHCerentailly expressed genes after adjusting raw p-values with FDR
# correction
#options( digits = 3 )
#topTags( de.tgw , n = 20 , sort.by = "p.value" ) 
# sort results by FC instead of p-value
resultsByFC.tgw <- topTags( de.tgw , n = nrow( de.tgw$table ) , sort.by ="logFC" )$table
head( resultsByFC.tgw )
# sort all topTags results tables
resultsTbl.cmn <- topTags( de.cmn , n = nrow( de.cmn$table ) )$table
resultsTbl.tgw <- topTags( de.tgw , n = nrow( de.tgw$table ) )$table
resultsTbl.poi <- topTags( de.poi , n = nrow( de.poi$table ) )$table
#head( resultsTbl.tgw )
# compare adjusted p-values to significance level(0.05) to find number of
# H69_NHCerentially expressed genes
de.genes.cmn <- rownames( resultsTbl.cmn )[ resultsTbl.cmn$PValue <= 0.05 ]
de.genes.tgw <- rownames( resultsTbl.tgw )[ resultsTbl.tgw$PValue <= 0.05 ]
de.genes.poi <- rownames( resultsTbl.poi )[ resultsTbl.poi$PValue <= 0.05 ]
# number of sig genes
#length( de.genes.cmn )
#length( de.genes.tgw )
#length( de.genes.poi )
# % of sig genes
#length( de.genes.cmn ) / nrow( resultsTbl.cmn ) * 100
#length( de.genes.tgw ) / nrow( resultsTbl.tgw ) * 100
#length( de.genes.poi ) / nrow( resultsTbl.poi ) * 100
# Up/Down regulated summary for tagwise results
#summary( decideTestsDGE( de.tgw , p.value = 0.05 ) ) # doesnt work, probably
#looking for resultsTbl.tgw$adj.P.Val instead of resultsTbl.tgw$PValue
# find DE genes in common
#sum( de.genes.tgw %in% de.genes.cmn ) / length( de.genes.tgw ) * 100 # Tagwise
#to Common
#sum( de.genes.cmn %in% de.genes.tgw ) / length( de.genes.cmn ) * 100 # Common
#to Tagwise
#sum( de.genes.tgw %in% de.genes.poi ) / length( de.genes.tgw ) * 100 # Tagwise
#to Poisson
# Percent shared out of top 10, 100 & 1000 between tagwise and common
#sum( de.genes.tgw[1:10] %in% de.genes.cmn[1:10] ) / 10 * 100
#sum( de.genes.tgw[1:100] %in% de.genes.cmn[1:100] )
sum( de.genes.tgw[1:1000] %in% de.genes.cmn[1:1000] ) / 1000 * 100
# Percent shared out of top 10, 100 & 1000 between tagwise and poisson
sum( de.genes.tgw[1:10] %in% de.genes.poi[1:10] ) / 10 * 100
sum( de.genes.tgw[1:100] %in% de.genes.poi[1:100] )
sum( de.genes.tgw[1:1000] %in% de.genes.poi[1:1000] ) / 1000 * 100
# visualize expression levels for top DE genes
png(file="Differential_expression_all_genes_plot.png")
par( mfrow=c(3 ,1) )
hist( resultsTbl.poi[de.genes.poi[1:100],"logCPM"] , breaks=100 , xlab="Log Concentration" , col="red" , freq=FALSE , main="Poisson: Top 100" )
hist( resultsTbl.cmn[de.genes.cmn[1:100],"logCPM"] , breaks=100 , xlab="Log Concentration" ,col="green" , freq=FALSE , main="Common: Top 100" )
hist( resultsTbl.tgw[de.genes.tgw[1:100],"logCPM"] , breaks=100 , xlab="Log Concentration" , col="blue" , freq=FALSE , main="Tagwise: Top 100" )
dev.off()
# MA plot showing relationship b/w concentration and FC across genes. DE genes
# colored red, non-DE black.
# orange = genes with 0 counts in all samples of one of the groups
# blue line= at log-FC of 2 to represent level fo biological sig
png(file="MA_plot_all_genes.png")
par( mfrow=c(2,1) )
plotSmear( cds , de.tags=de.genes.poi , main="Poisson" ,pair = c(control,case) ,cex= .35 ,xlab="Log Concentration" , ylab="Log Fold-Change" )
abline( h = c(-2, 2) , col = "dodgerblue" )
plotSmear( cds , de.tags=de.genes.tgw , main="Tagwise" ,pair = c(control,case) ,cex= .35 ,xlab="Log Concentration" , ylab="Log Fold-Change" )
abline( h = c(-2, 2) , col = "dodgerblue" )
par( mfrow=c(1,1) )
dev.off()
# same MA plot, but on top 500 DE genes
png(file="MA_plot_top_500_genes.png")
par( mfrow = c(2,1) )
plotSmear( cds , de.tags=de.genes.poi[1:500] , main="Poisson" ,pair=c(control,case),cex=.5 ,xlab="Log Concentration" , ylab="Log Fold-Change" )
abline( h = c(-2, 2) , col = "dodgerblue" )
plotSmear( cds , de.tags=de.genes.tgw[1:500] , main="Tagwise" ,pair=c(control,case),cex = .5 ,xlab="Log Concentration" , ylab="Log Fold-Change" )
abline( h = c(-2, 2) , col = "dodgerblue" )
par( mfrow=c(1,1) )
dev.off()
## outputting results
# re-order count matrix to be in line with the order of results
wh.rows.tgw <- match( rownames( resultsTbl.tgw ) , rownames( cds$counts ) )
wh.rows.cmn <- match( rownames( resultsTbl.cmn ) , rownames( cds$counts ) )
head( wh.rows.tgw )
# tagwise results
combResults.tgw <- cbind( resultsTbl.tgw ,"Tgw.Disp" = cds$tagwise.dispersion[
wh.rows.tgw ] ,"UpDown.Tgw" = decideTestsDGE( de.tgw , p.value = 0.05 )[
wh.rows.tgw ] ,cds$counts[ wh.rows.tgw , ] )
combResults.cmn <- cbind( resultsTbl.cmn ,"Cmn.Disp" = cds$common.dispersion
,"UpDown.Cmn" = decideTestsDGE( de.cmn , p.value = 0.05 )[ wh.rows.cmn ]
,cds$counts[ wh.rows.cmn , ] )
# combining common and tagwise results
wh.rows <- match( rownames( combResults.cmn ) , rownames( combResults.tgw ) )
combResults.all <- cbind( combResults.cmn[,1:4] ,combResults.tgw[wh.rows,3:4], "Cmn.Disp" = combResults.cmn[,5],"Tgw.Disp" =combResults.tgw[wh.rows,5],"UpDown.Cmn" = combResults.cmn[,6],"UpDown.Tgw" =combResults.tgw[wh.rows,6],combResults.cmn[,7:ncol(combResults.cmn)] )
head( combResults.all )
# Ouput csv tables of results
write.table( combResults.tgw , file ="tgw_control.vs.case.csv" , sep = "," , row.names =TRUE )
write.table( combResults.cmn , file ="cmn_control.vs.case.csv" , sep = "," , row.names =TRUE )
write.table( combResults.all , file ="all_control.vs.case.csv" , sep = "," , row.names = TRUE)

## individule gene variance to output file #
# neg binormial var formula
# meanGeneCount + meanGeneCount^2*cds$tagwise.dispersion 
 
