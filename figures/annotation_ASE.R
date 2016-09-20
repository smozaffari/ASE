#source("https://bioconductor.org/biocLite.R")
#biocLite("AllelicImbalance")
library(dplyr)
library(ggplot2)

#lane1 <- read.csv("100092_lane_1_ASE_info_sort_uniq", sep=" ", header = F)
#lane2 <- read.csv("100092_lane_2_ASE_info_sort_uniq", sep=" ", header = F)


#lane1$V6 <- paste(as.character(lane1$V2), lane1$V3, lane1$V4, sep=".")
#lane2$V6 <- paste(as.character(lane2$V2), lane2$V3, lane2$V4, sep=".")
#laneboth <- merge(lane1, lane2, by="V6")
#head(laneboth)
 
laneboth1 <- read.csv("100092_both_ASE_info", sep=" ", header = F)
laneboth2 <- read.csv("106052_both_ASE_info", sep=" ", header = F)
laneboth3 <- read.csv("24172_both_ASE_info", sep=" ", header = F)
laneboth4 <- read.csv("28101_both_ASE_info", sep=" ", header = F)
laneboth <- rbind(laneboth1, laneboth2, laneboth3, laneboth4)
head(laneboth)
min5 <- filter(laneboth, V1 >=5)

mat<- filter(min5, V4=="mat")
pat<- filter(min5, V4=="pat")


matpat<- filter(min5, V4=="pat" | V4=="mat")
matpat$V1[matpat$V4=="pat"]<- -c(matpat$V1[matpat$V4=="pat"])
matpatchr1_5 <- filter(matpat, V2=="chr1" |V2=="chr2" |V2=="chr3"|V2=="chr4"|V2=="chr5"|V2=="chr6" )
chr6 <- filter(matpat, V2=="chr6")

genes <- read.table("gene_start_stop_noNONE.txt", sep="\t", header = F)

geneschr6 <- filter(genes, V2=="chr6")


for (i in 1:dim(matpat)[1]) {
  chr <- as.character(matpat[i,2])
  geneschr <- filter(genes, V2==chr)
  ff <- geneschr[which(as.numeric(as.character(geneschr$V3))<matpat[i,3]),]
  ff2<- ff[which(as.numeric(as.character(ff$V4))>matpat[i,3]),]
  matpat[i,7] <- paste(ff2$V1, collapse=";")

}


chr6 <- filter(matpat, V2=="chr6")
ggplot(chr6, aes( x=as.factor(unique(V7)),y=V1, fill=V4))+geom_bar(stat="identity")+scale_fill_manual(values=c("#D25565", "#6D739D"))


extract <- chr6[,c(1,2,4,5,6)]

ggplot(chr6_2, aes( x=as.factor(7),y=V1, fill=V4))+
  geom_bar(stat="identity")+
  scale_fill_manual(values=c("#D25565", "#6D739D"), 
                    name="Parental Allele \nin Read",
                    breaks=c("mat", "pat"), 
                    labels=c("Maternal", "Paternal"))+
  geom_text(data=chr6_2, 
            mapping=aes(y=100,label=a), 
            vjust=0,
            nudge_x=0.2, 
            hjust=0, 
            angle=90)+
  theme(legend.text=element_text(size=20), 
        axis.title.x=element_text(size=14),
        axis.title.y=element_text(size=14),
        title=element_text(size=20), 
        axis.text.x=element_blank(), 
        axis.ticks.x=element_blank())+
  labs(x="Genes on chromosome 6, not in order", 
       y="Reads over PO SNP", 
       title="Parent of Origin Reads over Chromosome 6")
matpat$V8 <- matpat$V7
matpat$V7 <- paste(matpat$V2, matpat$V3, sep=":")

chr15 <- filter(matpat, V2=="chr6")
ggplot(chr15, aes( x=as.factor(V8),y=V1, fill=as.factor(V6)))+
  geom_bar(stat="identity", position="identity", colour="black")+
  scale_fill_manual(values=c("#D25565", "#F0B755", "#FFFDC1", "#2e94b9"), 
                    name="Parental Allele \nin Read",
                    breaks=c("mat", "pat"), 
                    labels=c("Maternal", "Paternal"))+
  geom_text(data=chr15, 
            mapping=aes(y=100,label=V8), 
            vjust=0,
            nudge_x=-0.5, 
            hjust=0, 
            angle=90)+
  theme(legend.text=element_text(size=20), 
        axis.title.x=element_text(size=14),
        axis.title.y=element_text(size=14),
        title=element_text(size=20), 
        axis.text.x=element_blank(), 
        axis.ticks.x=element_blank())+
  labs(x="Genes on chromosome 6, not in order", 
       y="Reads over PO SNP", 
       title="Parent of Origin Reads over Chromosome 6")

