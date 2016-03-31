for (i in 1:22) {
  system(paste("zcat ../ASE/data/SNP_files/chr",i,".snps.txt.gz | awk '{ print \"chr",i,"\", $1, $1+1, $2, $3 }' > oldchr",i,".bed", sep=""))
  system(paste("liftOver oldchr",i,".bed /home/smozaffari/hg19ToHg38.over.chain.gz newchr",i,".bed chr",i,"_unlifted.bed", sep=""))
  system(paste("cut -f2,4,5 newchr",i,".bed > chr",i,"snps.txt", sep=""))
  system(paste("sed 's/\t/\ /g' chr",i,"snps.txt > chr",i,".snps.txt", sep=""))
  system(paste("gzip chr",i,".snps.txt", sep=""))
} 

system(paste("rm chr*snps.txt"))