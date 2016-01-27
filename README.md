# ASE

following WASP
##Mapping reads

1. Intial mapping of reads --> bam files (done by Darren) 
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
   

###Creating IMPUTE2 files from PRIMAL(plink) output

1. impute2 haplotype file
   * `awk '{ print $52 " " $4 " " $5 " " $15 }'   /group/ober-resources/users/rlee/hutt_annotation/annotation_data/all12_imputed_cgi.annovar_plink_annotations.hg19_multianno.txt | tail -n+2 > testrecode.txt`

   * `phased2imputehaps.sh`
