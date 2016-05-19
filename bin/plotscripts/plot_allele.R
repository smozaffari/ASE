
#install.packages("ggplot2")
library(ggplot2)

args <- commandArgs(trailingOnly=TRUE)

gene <- args[1]
chr <- args[2]
bp <- args[3]

maternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Maternal_gene_normalized.txt", check.names = F)
paternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Paternal_gene_normalized.txt", check.names = F)
genes <- rownames(maternal)

system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_paternal --chr ",
              chr ," --from-bp ",
              bp, " --to-bp ", bp,
              " --recode --out ", chr, "_snppat", bp, sep=""))

system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_maternal --chr ",
              chr ," --from-bp ",
              bp, " --to-bp ", bp,
              " --recode --out ", chr, "_snpmat", bp, sep=""))

pat <- read.table(paste(chr, "_snppat", bp, ".ped" , sep=""))
mat <- read.table(paste(chr, "_snpmat", bp, ".ped" , sep=""))
Findiv <- substr(as.numeric(mat$V2), 1, nchar(mat$V2)-1)
gtype <- cbind(Findiv, as.character(pat$V7), as.character(mat$V7))
colnames(gtype) <- c("Findiv", "Pat", "Mat")
removedgt <- which(!Findiv%in%colnames(maternal))
gtype2 <- as.data.frame(gtype[-c(removedgt),])
gtype3 <- gtype2[match(colnames(maternal), as.character(gtype2$Findiv)),]
gtype3$GG <- paste(gtype3$Pat, gtype3$Mat, sep=":")


num <- grep(gene, genes)
if (length(num) >1) {
    print(genes[grep(gene, genes)])
}

maternal2 <- as.matrix(maternal)
paternal2 <- as.matrix(paternal)

for (i in num) {
  print(i)
  new <- as.data.frame(cbind(maternal2[i,], paternal2[i,]))
  new[is.na(new)] <- 0
  colnames(new) <- c("Mat", "Pat")
  p <-   ggplot(new, aes(Mat, Pat, col=gtype3$GG)) + 
    geom_point( size=3)+
    scale_colour_manual(values=c("#762a83", "#af8dc3", "#bababa", "#7fbf7b", "#1b7837"))+ 
 #                       breaks = c("--", "-G",  "G-", "GG", "00"), 
 #                       labels= c("-m-p","-mGp",  "Gm-p", "GmGp", "No information")) +
    theme(axis.title=element_text(size=20), 
          axis.text=element_text(size=14), 
          plot.title=element_text(size=30), 
          legend.title=element_text(size=20),
          legend.text=element_text(size=14),
          legend.key=element_rect(size=5))+ 
    labs(title=paste(genes[i], " by SNP: chr", chr, ":", bp, sep=""), x= "Maternal", y="Paternal")+
    guides(col=guide_legend(title="Parental Genotype: \n  Maternal:Paternal\n"))
    name=paste(genes[i],"_Maternal_Paternal_", chr,"_", bp, "_", i, ".pdf", sep="")
    print(name)
    ggsave(name, plot=p, width=10, height=6, units="in")
}

sessionInfo()