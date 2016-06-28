#!/usr/bin/Rscript

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
  length(pval) <- dim(ptab)[2]
  for (d in 1:dim(ptab)[2]) {
    pval[d] <- as.numeric((length(which(ptab[,d]>otab[d])))/(dim(ptab)[1]))
  }
  return(pvals=pval)
}

permute2 <- function(mtab, ptab, num) {
  vec <- c()
  mm2 <- cbind(rowMeans(mtab, na.rm=TRUE), rowMeans(ptab, na.rm=TRUE))
  diff <- mm2[,1]-mm2[,2]
  for (i in 1:num) {
    permean <- permuted_rows_mean(mtab, ptab)
    vec <- rbind(vec, ((permean$mat-permean$pat)^2))
  }
  pvals <- sig(vec, (diff^2))
  names(pvals) <- rownames(mm2)
  dir <- sign(diff)
  dir[dir==-1] <- "paternal" #if negative = paternal biased
  dir[dir==1] <- "maternal" #if positive = maternal biased
  list(pvals=pvals, T=diff^2, dir=dir)
}

permuted_rows_mean <- function(mat, pat) {
  b_mm <- apply(mat, 1, function(x) rbinom(dim(mat)[1], 1, 0.5))
  b_mp <- 1-b_mm
  mat2<-(mat*b_mm)+(pat*b_mp)
  pat2<-(pat*b_mm)+(mat*b_mp)
  ss_m <- apply(mat2, 1, function(x) mean((x), na.rm=T))
  ss_p <- apply(pat2, 1, function(x) mean((x), na.rm=T))
  list(mat=ss_m, pat=ss_p)
}

asym <- permute2(both, 1000)
table <- cbind(asym$pvals, asym$T, asym$dir)
rownames(table) <- names(asym$pvals)

write.table(table, "Asymmetry_10000.txt", quote = F, row.names = T, col.names = F)

sigenes<- rownames(table)[(which(table[,1]==0))]

again_mat <- maternal[genes,]
again_pat <- paternal[genes,]

asym <- permute2(again_mat,again_pat, 100000)
table <- cbind(asym$pvals, asym$T, asym$dir)
rownames(table) <- names(asym$pvals)

write.table(table, "Asymmetry_p0_100000.txt", quote = F, row.names = T, col.names = F)




