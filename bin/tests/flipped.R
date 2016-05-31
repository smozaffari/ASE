pvals <- c()
#names(pvals) <- c()
totalsnps <- c()
totalpeople <- c()
mm <- 0

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

      T = (het1p-het2p)^2+(het1m-het2m)^2
      list(h1p=het1p, h2p=het2p, h1m=het1m, h2m=het2m, T=T)
}

sig <- function(vec, newstat) {
    pval <-  (length(vec<newstat))/(length(vec)+1)
    p2<- sprintf("%.10f",pval)
    return(p2)
}

permute <- function(tab, num) {
	vec <- NULL
	orig <- tstat(tab)
	true <- orig$T	
	for (n in 1:num) {
		tab1 <- tab[, c(sample(c(1,2)),3)]
		tab2 <- tab1[sample(nrow(tab1)),]
	    	vec <- c(vec, tstat(tab2)$T)
	}
	list(vals=vec)
	sig(vec, true)	   
}


#for (i in 1:dim(maternal2)[1]) {
for (i in 1:10) {
#i <- 7
  print( genes[i])
  command <- paste("grep -w ",genes[i], " /group/ober-resources/users/smozaffari/ASE/data/ensemble_table_hg19_05.31  | cut -f2-5,12 | uniq", sep="")
  snps <- try(read.table(text=system(command, intern=TRUE)))
  if (class(snps) =='try-error') {
     snps=NULL
     pvals[mm+1] <- "NA"
     names(pvals)[mm+1] <- genes[i]
     totalsnps[mm+1] <- "NA"
     names(totalsnps)[mm+1] <- genes[i]
  }
  if (!is.null(snps)) {
  total <- split( snps , f = snps$V5 )
  mins <- sapply( total , function(x) min( x$V4 )+250000 )
  maxs <- sapply( total , function(x) max( x$V4 )+250000 )
  chr <- sapply( total , function(x) unique(x$V1) )
  for (m in 1:length(mins)) {
      nn <- i+m-1
      c <- substr(chr[m], 4, nchar(as.character(chr[m])))
      print(c);  
    system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_paternal --chr ",
              c ," --from-bp ",
              mins[m], " --to-bp ", maxs[m],
              " --recode --out /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snppat", names(total)[m] , sep=""))
    system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_maternal --chr ",
              c ," --from-bp ",
              mins[m], " --to-bp ", maxs[m],
              " --recode --out /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], sep=""))
     file <- paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".map", sep="")
    if (file.exists(file)) {
       pat <- read.table(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snppat", names(total)[m], ".ped" , sep=""))
       mat <- read.table(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".ped" , sep=""))
       map <- read.table(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".map" , sep=""))
       Findiv <- substr(as.numeric(mat$V2), 1, nchar(mat$V2)-1)
       genos <- (dim(mat)[2]-6)/2
       totalsnps[nn] <-  genos
       names(totalsnps)[nn] <- names(total)[m]
       for (g in 1:genos) {
       	   col <- g+7
       	   gtype <- cbind(Findiv, as.character(pat[[col]]), as.character(mat[[col]]))
       	   colnames(gtype) <- c("Findiv", "Pat", "Mat")
	   findiv <- sort(Findiv)
	   lostgt <- which(Findiv%in%colnames(maternal))
	   gtype2 <- as.data.frame(gtype[c(lostgt),])
	   maternal424 <- maternal[,c(which(colnames(maternal)%in%Findiv))]
	   paternal424 <- paternal[,c(which(colnames(paternal)%in%Findiv))]
	   mm <- i+m+g-1
	   totalpeople[mm] <- length(which(paternal424[i,]>0))
	   names(totalpeople)[mm] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
	   if (totalpeople[mm] > 10) {
	      print(totalpeople[mm])
	   gtype3 <- gtype2[match(colnames(maternal424), as.character(gtype2$Findiv)),]
	   gtype3$GG <- paste(gtype3$Pat, gtype3$Mat, sep=":")
#	   print(head(gtype3))
	   tgg <- table(gtype3$GG)
	   print(tgg)
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
	   if (length(hets) > 10) {
	   
	   	   new <- as.data.frame(cbind(unlist(c(maternal424[i,hets])), unlist(c(paternal424[i,hets])),unlist(c(gtype3[hets,"GG"]))))
		   mm <- i+m+g-1
	   	   pvals[mm] <- permute(new, 1000)
	#		  print(pvals)
#		print(names(pvals))
#		print(names(total[m]))
		names(pvals)[mm] <- (paste(names(total)[m], map$V1[g], map$V4[g], sep="_"))
#		print(pvals)
	    }
	   write.table(t(pvals), "pvalues.txt", row.names = F, quote = F)
	   }
	}
	}
	} else {
	  totalsnps[mm+1] <- 0
	  names(totalsnps)[mm+1] <- names(total)[m]
	  totalpeople[mm+1] <- 0
	  names(totalpeople)[mm+1] <- names(total)[m]
	 }
	system(paste("rm /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snppat", names(total)[m], ".*" , sep=""))

}
}
}


write.table(t(pvals), "pvalues.txt", quote = F)
write.table(t(totalsnps), "totalsnps.txt", quote=F )
write.table(t(totalpeople), "totalpeople.txt", quote=F )

