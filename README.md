# ASE


1. Fastq files (Darren) 
[RNAseq 500HT Project](https://oberlab-tk.uchicago.edu/wiki/Hutterites/RNAseq%20500HT%20Project)
   * single end
   * `/lustre/beagle2/ober/resources/RNASeq__500HT`
   * FlowCell/FINDIV/lane.index.sequence 
    
2. Process all the reads (ignore rescued reads) and put into output Directory : 
   * Trim adaptors with cutadapt
   * Map to hg19 using bowtie2
   * WASP to remove mapping bias
   * findsnps.py to separate maternal and paternal reads
   * Add back in sex chromosome genes
   * HTSeq-count to count genes
   * `master2.sh <inputDir> <outDir> <SNPDir> <FlowCell> `
   * `../bin/scripts/master2.sh /lustre/beagle2/ober/resources/RNASeq__500HT withoutsaved/ ../data/SNP_files/ FlowCell2`

3. count matrix
    * analysis_1.pbs
    * ls -ld withoutsaved/*/*/* | grep index | grep trim | cut -f11 -d" " | cut -f2-4 -d"/" | sed 's/\.sequence\.trim\.txt//g' > lane_and_index
    * ls -ld withoutsaved/*/*/* | grep index | grep trim | cut -f11 -d" " | cut -f2-4 -d"/" | sed 's/\.sequence\.trim\.txt//g' | sed 's/\//\./g' > lane_and_index2
    * s -ld withoutsaved/*/*/* | grep index | grep trim | cut -f11 -d" " | cut -f2-4 -d"/" | sed 's/\.sequence\.trim\.txt//g' | sed 's/\//\./g' | sed 's/\./\ /g' | sed 's/lane_//g' | sed 's/index_//g' >lane_and_index3

