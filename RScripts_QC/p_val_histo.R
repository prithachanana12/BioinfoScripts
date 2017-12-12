library("ggplot2")
de<-read.table("C:/Users/m133293/Documents/Ibrahim_tert_NASH/tgw_control.vs.case.csv", header=TRUE, sep=",")

ggplot() + geom_histogram(aes(x = de$PValue), color="black", fill="red", alpha=0.25) + scale_y_continuous(name="Count") + scale_x_continuous(name="p-value")
ggsave("C:/Users/m133293/Documents/Ibrahim_tert_NASH/p_val_histo.png")
