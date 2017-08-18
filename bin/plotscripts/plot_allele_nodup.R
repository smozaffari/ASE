
#install.packages("ggplot2")
#library(ggplot2)
require(ggplot2)
#install.packages("grid.arrange")
library(gridExtra)
require(gridExtra)

args <- commandArgs(trailingOnly=TRUE)

gene <- args[1]
chr <- args[2]
bp <- args[3]

maternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Maternal_notnormalized_08.16.17_nodup.txt", check.names = F)
paternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Paternal_notnormalized_08.16.17_nodup.txt", check.names = F)
genes <- rownames(maternal)
#unknown <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Unknown_gene_normalized.txt", check.names = F)
#total <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Total_gene_normalized.txt", check.names = F)

maternalfindivs <- cbind("HUTTERITES", paste(colnames(maternal),"2", sep=""))
paternalfindivs <- cbind("HUTTERITES", paste(colnames(paternal),"2", sep=""))
write.table(maternalfindivs, "Maternalfindivs", quote=F, row.names=F, col.names=F)
write.table(paternalfindivs, "Paternalfindivs", quote=F, row.names=F, col.names=F)

system(paste("plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc-po__2017-05-31/imputed-override  --chr ",
              chr ," --from-bp ",
              bp, " --to-bp ", bp,
              " --recode --keep Paternalfindivs --out  ", chr, "_snppat", bp, sep=""))

system(paste("plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc-po__2017-05-31/imputed-override --chr ",
              chr ," --from-bp ",
             bp, " --to-bp ", bp,
              " --recode --keep Maternalfindivs --out ", chr, "_snpmat", bp, sep=""))

pat <- read.table(paste(chr, "_snppat", bp, ".ped" , sep=""))
mat <- read.table(paste(chr, "_snpmat", bp, ".ped" , sep=""))
Findiv <- substr(as.numeric(mat$V2), 1, nchar(mat$V2)-1)
gtype <- as.data.frame(cbind(Findiv, as.character(pat$V7), as.character(mat$V7)))
colnames(gtype) <- c("Findiv", "Pat", "Mat")
removedgt <- which(!Findiv%in%colnames(maternal))
gtype3 <- gtype[match(colnames(maternal),as.character(gtype$Findiv)),]
gtype3$GG <- paste(gtype3$Pat, gtype3$Mat, sep=":")
gtype3$GG[which(gtype3$GG=="NA:NA")] <- "0:0"


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

t <- table(gtype3$GG)

new$Findiv <- rownames(new)
both <- merge(new, gtype3, by="Findiv")
write.table(both, paste(gene, chr, bp, ".txt", sep="_"), col.names=T, row.names=F, quote=F)
