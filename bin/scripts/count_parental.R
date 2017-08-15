#!/usr/bin/Rscript

##  Sahar Mozaffari
## 4.8.16
## To get gene count matrix for gene count for components

# Folder output of RNAseq data is in
path="star_overhang_v19"

# pattern = ending of file 
patterns = c( "homaltcount_nodupReadsPerGene.out.tab", "maternalaltcount_nodupReadsPerGene.out.tab", "paternalaltcount_nodupReadsPerGene.out.tab",  "genesaltcount_nodupReadsPerGene.out.tab","withsex_nodupReadsPerGene.out.tab")
ending = c( 17, 22, 22)

for (val  in 1:length(patterns)) {
#val <- 2
    	print (val);
	print (patterns[val]);
	file.names<-  list.files(path,recursive=T,pattern=patterns[val],full.names=T)
#	print(length(file.names))
    	outputfile<- NULL
    	findiv<- c()
    	for(i in 1:length(file.names)) {
	
	     if (file.info(file.names[i])$size >0) {
    		file <- read.table(file.names[i], header=F)
	      	if (!exists("outputfile")) {
	       		outputfile <- file
		    	findiv<- c(findiv, unlist(strsplit(file.names[i], "/"))[4])
		} else {	    
      			outputfile <- cbind(outputfile, file$V2)
			flowcell <- unlist(strsplit(file.names[i], "/"))[2]
			fc <- substr(flowcell, 9, nchar(flowcell))
			fc
			findiv<- c(findiv, paste(fc, unlist(strsplit(file.names[i], "/"))[4], sep="_"))
    		}
	      }
	}
	str(outputfile)
	f2 <- substr(findiv, 1, nchar(findiv)-ending[val])
	f2
	colnames(outputfile) <- c(f2)

	genes <- file$V1
	rownames(outputfile) <- genes

	write.table(outputfile, paste(path, "genecount", patterns[val], "170814_nodup", sep="_"), row.names = T, col.names = T, quote = F)
}
