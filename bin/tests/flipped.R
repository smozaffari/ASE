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
  print( genes[i])
  command <- paste("grep -w ",genes[i], " /group/ober-resources/users/smozaffari/ASE/data/ensemble_table_hg19_05.31  | cut -f2-5,12 | uniq", sep="")
  snps <- read.table(text=system(command, intern=TRUE))
  mins <- sapply( total , function(x) max( x$V4 )+250000 )
  maxs <- sapply( total , function(x) max( x$V4 )+250000 )
  chr <- sapply( total , function(x) unique(x$V1) )
  for (m in 1:mins)
    system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_paternal --chr ",
              chr[m] ," --from-bp ",
              mins[m], " --to-bp ", maxs[m],
              " --recode --out ", chr[m], "_snppat", mins[m], sep=""))
    system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_maternal --chr ",
              chr[m] ," --from-bp ",
              mins[m], " --to-bp ", maxs[m],
              " --recode --out ", chr[m], "_snpmat", mins[m], sep=""))

mc <- mean(maternal2[i,])
  pc <- mean(paternal2[i,])
  T = 
}
