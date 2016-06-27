#!/usr/bin/Rscript

dir <- "/lustre/beagle2/ober/users/smozaffari/ASE"

maternal <- read.table(paste(dir,"/data/expression/Maternal_gene_normalized.txt", sep=""), check.names = F)
paternal <- read.table(paste(dir,"/data/expression/Paternal_gene_normalized.txt", sep=""),  check.names = F)
genes <- rownames(maternal)


maternal2 <- as.matrix(maternal)
paternal2 <- as.matrix(paternal)

tstat <- function(obsmean, permean) {
  odiff <- (obsmean[,1]-obsmean[,2])
  pdiff <- (permean[,1]-permean[,2])
  T = (odiff)^2+(pdiff)^2
  list(odiff=odiff, pdiff=pdiff, T=T)
}

sig <- function(ptab, otab) {
  pval <- c()
  length(pval) <- dim(ptab)[2]
  for (d in 1:dim(ptab)[2]) {
    pval[d] <- as.numeric((length(which(ptab[,d]>otab[d]))+1)/(dim(ptab)[1]+1))
  }
  return(pvals=pval)
#  list(p=format(pval, scientific=TRUE), t=otab[d])
}

permuted_mean <- function(tab) {
  tt <- apply(both, 1, function(x) sample(x))
  ss <- apply(tt, 2, function(x) split(na.omit(x), f=c("mat", "pat")))  
  m <- do.call(rbind.data.frame, (rapply(ss, function(x){mean(x)}, how="list")))
  return(m) 
}


permute <- function(tab1, num) {
  vec <- c()
  mm2 <- cbind(rowMeans(maternal, na.rm=TRUE), rowMeans(paternal, na.rm=TRUE))
  diff <- mm2[,1]-mm2[,2]
  for (n in 1:num) {
      permean<- permuted_mean(tab1)
#      vec <- rbind(vec, tstat(mm2, permean)$T)
       vec <- rbind(vec, (permean[,1]-permean[,2]))
  }
  pvals <- sig(vec, (diff))
  names(pvals) <- rownames(mm2) 
  dir <- sign(diff)
  dir[dir==-1] <- "paternal"
  dir[dir==1] <- "maternal"
  #if positive = maternal biased
  #if negative = paternal biased
  list(pvals=pvals, diff=diff, dir=dir)
}


print(dim(maternal2)[1])

matmeans <- rowMeans(maternal, na.rm=TRUE)
patmeans <- rowMeans(paternal, na.rm=TRUE)

both <-  cbind(maternal,     paternal)
l <- apply(both, 1, function(x) length(which(!is.na(x))))

asym <- permute(both, 1000)
table <- cbind(asym$pvals, asym$diff, asym$dir)
rownames(table) <- names(asym$pvals)
write.table(table, "Asymmetry_1000.txt", quote = F, row.names = T, col.names = F)




