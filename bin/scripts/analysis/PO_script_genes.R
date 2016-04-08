#setwd("hg19genes")
path="/lustre/beagle2/ober/users/smozaffari/ASE/results/hg19genes"

allfile.names<- dir(path, pattern="_genes")

outputfile<- NULL
findiv<- c()
for(i in 1:length(allfile.names)) {
    file <- read.table(allfile.names[i], header=F)
    if (!exists("alloutputfile")) {
      alloutputfile <- file
      findiv<- c(findiv, unlist(strsplit(allfile.names[i], "_"))[1])
    } else {
      alloutputfile <- cbind(alloutputfile, file$V2)
      findiv<- c(findiv, unlist(strsplit(allfile.names[i], "_"))[1])
    }
}
colnames(alloutputfile) <- c(findiv)

write.table(alloutputfile, "genecount.noqc", quote = F, row.names = T, col.names = T)