# ASE

following WASP

1. Map reads --> bam files (done by Darren) 
[RNAseq 500HT Project](https://oberlab-tk.uchicago.edu/wiki/Hutterites/RNAseq%20500HT%20Project)
    * single end
    * hg19 (excluding 'random' chr)
    * BWA, less than 3 mismatches: bwa aln -n2
    * `/group/ober-resources/resources/Hutterites/RNAseq_500HT/raw_data/`
    
2. Identify reads with mapping bias
    * find_intersecting_snps.by <.bam> < SNP file directory>
        * chr<#?.snps.txt.gz
        * position refallele altallele
        * `awk -F"\t" '$4=="chr1" { print }' <file> > newfile`
        
3. Map input.remap.fq.gz
    * install BWA (what Darren used) into conda
      * `conda install -c https://conda/binstar.org/judowill bwa`
    * `bwa aln /group/referenceFiles/Homo_Sapiens/UCSC/hg19/sequence/IlluminaBWAIndex/genome.fa -n 2 input.remap.fq.gz`
      * same as Darren allowing for 2 mistmatches
    * `bwa samse -f remappedaga.sam /group/referenceFiles/Homo_Sapiens/UCSC/hg19/sequence/IlluminaBWAIndex/genome.fa remappedagain.sai input.remap.fq.gz`
    
4. Retrieve reads that remapped correctly
    * `python filter_remappedreads.py input.to.remap.bam remappedagain.sam output.bam input.to.remap.mem.gz`
      * 49,207 reads remapped to correct position
    * merge output.bam + input.bam for complete set of mappability filtered aligned reads
    
    
