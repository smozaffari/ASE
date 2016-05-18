


args <- commandArgs(trailingOnly=TRUE)

dir <- args[1]
gene <- args[2]
chr <- args[3]
bp <- args[4]

maternal <- read.table(paste(dir, "/Maternal_gene_normalized.txt", sep=""), check.names = F)
paternal <- read.table(paste(dir, "/Paternal_gene_normalized.txt", sep=""), check.names = F)
genes <- rownames(maternal)

system2(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_paternal --chr ",
              chr ,"--from-bp ",
              bp, "--to-bp ", bp,
              "--recode --out ", chr, "_snppat", bp, sep=""))

system2(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_maternal --chr ",
              chr ,"--from-bp ",
              bp, "--to-bp ", bp,
              "--recode --out ", chr, "_snpmat", bp, sep=""))

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
  new <- as.data.frame(cbind(maternal2[i,], paternal2[i,]))
  new[is.na(new)] <- 0
  colnames(new) <- c("Mat", "Pat")
  new$Mat <- as.numeric(new$Mat)
  new$Pat <- as.numeric(new$Pat)
  png(paste(gene,"_Maternal_Paternal_", chr,"_", snp, ".png", sep=""), width=800, height=600)
  ggplot(new, aes(Mat, Pat, col=gtype3$GG)) + 
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
    labs(title=gene, x= "Maternal", y="Paternal")+
    guides(col=guide_legend(title="Parental Genotype: \n  Maternal:Paternal\n"))
  dev.off()
}
