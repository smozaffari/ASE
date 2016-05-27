maternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Maternal_gene_normalized.txt", check.names = F)
paternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Paternal_gene_normalized.txt", check.names = F)
genes <- rownames(maternal)
unknown <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Unknown_gene_normalized.txt", check.names = F)
total <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Total_gene_normalized.txt", check.names = F)                


maternal2 <- as.matrix(maternal)
paternal2 <- as.matrix(paternal)

permute <- function() {
  
}


for (i in 1:dim(maternal2)[1]) {
  snps <- system(paste("grep -w ", genes[i], /group/ober-resources/users/rlee/hutt_annotation/annotation_data/all12_imputed_cgi.annovar_plink_annotations.hg19_multianno.txt | cut -f52))
  system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_paternal --chr ",
              chr ," --from-bp ",
              bp, " --to-bp ", bp,
              " --recode --out ", chr, "_snppat", bp, sep=""))
system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_maternal --chr ",
              chr ," --from-bp ",
             bp, " --to-bp ", bp,
              " --recode --out ", chr, "_snpmat", bp, sep=""))

mc <- mean(maternal2[i,])
  pc <- mean(paternal2[i,])
  T = 
}