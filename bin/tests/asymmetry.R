#!/usr/bin/Rscript

library(doParallel)
library(foreach)
require(doParallel)
require(foreach)

registerDoParallel()
getDoParWorkers()
registerDoSEQ()
getDoParWorkers()
cl <- makeCluster(16)
registerDoParallel(cl)

dir <- "/lustre/beagle2/ober/users/smozaffari/ASE"

maternal <- read.table(paste(dir,"/data/expression/Maternal_gene_normalized.txt", sep=""), check.names = F)
paternal <- read.table(paste(dir,"/data/expression/Paternal_gene_normalized.txt", sep=""),  check.names = F)
genes <- rownames(maternal)


maternal2 <- as.matrix(maternal)
paternal2 <- as.matrix(paternal)

tstat <- function(pdiff, odiff) {
  T = (odiff)^2+(pdiff)^2
  return(T)
}

sig <- function(ptab, otab) {
  pval <- c()
  print(dim(ptab)[1])
  length(pval) <- dim(ptab)[1]
  for (d in 1:dim(ptab)[1]) {
    pval[d] <- as.numeric((length(which(ptab[d,]>otab[d])))/(dim(ptab)[2]))
  }
  return(pvals=pval)
}


permute2 <- function(mtab, ptab, num) {
  vec <- c()
  print(num);
  mm2 <- cbind(rowMeans(mtab, na.rm=TRUE), rowMeans(ptab, na.rm=TRUE))
  diff <- mm2[,1]-mm2[,2]
  print(length(diff))
  vec<- foreach(i=1:num, .export=("permuted_rows_mean"), .combine=data.frame ) %dopar% {
    permean <- permuted_rows_mean(mtab, ptab)
    ((permean$mat-permean$pat)^2)    
  }
  pvals <- sig(vec, (diff^2))
  names(pvals) <- rownames(mm2)
  dir <- sign(diff)
  dir[dir==-1] <- "paternal" #if negative = paternal biased
  dir[dir==1] <- "maternal" #if positive = maternal biased
  list(pvals=pvals, T=diff^2, dir=dir)
}

permuted_rows_mean <- function(mat, pat) {
  b_mm <- matrix(rbinom(nrow(mat) * ncol(mat), 1, 0.5), nrow=nrow(mat), ncol=ncol(mat))
  b_mp <- 1-b_mm
  mat2<-(b_mm*mat)+(b_mp*pat)
  pat2<-(b_mm*pat)+(b_mp*mat)
  ss_m <- apply(mat2, 1, function(x) mean((x), na.rm=T))
  ss_p <- apply(pat2, 1, function(x) mean((x), na.rm=T))
  list(mat=ss_m, pat=ss_p)
}

asym <- permute2(maternal, paternal, 10000)
table <- cbind(asym$pvals, asym$T, asym$dir)
rownames(table) <- names(asym$pvals)

write.table(table, "Asymmetry_10000_07.15.txt", quote = F, row.names = T, col.names = F)

#still0genes <- read.table("/lustre/beagle2/ober/users/smozaffari/ASE/results/tests_asym/still0genes_10000")
#head(still0genes)

#sigenes<- rownames(table)[(which(table[,1]==0))]


#again_mat <- maternal[which(rownames(maternal)%in%still0genes$V1),]
#again_pat <- paternal[which(rownames(paternal)%in%still0genes$V1),]

#asym <- permute2(again_mat,again_pat, 100000)
#table <- cbind(asym$pvals, asym$T, asym$dir)
#rownames(table) <- names(asym$pvals)

#write.table(table, "Asymmetry_p0_100000.txt", quote = F, row.names = T, col.names = F)

stopCluster(cl)

