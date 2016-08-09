1. `master2.sh <inputDir> <outDir> <SNPDir> <FlowCell> `    

   * (ignore rescued reads `saved.sequence`)
   * Trim adaptors with cutadapt
   * Map to hg19 using star
   * WASP to remove mapping bias
   * findsnps.py to separate maternal and paternal reads
   * Add back in sex chromosome genes
   * HTSeq-count to count genes
   * `../bin/scripts/master2.sh /lustre/beagle2/ober/resources/RNASeq__500HT star_overhang/ ../data/SNP_files/ FlowCell2`

2. `qsub analysis_1.pbs`
    * make gene count matrix
    * ` ls -ld withoutsaved/*/*/* | grep index | grep trim | cut -f2-4 -d"/"  | sed 's/\.sequence\.trim\.txt//g' | sed 's/\//\./g' | sed 's/\./\ /g' | sed 's/lane_//g' | sed 's/index_//g' | sed 's/FlowCell//g' >lane_and_index3 

4. POreads
    * `cut -f1-4 -d" "  withoutsaved/FlowCell1/4972/4972_lane_6_ASE_info | grep -v D7LYM | sort -k1.4,1n -k2,2n -t" " | uniq -c | grep -v indel  | grep -v some >4972_lane6_POreads`
