1. Fastq files (Darren) 
[RNAseq 500HT Project](https://oberlab-tk.uchicago.edu/wiki/Hutterites/RNAseq%20500HT%20Project)
   * single end
   * `/lustre/beagle2/ober/resources/RNASeq__500HT`
   * FlowCell/FINDIV/lane.index.sequence 
  
1. Process RNA seq data
 `master2.sh <inputDir> <outDir> <SNPDir> <FlowCell> `    

   * (ignore rescued reads `saved.sequence`)
   * Trim adaptors with cutadapt (keep reads > 5bp)
   * Map to hg19 using star
   * WASP to remove mapping bias
   * findsnps_new.py to separate maternal and paternal reads
   * Add back in sex chromosome genes
   * HTSeq-count to count genes
   * `../bin/scripts/master2.sh /lustre/beagle2/ober/resources/RNASeq__500HT star_overhang_v19/ ../data/SNP_files/ FlowCell2`

2. Get gene count matrix
    `qsub analysis_1.pbs`
    * need 
    * ` ls -ld star_overhang/*/*/* | grep index | grep trim | cut -f2-4 -d"/"  | sed 's/\.sequence\.trim\.txt//g' | sed 's/\//\./g' | sed 's/\./\ /g' | sed 's/lane_//g' | sed 's/index_//g' | sed 's/FlowCell//g' >li_6` 

3. QC on gene count matrix
    * `RNA_Seq_qc_star_overhang.Rmd`
    * need `new_FC_<FC#>` files, gene count matrices, and li_6 (output from analysis_1.pbs)

(4. POreads)
    * `cut -f1-4 -d" "  star_overhang/FlowCell1/4972/4972_lane_6_ASE_info | grep -v D7LYM | sort -k1.4,1n -k2,2n -t" " | uniq -c | grep -v indel  | grep -v some >4972_lane6_POreads`
