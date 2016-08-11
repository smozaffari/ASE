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
  pvals <- sig(vec, diff)
  length(pvals)
  names(pvals) <- rownames(mm2)
  dir <- sign(diff)
  dir[dir==-1] <- "paternal" #if negative = paternal biased
  dir[dir==1] <- "maternal" #if positive = maternal biased
  list(pvals=pvals, T=diff^2, dir=dir, vec=vec)
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


permutefiltered <- function(mtab, ptab, num, oldvecs, oldpvals, threshold) {
  vec <- c()
  print(num);
  zero <- which(oldpvals<threshold)
  newmtab <- mtab[zero,]
  newptab <- ptab[zero,]
  newvecs <- oldvecs[zero,]
  mm2 <- cbind(rowMeans(newmtab, na.rm=TRUE), rowMeans(newptab, na.rm=TRUE))
  diff <- mm2[,1]-mm2[,2]
  print(length(diff))
  vec<- foreach(i=1:num, .export=("permuted_rows_mean"), .combine=data.frame ) %dopar% {
    permean <- permuted_rows_mean(newmtab, newptab)
    ((permean$mat-permean$pat)^2)
  }
  bothvecs <- cbind(newvecs, vec)
  pvals <- sig(bothvecs, diff)
  names(pvals) <- rownames(mm2)
  dir <- sign(diff)
  dir[dir==-1] <- "paternal" #if negative = paternal biased
  dir[dir==1] <- "maternal" #if positive = maternal biased
  list(pvals=pvals, T=diff^2, dir=dir, vec=bothvecs, newmaternal=newmtab, newpaternal=newptab)
}

asym <- permute2(maternal2, paternal2, 10000)
table <- cbind(asym$pvals, asym$T, asym$dir, asym$vec)
rownames(table) <- names(asym$pvals)
  
write.table(table, "Asymmetry_10000_08.08_11_all.txt", quote = F, row.names = T, col.names = F)

asym$newmaternal <- maternal2
asym$newpaternal <- paternal2
asym2 <- asym

#for (t in 1:5) {
while (length(asym2$pvals) > 10) {
  asym2 <- permutefiltered(asym2$newmaternal, asym2$newpaternal, 10000, asym2$vec, asym2$pvals, 0.5)
  table <- cbind(asym2$pvals, asym2$T, asym2$dir, asym2$vec)
  rownames(table) <- names(asym2$T)
  t <- length(asym2$pvals)
  write.table(table, paste("Asymmetry_10000_08.11_",t,".txt",sep="") , quote = F, row.names = T, col.names = F)
}

stopCluster(cl)