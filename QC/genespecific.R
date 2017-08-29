tab <- read.table("~/Downloads/ENSG00000164308_5_96252432_.txt", header = T)
tab$total <- tab$Mat.x+tab$Pat.x
t <- table(tab$GG)

ggplot(tab, aes(Mat.x, Pat.x, col=GG))+
  geom_point(size=2)+
  theme_bw()+
  labs(x="Maternal Expression", 
       y="Paternal Expression", 
       title="ERAP2 LCL gene expression by eQTL SNP rs2927608")+
  scale_colour_manual("Parental Genotype\n Paternal: Maternal", 
                      values=c("#762a83", "#af8dc3", "#bababa", "#7fbf7b", "#1b7837"), 
                      breaks=names(t),
                      labels=c(paste(names(t), " N=", t)))

tab$het <- tab$GG
tab[which(tab$het=="T:C"),"het"] <- "C:T"
ggplot(tab, aes(het, total, col=het))+geom_boxplot()+theme_bw()+
  labs(x="Genotypes", 
       y="Maternal + Paternal Expression", 
       title="ERAP2 LCL gene expression by eQTL SNP rs2927608")+
  scale_colour_manual("Parental Genotype\n Paternal: Maternal", 
                      values=c("#762a83", "#af8dc3", "#bababa", "#7fbf7b", "#1b7837"), 
                      breaks=names(t),labels=c(paste(names(t), " N=", t)))

ggplot(tab, aes(het, total2, col=het))+geom_boxplot()+theme_bw()+
  labs(x="Genotypes", 
       y="Total Expression", 
      title ="ERAP2 LCL gene expression by eQTL SNP rs2927608")+
  scale_colour_manual("Parental Genotype\n Paternal: Maternal", 
                      values=c("#762a83", "#af8dc3", "#bababa", "#7fbf7b", "#1b7837"), 
                      breaks=names(t),labels=c(paste(names(t), " N=", t)))

