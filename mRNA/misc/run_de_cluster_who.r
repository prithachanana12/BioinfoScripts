library(rlocal)
library(edgeR)
library(scatterplot3d)
library(ggplot2)
library(gplots)
library(plyr)


X11.options(type = "nbcairo")
#Useful functions

summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
    library(plyr)

    # New version of length which can handle NA's: if na.rm==T, don't count them
    length2 <- function (x, na.rm=FALSE) {
        if (na.rm) sum(!is.na(x))
        else       length(x)
    }

    # This does the summary. For each group's data frame, return a vector with
    # N, mean, and sd
    datac <- ddply(data, groupvars, .drop=.drop,
      .fun = function(xx, col) {
        c(N    = length2(xx[[col]], na.rm=na.rm),
          mean = mean   (xx[[col]], na.rm=na.rm),
          sd   = sd     (xx[[col]], na.rm=na.rm)
        )
      },
      measurevar
    )

    # Rename the "mean" column    
    datac <- rename(datac, c("mean" = measurevar))

    datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

    # Confidence interval multiplier for standard error
    # Calculate t-statistic for confidence interval: 
    # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
    ciMult <- qt(conf.interval/2 + .5, datac$N-1)
    datac$ci <- datac$se * ciMult

    return(datac)
}


normcounts <- function(counts.filter, group.names) {
  cds<-DGEList(counts=counts.filter,group=group.names)
  cds<-calcNormFactors(cds)
  cds<-estimateCommonDisp(cds)
  cds<-estimateTagwiseDisp(cds)
  pseudo.counts<-cds$pseudo.counts

  return (pseudo.counts)
}

plot.pca <-function(file.name, pseudo.counts, sample.group, color.scheme) {
  mat=log(1+pseudo.counts)
  pca <- prcomp(t(mat))

  sample.labels = unique(sample.group)
  group.colors=mapvalues(as.vector(sample.group),
    from=sample.labels,to=color.scheme)

  png(file=file.name,height=720,width=720)
  scatterplot3d (pca$x[,1:3], color=group.colors )
  legend("topleft",legend=sample.labels,col=color.scheme,pch=c(1),bty="n")
  dev.off()
}

plot.cluster <-function(file.name, pseudo.counts, sample.group, color.scheme) {
  mat=log(1+pseudo.counts)
  sub.mat=mat[c(1:10000),]

  sample.labels = unique(sample.group)
  sample.colors=mapvalues(as.vector(sample.group),
    from=sample.labels, to=color.scheme)

  png(file=file.name,height=850,width=850)

  distCor <- function(x) as.dist(1-cor(t(x)))
  hclustAvg <- function(x) hclust(x, method="average")

  genes=heatmap.2(sub.mat,col=rev(redgreen(75)), scale="row", key=T, keysize=1,
    density.info="none", trace="none",cexCol=1.4, labRow=NA,
    hclust=hclustAvg, distfun=distCor,
    dendrogram="column",ColSideColors=sample.colors)
  
  par(lend = 1)           
  legend("topright",      
         legend = sample.labels, 
         col = color.scheme,
         lty= 1,             
         lwd = 10            
         )
  dev.off()
}

plot.gene <-function(file.name, pseudo.counts, sample.group,ensembl.name, gene.name) {
  gene=pseudo.counts[ensembl.name,]

  df=data.frame(val=gene,group=sample.group)
  tgc=summarySE(df,measurevar="val",groupvars=c("group"))

  png(file=file.name,height=850,width=850)

  ggplot(tgc,aes(x=factor(group),y=val))+
       geom_bar(position=position_dodge(),stat="identity",
               fill="white",colour="black")+
       geom_errorbar(aes(ymin=val-se,ymax=val+se),
                     width=.2,position=position_dodge(.9))+
       xlab("Group")+
       ylab("Expression(log scale)")+
       scale_x_discrete(limits=levels(sample.group))+
       ggtitle(gene.name) +
       theme(axis.text.x=element_text(angle=45,hjust=1))+
       scale_y_log10()
  dev.off()
}

save.differential <-function(file.name, lrt, info, pseudo.counts,group, case, control) {

  results <- topTags( lrt , n = nrow( lrt$table ) )$table

  info.gene = info[match(rownames(results),rownames(info)),]
  counts.index= match(rownames(results),rownames(pseudo.counts))

  case.counts = pseudo.counts[counts.index,group==case]
  control.counts = pseudo.counts[counts.index,group==control]

  out.table = cbind(info.gene,
    results[,c("logFC","logCPM","PValue","FDR")],
    case.counts, control.counts)
  
  write.table(out.table, file=file.name,sep="\t",col.names=NA)

  return(out.table)
}

save.MA <-function(file.name, lrt, cds) {
  summary(de<-decideTestsDGE(lrt))
  detags<-rownames(cds)[as.logical(de)]
  png(file=file.name)
  plotSmear(lrt,de.tags=detags)
  abline(h=c(-1, 1), col="blue")
  dev.off()
}

# Read sample/patient correspondence
data.id=read.table(file="supplied_results/sample_patient.csv",header=TRUE)
new.info.csv=read.table(file="supplied_results/cmml.fab",header=TRUE)

new.cases=merge(data.id,new.info.csv)
fab.cases=merge(data.id, new.cases,by.x="pat.id",by.y="pat.id")
fab.cases=fab.cases[c("Seq.id.x","pat.id","FAB","qc.pass.x")]
colnames(fab.cases)=c("seq.id","pat.id.","fab","qc")

order.fab.cases=fab.cases[order(fab.cases$seq.id),]


samples=read.table(file="supplied_results/sample_info.ex.csv",sep='\t',header=T)
samples.merge=merge(order.fab.cases,samples,by.x="seq.id",by.y="Name")
samples.fab=subset(samples.merge,(qc=="Y")&((Phenotype=="CMML")|(Phenotype=="Normal")))
write.table(samples.fab, file="results/cmml_samples.xls",sep="\t",col.names=NA)

# Merge 2 phenotype tables
data.id=read.table(file="supplied_results/sample_patient.csv",header=TRUE)
samples=read.table(file="supplied_results/sample_info.csv",sep='\t',header=T)
samples.id=merge(data.id,samples,by.x="Seq.id",by.y="Name",all=TRUE)

new.info=read.table(file="supplied_results/new_info.csv",sep='\t',header=T)
new.info.id = merge(data.id,new.info)
patient.merge=merge(data.id,new.info.id,by.x="pat.id",by.y="pat.id")

all.patient.merge=merge(patient.merge,samples.id,by.x="Seq.id.x",by.y="Seq.id",all=TRUE)
clean.all.patient.merge=subset(all.patient.merge,select=-c(qc.pass.x,Seq.id.y,pat.id.y,qc.pass))
cols.names = c("sample","patient.id","qc.status","fab","asxl1","asxl1.mut","asxl1.vaf","tet2",
  "splicing","mutations","mutations.daniela","cyto","mmm","leukemic.transf","hma.exposure",
  "flowcell","phenotype","source","hma","mutations.first","asxl1.first","tet2.first","cyto.first");
colnames(clean.all.patient.merge)=cols.names

write.table(clean.all.patient.merge, file="supplied_results/db.all.xls",sep="\t",col.names=NA)


#Samples for splicing
cmml.splicing.samples=subset(clean.all.patient.merge,
  (qc.status=="Y")&(phenotype=="CMML")& (source=="Bone marrow") & ((splicing=="Y" | splicing=="N")))
write.table(cmml.splicing.samples, file="results/splicing.xls",sep="\t",col.names=NA)


# Read Gene counts table
data=read.table(file="results/counts_genes.tsv",header=TRUE)
counts=data[,c(7:91)]
rownames(counts)=data[,2]
counts.fab = counts[as.vector(samples.fab$seq.id)]

isexpr= rowSums(cpm(counts.fab)>1) >=10
counts.filter=counts.fab[isexpr,]
dim(counts.filter)
boxplot(log(1+counts.filter))

# Box-plot of normalized raw counts
png(file="png/boxplot_raw.png",height=480,width=480)
boxplot(log(1+counts.filter))
dev.off()

# Group information
group.names=paste(samples.fab$fab,samples.fab$Source,sep=".")
pseudo.counts=normcounts(counts.filter,factor(group.names))

# Box-plot of normalized raw counts
png(file="png/boxplot_norm.png",height=480,width=480)
boxplot(log(1+pseudo.counts))
dev.off()

# PCA analysis
sample.phenotype=paste(samples.fab$fab,samples.fab$Source,sep=".")
phenotype.color.scheme=c("blue","yellow","red","green","gray")

plot.pca(file.name="png/PCA.phenotype.png",pseudo.counts=pseudo.counts,
          sample.group=sample.phenotype,color.scheme=phenotype.color.scheme)

#Clustering

# According to phenotype-source
plot.cluster(file.name="png/cluster.phenotype.png",
             pseudo.counts=pseudo.counts,
             sample.group=sample.phenotype, color.scheme=phenotype.color.scheme)

#Clustering on bone marrow
bm.samples = samples.fab[which(samples.fab$Source=="Bone marrow"),]
counts.bm = pseudo.counts[,as.vector(bm.samples$seq.id)]

sample.phenotype=bm.samples$fab
color.scheme=c("blue","green","gray")

plot.cluster(file.name="png/cluster.bm.png",
             pseudo.counts=counts.bm,
             sample.group=sample.phenotype, color.scheme=color.scheme)

#Clustering on peripheral blood samples
pb.samples = samples.fab[which(samples.fab$Source=="Peripheral blood"),]
counts.pb = pseudo.counts[,as.vector(pb.samples$seq.id)]

sample.phenotype=pb.samples$fab
phenotype.color.scheme=c("blue","green")

plot.cluster(file.name="png/cluster.pb.png",
             pseudo.counts=counts.pb,
             sample.group=sample.phenotype, color.scheme=phenotype.color.scheme)

#Set up info table
info = data[,c("GeneName","Description","Chr","Start","Stop")]
rownames(info) = data$GeneID
source = samples.fab$Source
source=gsub("Peripheral blood","PB",source)
source=gsub("Bone marrow","BM",source)


#Comparisons involving BM

## Comparisons of normal and CMML cases in BM

source.phenotype = paste(source,samples.fab$Phenotype,sep=".")

cds <- DGEList(counts=counts.filter,group=source.phenotype)
cds <- calcNormFactors(cds)

design <- model.matrix(~0+source.phenotype,data=cds$samples)
colnames(design) <- levels(cds$samples$group)
cds <- estimateDisp(cds, design, robust=TRUE)
fit<- glmFit(cds,design)

lrt<- glmLRT(fit,contrast=makeContrasts(BM.CMML-BM.Normal,levels=design))
bm.cmp=save.differential(file.name="results/bm.cmml-normal.xls",
                  lrt=lrt, info=info, group=source.phenotype,
                  pseudo.counts=pseudo.counts,
                  control="BM.Normal",case="BM.CMML")
save.MA(file.name="png/bm.cmml.ma.png",lrt,cds)


# Clustering on differentially expressed genes
bm.sig=subset(bm.cmp,(bm.cmp$FDR<0.1)&(bm.cmp$logCPM>-1),select=s_CMML05:s_NM09)

genemat=as.matrix(log(1+bm.sig))

distCor <- function(x) as.dist(1-cor(t(x)))
hclustAvg <- function(x) hclust(x, method="average")

genes=heatmap.2(genemat,col=rev(redgreen(75)),
  scale="row", key=T, keysize=1.5,density.info="none",
  trace="none",cexCol=0.9, labRow=NA,dendrogram="both",
  distfun=distCor,hclustfun=hclustAvg,ColSideColors=sample.colors)


## Set up for Dysplastic and Proliferative categories

sample.source.phenotype=paste(source,samples.fab$fab,sep=".")
  
cds <- DGEList(counts=counts.filter,group=sample.source.phenotype)
cds <- calcNormFactors(cds)

design <- model.matrix(~0+sample.source.phenotype,data=cds$samples)
colnames(design) <- levels(cds$samples$group)
cds <- estimateDisp(cds, design, robust=TRUE)
fit<- glmFit(cds,design)

# Compare Dysplastic vs Proliferative (BM)
lrt<- glmLRT(fit,contrast=makeContrasts(BM.Proliferative-BM.Dysplastic,levels=design))
bm.cmp=save.differential(file.name="results/bm.dysplastic-proliferative.xls",
                  lrt=lrt, info=info, group=sample.source.phenotype,
                  pseudo.counts=pseudo.counts,
                  control="BM.Dysplastic",case="BM.Proliferative")
save.MA(file.name="png/bm.fab.ma.png",lrt,cds)

genes.bm.fab = rownames(subset(bm.cmp,(bm.cmp$logCPM>-1)&(abs(bm.cmp$logFC)>1)))

genes.index = match(genes.bm.fab,rownames(pseudo.counts))
bm.samples = samples.fab[which(samples.fab$Source=="Bone marrow"),]
counts.bm = pseudo.counts[genes.index,as.vector(bm.samples$seq.id)]


genemat=as.matrix(log(1+counts.bm))
sample.group=bm.samples$fab
sample.labels = unique(sample.group)
color.scheme = c("red","blue","gray")
sample.colors=mapvalues(as.vector(sample.group),
  from=sample.labels, to=color.scheme)


genes=heatmap.2(genemat,col=rev(redgreen(75)),
  scale="row", key=T, keysize=1.5,density.info="none",
  trace="none",cexCol=0.9, labRow=NA,dendrogram="both",
  distfun=distCor,hclustfun=hclustAvg,ColSideColors=sample.colors)


# Compare Dysplastic vs Proliferative (PB)
lrt<- glmLRT(fit,contrast=makeContrasts(PB.Proliferative-PB.Dysplastic,levels=design))
save.differential(file.name="results/pb.proliferative-dysplastic.xls",
                  lrt=lrt, info=info, group=sample.source.phenotype,
                  pseudo.counts=pseudo.counts,
                  control="PB.Dysplastic",case="PB.Proliferative")
save.MA(file.name="png/pb.fab.ma.png",lrt,cds)


genes.bm.fab = rownames(subset(bm.cmp,(bm.cmp$FDR<0.1)&(bm.cmp$logCPM>-1)&(abs(bm.cmp$logFC)>1)))
genes.index = match(genes.bm.fab,rownames(pseudo.counts))

pb.samples = samples.fab[which(samples.fab$Source=="Peripheral blood"),]
counts.pb = pseudo.counts[genes.index,as.vector(pb.samples$seq.id)]


genemat=as.matrix(log(1+counts.pb))
sample.group=pb.samples$fab
sample.labels = unique(sample.group)
color.scheme = c("blue","red")
sample.colors=mapvalues(as.vector(sample.group),
  from=sample.labels, to=color.scheme)


png(file="png/cluster_pb.png",height=960,width=960)
genes=heatmap.2(genemat,col=rev(redgreen(75)),
  scale="row",key=T, keysize=1.5,density.info="none",
  trace="none",cexCol=0.9, labRow=NA,dendrogram="both",
  distfun=distCor,hclustfun=hclustAvg,ColSideColors=sample.colors)

par(lend = 1)           
legend("topright",      
       legend = sample.labels, 
       col = color.scheme,
       lty= 1,             
       lwd = 10            
       )
dev.off()


tst=genemat[rev(genes$rowInd),genes$colInd]

write.table(tst,file="results/pb.cluster.xls",sep="\t",col.names=NA)
           


# Comparisosn only for BM clusters

# 3 Clusters
pb.samples = samples.fab[which(samples.fab$Source=="Peripheral blood"),]
pb.counts = counts[as.vector(pb.samples$seq.id)]


pb.samples$cluster=c("c.1","c.3","c.1","c.3","c.1","c.3","c.3","c.1","c.1","c.1","c.1","c.1","c.2","c.3","c.3","c.2","c.3","c.1","c.1","c.3","c.3","c.2","c.2","c.3","c.1")

isexpr= rowSums(cpm(pb.counts)>1) >=5
pb.counts.filter=pb.counts[isexpr,]

pb.pseudo.counts=normcounts(pb.counts.filter,factor(pb.samples$cluster))

pb.cds <- DGEList(counts=pb.counts.filter,group=pb.samples$cluster)

pb.cds <- calcNormFactors(pb.cds)

design <- model.matrix(~0+pb.samples$cluster,data=pb.cds$samples)
colnames(design) <- levels(pb.cds$samples$group)
pb.cds <- estimateDisp(pb.cds, design, robust=TRUE)
pb.fit<- glmFit(pb.cds,design)

pb.lrt<- glmLRT(pb.fit,contrast=makeContrasts(c.3-c.1,levels=design))
pb.c3.c1=save.differential(file.name="results/pb.c3-c1.xls",
        lrt=pb.lrt, info=info, group=pb.samples$cluster,
        pseudo.counts=pb.pseudo.counts,
        control="c.1",case="c.3")
save.MA(file.name="png/pb.c1-c3.ma.png",pb.lrt,pb.cds)


pb.lrt<- glmLRT(pb.fit,contrast=makeContrasts(c.3-c.2,levels=design))
pb.c3.c2=save.differential(file.name="results/pb.c3-c2.xls",
        lrt=pb.lrt, info=info, group=pb.samples$cluster,
        pseudo.counts=pb.pseudo.counts,
        control="c.2",case="c.3")
save.MA(file.name="png/pb.c3-c2.ma.png",pb.lrt,pb.cds)


pb.lrt<- glmLRT(pb.fit,contrast=makeContrasts(c.2-c.1,levels=design))
pb.c2.c1=save.differential(file.name="results/pb.c2-c1.xls",
        lrt=pb.lrt, info=info, group=pb.samples$cluster,
        pseudo.counts=pb.pseudo.counts,
        control="c.1",case="c.2")
save.MA(file.name="png/pb.c2-c1.ma.png",pb.lrt,pb.cds)

#2 Clusters

pb.samples$cluster=c("c.1","c.3","c.1","c.3","c.1","c.3","c.3","c.1","c.1","c.1","c.1","c.1","c.3","c.3","c.3","c.3","c.3","c.1","c.1","c.3","c.3","c.3","c.3","c.3","c.1")


isexpr= rowSums(cpm(pb.counts)>1) >=10
pb.counts.filter=pb.counts[isexpr,]

pb.cds <- DGEList(counts=pb.counts.filter,group=pb.samples$cluster)

pb.cds <- calcNormFactors(pb.cds)


design <- model.matrix(~0+pb.samples$cluster,data=pb.cds$samples)
colnames(design) <- levels(pb.cds$samples$group)
pb.cds <- estimateDisp(pb.cds, design, robust=TRUE)
pb.fit<- glmFit(pb.cds,design)

pb.lrt<- glmLRT(pb.fit,contrast=makeContrasts(c.3-c.1,levels=design))
pb.cmp=save.differential(file.name="results/pb.2-groups.xls",
        lrt=pb.lrt, info=info, group=pb.samples$cluster,
        pseudo.counts=pb.pseudo.counts,
        control="c.1",case="c.3")
save.MA(file.name="png/pb.2-groups.ma.png",pb.lrt,pb.cds)
