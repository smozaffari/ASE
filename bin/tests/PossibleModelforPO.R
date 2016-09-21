maternal<- read.table("Maternal_gene_normalized.txt", check.names = F)
paternal<- read.table("Paternal_gene_normalized.txt", check.names = F)
total <- read.table("Total_gene_normalized.txt", check.names = F)

dim(maternal)
a<- which(rowSums(maternal)==0)
b<- which(rowSums(paternal)==0)
zeros <- which(a%in%b)
length(zeros)

maternal2 <- maternal[-a[zeros],]
paternal2 <- paternal[-a[zeros],]
total2 <- maternal2+paternal2


gene <- "OR5K4"

genetotal <- total2[gene,]
genematernal <- maternal2[gene,]
genepaternal <- paternal2[gene,]

z= (as.numeric(genematernal)-(as.numeric(genetotal)/2))/(as.numeric(genetotal)/2)

plot(density(na.omit(z)))
plot(density(rnorm(20,0,1)), col="red")
lines(density(na.omit(z)))