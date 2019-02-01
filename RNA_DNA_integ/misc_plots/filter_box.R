args =  commandArgs(TRUE)
fileName=args[1]
outfile=args[2]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript filter_box.R pathToStatsMatrix pathTopngFile\n");
  quit()
}

library(rlocal)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

variant.filter=tbl_df(read.csv(fileName,sep="\t"))
#head (variant.filter)
#variant.filter.truseq = filter(variant.filter,
#  sample.name %in% sample.info.truseq$sample.name) %>%
#  mutate(sample.name=as.character(sample.name))

variant.filter.tidy = gather(variant.filter,filter,number,2:10)
#variant.filter.tidy

reverselog_trans <- function(base = exp(1)) {
    trans <- function(x) -log(x, base)
    inv <- function(x) base^(-x)
    trans_new(paste0("reverselog-", format(base)), trans, inv,
              log_breaks(base = base),
              domain = c(1e-100, Inf))
}
median.filter =
  variant.filter.tidy %>%
  group_by(filter) %>%
  summarize (avg=median(number),
             pretty.avg=prettyNum(avg,big.mark=","))


ggplot(variant.filter.tidy, aes(filter,number,fill=filter)) +
  geom_boxplot()+
  scale_x_discrete(limits=rev(colnames(variant.filter[2:10])),
                   labels=rev(c("Total variants",
                     "Read depth\n(>10)",
                     "Q score\n(>5%)",
                     "Population freq\n(<2%)",
                     "Not in RNA \nvariant database",
                     "Coding & \n non-synonymous",
                     "A list",
                     "A1_list",
		     "Epi list"))) +
  theme( axis.text.y = element_text(vjust=0.5, size=16),
        axis.text.x = element_text(vjust=0.5, size=16)) +
  scale_y_continuous(trans=reverselog_trans(10),
                     breaks = c(10^5,10^3,10),
                     labels = c("100,000","1,000", "10"))+
  coord_flip()+
  theme(legend.position="none")+
  xlab("") +
  ylab("") +
  geom_label(data=median.filter,
             aes(filter,avg,label=pretty.avg))

ggsave(outfile)
