#!/bin/bash
# Author: SVM 

#comple Snp2h5 before

WASP=/lustre/beagle2/ober/users/smozaffari/ASE/bin/scripts/WASP
DATA_DIR=/lustre/beagle2/ober/users/smozaffari/ASE/data/Impute2
MAPPEDREADS=/lustre/beagle2/ober/users/smozaffari/ASE/results/WASP_reads
OUTDIR=/lustre/beagle2/ober/users/smozaffari/ASE/results/CHT
SNP_DIR=/lustre/beagle2/ober/users/smozaffari/ASE/data/SNP_files

$WASP/snp2h5/snp2h5 --chrom $WASP/example_data/chromInfo.hg19.txt \
  --format impute \
  --haplotype $OUTDIR/haplotypes.h5
  --geno_prob $OUTDIR/geno_probs.h5 \
  --snp_index $OUTDIR/snp_index.h5 \
  --snp_tab $OUTDIR/snp_tab.h5 \
  $DATA_DIR/genotypes/chr*_impute.gz \
  $DATA_DIR/haplotypes/chr*_imputehaps.gz
  
$WASP/snp2h5/fasta2h5 --chrom $WASP/example_data/chromInfo.hg19.txt \
  --seq $OUTDIR/seq.h5 \
  /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa
  
python $WASP/CHT/bam2h5.py --chrom $WASP/example_data/chromInfo.hg19.txt
  --haplotype $OUTDIR/haplotypes.h5
  --snp_index $OUTDIR/snp_index.h5 \
  --snp_tab $OUTDIR/snp_tab.h5 \
  --samples \
  --individual \
  --ref_as_counts \
  --alt_as_counts \
  --other_as_counts \
  --read_counts \
  $INDIVIDUAl.chr*.keep.rmdup.bam
  
  
