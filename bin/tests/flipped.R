maternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Maternal_gene_normalized.txt", check.names = F)
paternal <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Paternal_gene_normalized.txt", check.names = F)
genes <- rownames(maternal)
unknown <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Unknown_gene_normalized.txt", check.names = F)
total <- read.table("/group/ober-resources/users/smozaffari/ASE/data/expression/Total_gene_normalized.txt", check.names = F)                


maternal2 <- as.matrix(maternal)
paternal2 <- as.matrix(paternal)

#permute <- function() {
  
#}


#for (i in 1:dim(maternal2)[1]) {
#for (i in 7:7) {
i <- 7
  print( genes[i])
  command <- paste("grep -w ",genes[i], " /group/ober-resources/users/smozaffari/ASE/data/ensemble_table_hg19_05.31  | cut -f2-5,12 | uniq", sep="")
  snps <- try(read.table(text=system(command, intern=TRUE)))
  if (class(snps) =='try-error') {
     snps=NULL
  }
  if (!is.null(snps)) {
  total <- split( snps , f = snps$V5 )
  mins <- sapply( total , function(x) min( x$V4 )+250000 )
  maxs <- sapply( total , function(x) max( x$V4 )+250000 )
  chr <- sapply( total , function(x) unique(x$V1) )
  for (m in 1:length(mins)) {
      c <- substr(chr[m], 4, nchar(as.character(chr[m])))
      print(c);  
#    system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_paternal --chr ",
#              c ," --from-bp ",
#              mins[m], " --to-bp ", maxs[m],
#              " --recode --out /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snppat", names(total)[m] , sep=""))
#    system(paste("plink --bfile /group/ober-resources/users/smozaffari/ASE/data/plinkfiles/Hutterite_maternal --chr ",
#              c ," --from-bp ",
#              mins[m], " --to-bp ", maxs[m],
#              " --recode --out /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], sep=""))
#	      }
    if (file.exists(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m], ".map", sep=""))) {
       pat <- read.table(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snppat", names(total)[m] ".ped" , sep=""))
       mat <- read.table(paste("/group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m] ".ped" , sep=""))
       pat[1:5,1:5]
       Findiv <- substr(as.numeric(mat$V2), 1, nchar(mat$V2)-1)
       genos <- (dim(mat)[2]-6)/2
       print genos
       for (g in 1:genos) {
       	   col <- g+7
       	   gtype <- cbind(Findiv, as.character(pat[,col]), as.character(mat[,col]))
       	   colnames(gtype) <- c("Findiv", "Pat", "Mat")
	   removedgt <- which(!Findiv%in%colnames(maternal))
	   gtype2 <- as.data.frame(gtype[-c(removedgt),])
	   gtype3 <- gtype2[match(colnames(maternal), as.character(gtype2$Findiv)),]
	   gtype3$GG <- paste(gtype3$Pat, gtype3$Mat, sep=":")
	   head(gtype3)
	}

        #lcommand <- (paste("wc -l /group/ober-resources/users/smozaffari/ASE/data/tests_flipped/", chr[m], "_snpmat", names(total)[m],".map", sep=""))
	#lines <- read.table(text=system(command), intern=TRUE)
    	#print (lines)
	#str(lines)
	#print (as.string(as.character(lines)))
    	#num <- strsplit(as.character(lines), " ")
	#print (num[1])
}
}

	      
#mc <- mean(maternal2[i,])
#  pc <- mean(paternal2[i,])
#  T = 
#}
