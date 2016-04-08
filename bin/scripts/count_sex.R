#path="~/lustre/beagle2/ober/users/smozaffari/ASE/results/hg19genes_withsex"
path="withoutsaved"

file.names<-  list.files(path,recursive=T,pattern='withsex',full.names=T)

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

write.table(outputfile, "withoutsaved_genes_withsex", row.names = T, col.names = T, quote = F)
