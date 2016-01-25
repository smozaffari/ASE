# ASE

following WASP
##Mapping reads

1. Map reads --> bam files (done by Darren) 
[RNAseq 500HT Project](https://oberlab-tk.uchicago.edu/wiki/Hutterites/RNAseq%20500HT%20Project)
    * single end
    * hg19 (excluding 'random' chr)
    * BWA, less than 3 mismatches: bwa aln -n2
    * `/group/ober-resources/resources/Hutterites/RNAseq_500HT/raw_data/`
    
2. SNPs in SNP directory

    * chr<#>.snps.txt.gz
    * position refallele altallele
    * `awk -F"\t" '$4=="chr1" { print }' <file> > newfile` 


3. to run WASP on all the reads (including remapping reads step) and put into output Directory : 
  
   * `Masterscript.sh <inputDir> <#jobspernode> <#Nodes> <outDir> <SNPDir>`
   

###creating impute2 files

1. impute2 haplotype file
   * `plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/imputed-override3/imputed_cgi.po --geno 0.15 --keep PO_ids --missing --out phasedPO_g0.15_AD_gexppl --recode 12 --transpose` where PO_ids contains parent of origin findivs
      * `geno 0.15` : ~2.8M SNPs
      * `geno 0.10` : ~ 1M SNPs

   * `phased2imputehaps.pl`
   * 
   
2. impute2 genotype file
   * `plink 
   * `phased2impute.pl`
   

   
