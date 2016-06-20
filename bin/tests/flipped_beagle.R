#!/usr/bin/Rscript

args = commandArgs(trailingOnly=TRUE)
i <- as.numeric(args[1])
dir <- "/lustre/beagle2/ober/users/smozaffari/ASE"
print(i)
print(getwd())
pvals <- c()
totalsnps <- c()
totalpeople <- c()
totalhets <- c()
tvals <- c()
mm <- 0

snpcount <- 1;
genecount <- 0;

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

permute <- function(tab, num) {
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

  i <- as.numeric(args[1])
  print(i)
  print(genes[i])
  genecount <- genecount+1
  command <- paste("grep -w ",genes[i], " ",dir,"/data/ensemble_table_hg19_05.31  | grep -v \"_\" | cut -f2-5,12 | uniq", sep="")
  print(command);
  snps <- try(read.table(text=system(command, intern=TRUE)))
  head(snps)
  if (class(snps) =='try-error') {
    snps=NULL	
    pvals[snpcount] <- "NA"
    names(pvals)[snpcount] <- genes[i]
    tvals[snpcount] <- "NA"
    names(tvals)[snpcount] <- genes[i]
    totalsnps[genecount] <- "NA"
    names(totalsnps)[genecount] <- genes[i]
    totalpeople[snpcount] <- "NA"
    names(totalpeople)[snpcount] <- genes[i]
    totalhets[snpcount] <- "NA"
    names(totalhets)[snpcount] <- genes[i]
    snpcount <- snpcount+1
  }
  if (!is.null(snps)) {
    total <- split( snps , f = snps$V5 )
    print(total)
    mins <- sapply( total , function(x) min( x$V3 )-250000 )
    maxs <- sapply( total , function(x) max( x$V4 )+250000 )
    chr <- sapply( total , function(x) unique(x$V1) )
    totmatch <- length(total)
    for (m in 1:totmatch) {
      c <- substr(chr[m], 4, nchar(as.character(chr[m])))
      system(paste("plink-1.9 --bfile ",dir,"/data/plinkfiles/Hutterite_paternal --chr ", c ," --from-bp ", mins[m], " --to-bp ", maxs[m], " --recode --out ",dir,"/results/tests_flipped/", chr[m], "_snppat", names(total)[m] , sep=""))
      system(paste("plink-1.9 --bfile ",dir,"/data/plinkfiles/Hutterite_maternal --chr ", c ," --from-bp ", mins[m], " --to-bp ", maxs[m], " --recode --out ",dir,"/results/tests_flipped/", chr[m], "_snpmat", names(total)[m], sep=""))
      file <- paste(dir,"/results/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".map", sep="")
      if (file.exists(file)) {
        pat <- read.table(paste(dir, "/results/tests_flipped/", chr[m], "_snppat", names(total)[m], ".ped" , sep=""))
       	mat <- read.table(paste(dir, "/results/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".ped" , sep=""))
       	map <- read.table(paste(dir, "/results/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".map" , sep=""))
       	Findiv <- substr(as.numeric(mat$V2), 1, nchar(mat$V2)-1)
       	genos <- ((dim(mat)[2]-6)/2)
       	totalsnps[genecount] <-  genos
       	names(totalsnps)[genecount] <- names(total)[m]
	for (g in 1:genos) {
	  if (g%%2==0) {
	    g+1
	  }
       	  col <- g+6
       	  gtype <- cbind(Findiv, as.character(pat[[col]]), as.character(mat[[col]]))
       	  colnames(gtype) <- c("Findiv", "Pat", "Mat")
	  findiv <- sort(Findiv)
	  lostgt <- which(Findiv%in%colnames(maternal))
	  gtype2 <- as.data.frame(gtype[c(lostgt),])
	  maternal424 <- maternal[,c(which(colnames(maternal)%in%Findiv))]
	  paternal424 <- paternal[,c(which(colnames(paternal)%in%Findiv))]
	  lots <- length(which(paternal424[i,]>=0))
	  totalpeople[snpcount] <- length(which(paternal424[i,]>=0))
	  names(totalpeople)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
 	  gtype3 <- gtype2[match(colnames(maternal424), as.character(gtype2$Findiv)),]
          gtype3$GG <- paste(gtype3$Pat, gtype3$Mat, sep=":")
          tgg <- table(gtype3$GG)
	  if ( totalpeople[snpcount] >= 10) {
#	    gtype3 <- gtype2[match(colnames(maternal424), as.character(gtype2$Findiv)),]
#	    gtype3$GG <- paste(gtype3$Pat, gtype3$Mat, sep=":")
#	    tgg <- table(gtype3$GG)
	    if (length(levels(gtype3$Mat)< 3)) {
	      if (length(levels(gtype3$Pat) ==3 )) {
	        gtype3$Mat <- factor(gtype3$Mat, levels=levels(gtype3$Pat))
	      }
	    }
	    if (length(levels(gtype3$Pat) < 3)) {
	      if (length(levels(gtype3$Mat) ==3)) {
	        gtype3$Pat <- factor(gtype3$Pat, levels=levels(gtype3$Mat))
	      }
	    }
#	    if (all.equal(levels(gtype3$Pat),  levels(gtype3$Mat))) {
	      
	      hets <- which(!gtype3$Pat==gtype3$Mat)
	      totalhets[snpcount] <- length(hets)
	      names(totalhets)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	       if (length(hets) > 10) {
	         new <- as.data.frame(cbind(unlist(c(maternal424[i,hets])), unlist(c(paternal424[i,hets])),unlist(c(gtype3[hets,"GG"]))))
#		 write.table(new, "ZDBF2.txt", quote = F)
	         per <- permute(new, 1000)
		 print(per$p)
		 print(format(permute(new, 1000), scientific=TRUE))
		 print(format(per$p), scientific=TRUE)
		 print (as.integer(per$p))
	         pvals[snpcount] <- per$p
	         names(pvals)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	         tvals[snpcount] <- per$t 
	         names(tvals)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	       } else {
                 pvals[snpcount] <- 'NA'
                 names(pvals)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
                 tvals[snpcount] <- 'NA'
                 names(tvals)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	       }
	       write.table(t(pvals), "pvalues.txt", row.names = F, quote = F)
#	    } else {
#	      totalhets[snpcount] <- 'NA'
#	      names(totalhets)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
#	    }
	} else {
	  print("not 10 people")
	  print(gtype2$Pat)
	  print(gtype2$Mat)
#	  gtype3 <- gtype2[match(colnames(maternal424), as.character(gtype2$Findiv)),]
#          gtype3$GG <- paste(gtype3$Pat, gtype3$Mat, sep=":")
#	  head(gtype3)
#	  if (all.equal(levels(gtype3$Pat),  levels(gtype3$Mat))) {
	  if (length(levels(gtype3$Mat)< 3)) {
	      if (length(levels(gtype3$Pat) ==3 )) {
	        gtype3$Mat <- factor(gtype3$Mat, levels=levels(gtype3$Pat))
	      }
	    }
	    if (length(levels(gtype3$Pat) < 3)) {
	      if (length(levels(gtype3$Mat) ==3)) {
	        gtype3$Pat <- factor(gtype3$Pat, levels=levels(gtype3$Mat))
	      }
	    }
            hets <- which(!gtype3$Pat==gtype3$Mat)
	    totalhets[snpcount] <- 'NA'
	    names(totalhets)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
#	  }
	}
	snpcount <- snpcount+1
      }
     } else {
       totalsnps[genecount] <- 0
       names(totalsnps)[genecount] <- names(total)[m]
       totalpeople[snpcount] <- 0
       names(totalpeople)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
       pvals[snpcount] <- 'NA'
       names(pvals)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
       tvals[snpcount] <- 'NA'
       names(tvals)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
       totalhets[snpcount] <- 'NA'
       names(totalhets)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
       snpcount <- snpcount+1
     }
     system(paste("rm ",dir,"/results/tests_flipped/", chr[m], "_snppat", names(total)[m], ".*" , sep=""))
   }
 }
#}


pvals2 <- cbind(names(pvals), pvals)
#write.table(pvals2, "pvalues.txt", quote = F, row.names = F)
tvals2 <- cbind(names(tvals), tvals)
#write.table(tvals2, "tvalues.txt", quote = F, row.names = F)
tot2 <- cbind(names(totalsnps), totalsnps)
write.table(tot2, "snps.txt", quote=F, row.names = F )
pp2 <- cbind(names(totalpeople), totalpeople)
#write.table(pp2, "people.txt", quote=F, row.names = F )
het2 <- cbind(names(totalhets), totalhets)
#write.table(het2, "hets.txt", quote = F, row.names = F)

all <- cbind(pp2, totalhets, tvals, pvals)
head(all)
write.table(all, paste(dir, "/results/tests_flipped/summary_",genes[i],".txt", sep=""), quote = F, row.names = F)
