#!/usr/bin/Rscript

dir <- "/lustre/beagle2/ober/users/smozaffari/ASE"

maternal <- read.table(paste(dir,"/data/expression/Maternal_gene_normalized.txt", sep=""), check.names = F)
paternal <- read.table(paste(dir,"/data/expression/Paternal_gene_normalized.txt", sep=""),  check.names = F)
genes <- rownames(maternal)
genes[i]
unknown <- read.table(paste(dir,"/data/expression/Unknown_gene_normalized.txt", sep=""), check.names = F)
total <- read.table(paste(dir, "/data/expression/Total_gene_normalized.txt", sep=""), check.names = F)                


maternal2 <- as.matrix(maternal)
paternal2 <- as.matrix(paternal)

tstat <- function(tab) {
  s <- split(tab, tab$V3)
  het1p <- mean(na.omit(as.numeric(as.character(unlist(s[[1]][1])))))
  het2p <- mean(na.omit(as.numeric(as.character(unlist(s[[2]][1])))))
  het1m <- mean(na.omit(as.numeric(as.character(unlist(s[[1]][2])))))
  het2m <- mean(na.omit(as.numeric(as.character(unlist(s[[2]][2])))))

  T = (het1m-het2p)^2+(het1p-het2m)^2
  list(h1p=het1p, h2p=het2p, h1m=het1m, h2m=het2m, T=T)
}

sig <- function(vec, newstat) {
  pval <-  (length(which(vec>newstat))+1)/(length(vec)+1)
  list(p=format(pval, scientific=TRUE), t=newstat)
}

permute <- function(tab1,tab2, num) {
  both <-  cbind(maternal,     paternal)
  l <- apply(both, 1, function(x) length(which(!is.na(x))))
  tt <- apply(both, 1, function(x) sample(x, size=length(which(!is.na(x))))

  vec <- NULL
  orig <- tstat(tab)
  true <- orig$T	
  for (n in 1:num) {
    tab1 <- tab[, c(1,2)]
    tab1 <- cbind(tab1, sample(tab$V3))
    colnames(tab1)[3] <- "V3"
    vec <- c(vec, tstat(tab1)$T)
    tab <- tab1
  }
   sig(vec, true)	   
}

print(dim(maternal2)[1])

matmeans <- rowMeans(maternal, na.rm=TRUE)
patmeans <- rowMeans(paternal, na.rm=TRUE)

both <- cbind(maternal, paternal)
tt <- (apply(both, 1, function(x) sample(x, size=length(!is.na(x)))))
l <- apply(tt, 2, function(x) length(which(!is.na(x))))



