library(ggplot2)
library(reshape2)
library(cowplot2)
theme_set(theme_cowplot(font_size = 18, line_size = 1))


LCL <- read.table("Zall3.txt", header=T)
WB <- read.table("WB_Zall3.txt", header = T)
colnames(LCL)[5] <- "genename"
LCL$diff=LCL$greater0-LCL$less0
LCL2 <- LCL[,c(2,3,5)]
LCL3 <- melt(LCL2, id="genename")
LCL3$diff=LCL$diff
LCL3$genename <- reorder(LCL3$genename, LCL3$diff)
pdf("LCL_WBreplication.pdf", width=17, height=6)
ggplot(LCL3, aes(genename, value, fill=variable))+
  geom_bar(stat="identity", position="dodge")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  labs(x="Gene", title="LCL", y="Individuals")+
  scale_fill_manual(values=c( "#EE2B47","#005792"),
                    name="Parent of Origin \nAsymmetry",
                    breaks=c("less0", "greater0"),
                    labels=c("M>P", "P>M"))
dev.off()

WB$diff=WB$greater0-WB$less0
WB2 <- WB[,c(2,3,5)]
WB3 <- WB2[match(LCL$genename,WB2$genename ),]
WB4 <- melt(WB3, id="genename")
WB4$diff <- LCL3$diff
WB4$genename <- reorder(WB4$genename, WB4$diff)
pdf("WBreplication.pdf", width=17, height=6)
ggplot(WB4, aes(genename, value, fill=variable))+
  geom_bar(stat="identity", position="dodge")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  labs(x="Gene", title="WB Replication of LCL genes", y="Individuals")+
  scale_fill_manual(values=c( "#EE2B47","#005792"),
                    name="Parent of Origin \nAsymmetry",
                    breaks=c("less0", "greater0"),
                    labels=c("M>P", "P>M"))
dev.off()

