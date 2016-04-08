##  Sahar Mozaffari
## 4.8.16
## To get gene count matrix for gene count for components

# Folder output of RNAseq data is in
path="withoutsaved"

# pattern = ending of file 
patterns = c("withsex", "hom", "maternal", "paternal")
for (val  in 1:length(patterns)) {
    file.names<-  list.files(path,recursive=T,pattern=val,full.names=T)

    outputfile<- NULL
    findiv<- c()
    for(i in 1:length(file.names)) {
    	  file <- read.table(file.names[i], header=F)
	      if (!exists("outputfile")) {
	            outputfile <- file
		    findiv<- c(findiv, unlist(strsplit(file.names[i], "/"))[4])
		     } else {	    
      outputfile <- cbind(outputfile, file$V2)
      findiv<- c(findiv, unlist(strsplit(file.names[i], "/"))[4])
    }
}
str(outputfile)
f2 <- substr(findiv, 1, nchar(findiv)-14)
colnames(outputfile) <- c(f2)

genes <- rownames(file)
rownames(outputfile) <- genes

write.table(outputfile, paste(path, "genecount", val, sep="_"), row.names = T, col.names = T, quote = F)
