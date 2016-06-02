pvals <- c()
totalsnps <- c()
totalpeople <- c()
totalhets <- c()
mm <- 0

snpcount <- 1;
genecount <- 0;

maternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Maternal_gene_normalized.txt", check.names = F)
paternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Paternal_gene_normalized.txt", check.names = F)
genes <- rownames(maternal)
unknown <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Unknown_gene_normalized.txt", check.names = F)
total <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Total_gene_normalized.txt", check.names = F)                


maternal2 <- as.matrix(maternal)
paternal2 <- as.matrix(paternal)

tstat <- function(tab) {
  s <- split(tab, tab$V3)
  het1p <- mean(na.omit(as.numeric(as.character(unlist(s[[1]][1])))))
  het2p <- mean(na.omit(as.numeric(as.character(unlist(s[[2]][1])))))
  het1m <- mean(na.omit(as.numeric(as.character(unlist(s[[1]][2])))))
  het2m <- mean(na.omit(as.numeric(as.character(unlist(s[[2]][2])))))

  T = (het1p-het2p)^2-(het1m-het2m)^2
  list(h1p=het1p, h2p=het2p, h1m=het1m, h2m=het2m, T=T)
}

sig <- function(vec, newstat) {
  pval <-  (length(vec>newstat))/(length(vec)+1)
  p2<- sprintf("%.10f",pval)
  print(p2)
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
#    print(vec, tstat(tab1)$T)
tab <- tab1
  }
#  list(vals=vec)
   sig(vec, true)	   
}

print(dim(maternal2)[1])
#for (i in 1:dim(maternal2)[1]) {
#for (i in 1:20) {
i <- 19232
  print(i)
  print( genes[i])
  genecount <- genecount+1
  command <- paste("grep -w ",genes[i], " /group/ober-resources/users/smozaffari/ASE/data/ensemble_table_hg19_05.31  | cut -f2-5,12 | uniq", sep="")
  snps <- try(read.table(text=system(command, intern=TRUE)))
  head(snps)
  if (class(snps) =='try-error') {
    snps=NULL	
    pvals[snpcount] <- "NA"
    names(pvals)[snpcount] <- genes[i]
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
    mins <- sapply( total , function(x) min( x$V3 )-250000 )
    maxs <- sapply( total , function(x) max( x$V4 )+250000 )
    chr <- sapply( total , function(x) unique(x$V1) )
    totmatch <- length(total)
    for (m in 1:totmatch) {
      genecount <- genecount+m-1
	#      nn <- i+m-1
      c <- substr(chr[m], 4, nchar(as.character(chr[m])))
#      print(c, mins[m], maxs[m])
      system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_paternal --chr ", c ," --from-bp ", mins[m], " --to-bp ", maxs[m], " --recode --out /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snppat", names(total)[m] , sep=""))
      system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_maternal --chr ", c ," --from-bp ", mins[m], " --to-bp ", maxs[m], " --recode --out /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], sep=""))
      file <- paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".map", sep="")
      if (file.exists(file)) {
        pat <- read.table(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snppat", names(total)[m], ".ped" , sep=""))
       	mat <- read.table(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".ped" , sep=""))
       	map <- read.table(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".map" , sep=""))
       	Findiv <- substr(as.numeric(mat$V2), 1, nchar(mat$V2)-1)
       	genos <- ((dim(mat)[2])/2)+6
       	totalsnps[genecount] <-  genos
       	names(totalsnps)[genecount] <- names(total)[m]
	for (g in 1:genos) {
       	  col <- g
       	  gtype <- cbind(Findiv, as.character(pat[[col]]), as.character(mat[[col]]))
       	  colnames(gtype) <- c("Findiv", "Pat", "Mat")
	  findiv <- sort(Findiv)
	  lostgt <- which(Findiv%in%colnames(maternal))
	  gtype2 <- as.data.frame(gtype[c(lostgt),])
	  maternal424 <- maternal[,c(which(colnames(maternal)%in%Findiv))]
	  paternal424 <- paternal[,c(which(colnames(paternal)%in%Findiv))]
	  lots <- length(which(paternal424[i,]>0))
	  totalpeople[snpcount] <- length(which(paternal424[i,]>0))
	  names(totalpeople)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	  if ( totalpeople[snpcount] >= 10) {
	    print(totalpeople[snpcount])
	    gtype3 <- gtype2[match(colnames(maternal424), as.character(gtype2$Findiv)),]
	    gtype3$GG <- paste(gtype3$Pat, gtype3$Mat, sep=":")
	    tgg <- table(gtype3$GG)
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
	    if (all.equal(levels(gtype3$Pat),  levels(gtype3$Mat))) {
	      hets <- which(!gtype3$Pat==gtype3$Mat)
#	      print(hets)
	      totalhets[snpcount] <- length(hets)
	      names(totalhets)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	       if (length(hets) > 10) {
	         new <- as.data.frame(cbind(unlist(c(maternal424[i,hets])), unlist(c(paternal424[i,hets])),unlist(c(gtype3[hets,"GG"]))))
	         pvals[snpcount] <- permute(new, 1000)
	         names(pvals)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	       } else {
                 pvals[snpcount] <- 'NA'
                 names(pvals)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	       }
	       write.table(t(pvals), "pvalues.txt", row.names = F, quote = F)
	    } else {
	      totalhets[snpcount] <- NA
	      names(totalhets)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	    }
	} else {
	  print("not 10 people")
	  if (all.equal(levels(gtype3$Pat),  levels(gtype3$Mat))) {
            hets <- which(!gtype3$Pat==gtype3$Mat)
#	    print(hets)	    
	    totalhets[snpcount] <- length(hets)
	    
	    names(totalhets)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	  }
	}
	snpcount <- snpcount+1
      }
     } else {
       totalsnps[genecount] <- 0
       names(totalsnps)[genecount] <- names(total)[m]
       totalpeople[snpcount] <- 0
       names(totalpeople)[snpcount] <- names(total)[m]
       pvals[snpcount] <- 'NA'
       names(pvals)[snpcount] <- names(total)[m]	  
       totalhets[snpcount] <- 'NA'
       names(totalhets)[snpcount] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
       snpcount <- snpcount+1
     }
     system(paste("rm /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snppat", names(total)[m], ".*" , sep=""))
   }
 }
#}


pvals2 <- cbind(names(pvals), pvals)
write.table(pvals2, "pvalues.txt", quote = F, row.names = F)
tot2 <- cbind(names(totalsnps), totalsnps)
write.table(tot2, "totalsnps.txt", quote=F, row.names = F )
pp2 <- cbind(names(totalpeople), totalpeople)
write.table(pp2, "totalpeople.txt", quote=F, row.names = F )
het2 <- cbind(names(totalhets), totalhets)
write.table(het2, "totalhets.txt", quote = F, row.names = F)
