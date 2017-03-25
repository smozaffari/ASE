
import sys
import os
import gzip
import argparse
import numpy as np

import pysam

import util
import snptable

import tables

MAX_SEQS_DEFAULT = 64
MAX_SNPS_DEFAULT = 6


class DataFiles(object):
    """Object to hold names and filehandles for all input / output 
    datafiles"""
    
    def __init__(self, bam_filename, is_sorted,
                 output_dir=None, snp_dir=None):

        # prefix for output files
        self.prefix = None

        # name of input BAM filename
        self.bam_filename = bam_filename        
        # name of sorted input bam_filename
        # (new file is created if input file is not
        #  already sorted)
        self.bam_sort_filename = None
        # pysam file handle for input BAM
        self.input_bam = None

        # name of output keep and to.remap BAM files
        self.maternal_filename = None
        self.paternal_filename = None
        self.hom_filename = None

        # pysam file handles for output BAM filenames
        self.maternal_bam = None
        self.paternal_bam = None
        self.hom_bam = None

        # name of directory to read SNPs from
        self.snp_dir = snp_dir

            
        # separate input directory and bam filename
        tokens = self.bam_filename.split("/")
        bam_dir = "/".join(tokens[:-1])
        filename = tokens[-1]

        if output_dir is None:
            # if no output dir specified, use same directory as input
            # bam file
            output_dir = bam_dir
        else:
            if output_dir.endswith("/"):
                # strip trailing '/' from output dir name
                output_dir = output_dir[:-1]
                
        name_split = filename.split(".")
        if len(name_split) > 1:
           self.prefix = output_dir + "/" + ".".join(name_split[:-1])
        else:
            self.prefix = output_dir + "/" + name_split[0]
            
        # TODO: could allow names of output files to be specified
        # on command line rather than appending name to prefix
        sys.stderr.write("prefix: %s\n" % self.prefix)
        
        if not is_sorted:
            util.sort_bam(self.bam_filename, self.prefix)
            self.bam_sort_filename = self.prefix + ".sort.bam"
        else:
            self.bam_sort_filename = self.bam_filename

        self.maternal_filename = self.prefix + ".maternal.bam"
        self.paternal_filename = self.prefix + ".paternal.bam"
        self.hom_filename = self.prefix + ".hom.bam"

        sys.stderr.write("reading reads from:\n  %s\n" %
                         self.bam_sort_filename)
        
        sys.stderr.write("writing output files to:\n")
        

        self.input_bam = pysam.Samfile(self.bam_sort_filename, "rb")
        self.hom_bam = pysam.Samfile(self.hom_filename, "wb",
                                  template=self.input_bam)

        self.maternal_bam = pysam.Samfile(self.maternal_filename, "wb",
                                      template=self.input_bam)
        self.paternal_bam = pysam.Samfile(self.paternal_filename, "wb",
                                       template=self.input_bam)

        sys.stderr.write("  %s\n  %s\n %s\n" % (self.hom_filename, 
                                           self.maternal_filename,
                                           self.paternal_filename))                         


    
        
    def close(self):
        """close open filehandles"""
        filehandles = [self.maternal_bam, self.paternal_bam, self.hom_bam]

        for fh in filehandles:
            if fh:
                fh.close()

        
class ReadStats(object):
    """Track information about reads and SNPs that they overlap"""

    def __init__(self):
        # number of read matches to reference allele
        self.mat_count = 0
        # number of read matches to alternative allele
        self.pat_count = 0
        self.hom_count = 0
        # number of reads that overlap SNP but match neither allele
        self.other_count = 0

        # number of reads discarded becaused not mapped
        self.discard_unmapped = 0

        # number of reads discarded because overlap an indel
        self.discard_indel = 0

        # number of reads discarded because secondary match
        self.discard_secondary = 0

        # number of reads discarded because of too many overlapping SNPs
        self.discard_excess_snps = 0
        
        # number of reads discarded because too many allelic combinations
        self.discard_excess_reads = 0
        
        # number of maternal reads
        self.maternal_single = 0

        # number of paternal reads
        self.paternal_single = 0

        # number of homozygous reads
        self.hom_single = 0


    def write(self, file_handle):
        sys.stderr.write("DISCARD reads:\n"
                         "  unmapped: %d\n"
                         "  indel: %d\n"
                         "  secondary alignment: %d\n"
                         "  excess overlapping snps: %d\n"
                         "  excess allelic combinations: %d\n"
                         "PO reads:\n"
                         "  maternal: %d\n"
                         "  paternal: %d\n"
                         "hom reads:\n"
                         "  hom_single: %d\n"  %
                         (self.discard_unmapped,
                          self.discard_indel,
                          self.discard_secondary,
                          self.discard_excess_snps,
                          self.discard_excess_reads,
                          self.maternal_single,
                          self.paternal_single,
                          self.hom_single))

        file_handle.write("read SNP mat matches: %d\n" % self.mat_count)
        file_handle.write("read SNP pat matches: %d\n" % self.pat_count)
        file_handle.write("read SNP mismatches: %d\n" % self.other_count)
        
        total = self.mat_count + self.pat_count + self.other_count
        if total > 0:
            mismatch_pct = 100.0 * float(self.other_count) / total
            if mismatch_pct > 10.0:
                sys.stderr.write("WARNING: many read SNP overlaps do not match "
                                 "either allele (%.1f%%). SNP coordinates "
                                 "in input file may be incorrect.\n" %
                                 mismatch_pct)
    



def parse_options():
    
    parser = argparse.ArgumentParser(description="Looks for SNPs and indels "
                                     "overlapping reads. If a read overlaps "
                                     "SNPs, alternative versions of the read "
                                     "containing different alleles are created "
                                     "and written to files for remapping. "
                                     "Reads that do not overlap SNPs or indels "
                                     "are written to a 'keep' BAM file."
                                     "Reads that overlap indels are presently "
                                     "discarded.")
                                   

    parser.add_argument("--is_paired_end", "-p", action='store_true',
                        dest='is_paired_end', 
                        default=False,
                        help=("Indicates that reads are paired-end "
                              "(default is single)."))
    
    parser.add_argument("--is_sorted", "-s", action='store_true',
                        dest='is_sorted', 
                        default=False,
                        help=('Indicates that the input BAM file'
                              ' is coordinate-sorted (default '
                              'is False).'))
    
    parser.add_argument("--max_seqs", type=int, default=MAX_SEQS_DEFAULT,
                        help="The maximum number of sequences with different "
                        "allelic combinations to consider remapping "
                        "(default=%d). Read pairs with more allelic "
                        "combinations than MAX_SEQs are discarded" %
                        MAX_SEQS_DEFAULT)

    parser.add_argument("--max_snps", type=int, default=MAX_SNPS_DEFAULT,
                        help="The maximum number of SNPs allowed to overlap "
                        "a read before discarding the read. Allowing higher "
                        "numbers will decrease speed and increase memory "
                        "usage (default=%d)."
                         % MAX_SNPS_DEFAULT)
    
    parser.add_argument("--output_dir", default=None,
                        help="Directory to write output files to. If not "
                        "specified, output files are written to the "
                        "same directory as the input BAM file.")

    parser.add_argument("--snp_dir", action='store', 
                        help="Directory containing SNP text files "
                        "This directory should contain one file per "
                        "chromosome named like chr<#>.snps.txt.gz. "
                        "Each file should contain 3 columns: position "
                        "RefAllele AltAllele. This option should "
                        "only be used if --snp_tab, --snp_index, "
                        "and --haplotype arguments are not used."
                        " If this argument is provided, all possible "
                        "allelic combinations are used (rather "
                        "than set of observed haplotypes).",
                        default=None)
        

    parser.add_argument("--snp_tab",
                        help="Path to HDF5 file to read SNP information "
                        "from. Each row of SNP table contains SNP name "
                        "(rs_id), position, allele1, allele2.",
                        metavar="SNP_TABLE_H5_FILE",
                        default=None)
    
    parser.add_argument("--snp_index",
                        help="Path to HDF5 file containing SNP index. The "
                        "SNP index is used to convert the genomic position "
                        "of a SNP to its corresponding row in the haplotype "
                        "and snp_tab HDF5 files.",
                        metavar="SNP_INDEX_H5_FILE",
                        default=None)
    
    parser.add_argument("--haplotype",
                        help="Path to HDF5 file to read phased haplotypes "
                        "from. When generating alternative reads "
                        "use known haplotypes from this file rather "
                        "than all possible allelic combinations.",
                        metavar="HAPLOTYPE_H5_FILE",
                        default=None)

    parser.add_argument("--samples",
                        help="Use only haplotypes and SNPs that are "
                        "polymorphic in these samples. "
                        "SAMPLES can either be a comma-delimited string "
                        "of sample names or a path to a file with one sample "
                        "name per line (file is assumed to be whitespace-"
                        "delimited and first column is assumed to be sample "
                        "name). Sample names should match those present in the "
                        "--haplotype file. Samples are ignored if no haplotype "
                        "file is provided.",
                        metavar="SAMPLES")
                        
    parser.add_argument("bam_filename", action='store',
                        help="Coordinate-sorted input BAM file "
                        "containing mapped reads.")
    
        
    options = parser.parse_args()

    if options.snp_dir:
        if(options.snp_tab or options.snp_index or options.haplotype):
            parser.error("expected --snp_dir OR (--snp_tab, --snp_index and "
                         "--haplotype) arguments but not both")
    else:
        if not (options.snp_tab and options.snp_index and options.haplotype):
            parser.error("either --snp_dir OR (--snp_tab, "
                         "--snp_index AND --haplotype) arguments must be "
                         "provided")
    
    if options.samples and not options.haplotype:
        # warn because no way to use samples if haplotype file not specified
        sys.stderr.write("WARNING: ignoring --samples argument "
                         "because --haplotype argument not provided")

    return options

        


def count_ref_alt_matches(read, read_stats, snp_tab, snp_idx, read_pos, files, cur_chrom):
    mat_alleles = snp_tab.snp_allele1[snp_idx]
    pat_alleles = snp_tab.snp_allele2[snp_idx]
    
    for i in range(len(snp_idx)):
        if mat_alleles[i] == pat_alleles[i]:
            #if maternal = paternal it is a homozygous read
            read_stats.hom_count +=1
            files.hom_bam.write(read)
            print  cur_chrom, snp_idx,  read.query_sequence[read_pos[i]-1], i, "hom", read_pos, read.query_sequence
        else:
            if mat_alleles[i] == read.query_sequence[read_pos[i]-1]:
                # read matches reference allele
                read_stats.mat_count += 1
                #output to maternal.bam file.
                files.maternal_bam.write(read)
                print  cur_chrom, snp_idx,  mat_alleles[i], i, "mat", read_pos, read.query_sequence
            elif pat_alleles[i] == read.query_sequence[read_pos[i]-1]:
                # read matches non-reference allele
                read_stats.pat_count += 1
                #output to maternal.bam file.
                files.paternal_bam.write(read)
                print  cur_chrom, snp_idx,  pat_alleles[i], i, "pat", read_pos, read.query_sequence
                
            else:
                # read matches neither ref nor other
                read_stats.other_count += 1
                
    
def filter_reads(files, max_seqs=MAX_SEQS_DEFAULT, max_snps=MAX_SNPS_DEFAULT,
                 samples=None):
    cur_chrom = None
    cur_tid = None
    seen_chrom = set([])

    snp_tab = snptable.SNPTable()
    read_stats = ReadStats()
    read_pair_cache = {}
    cache_size = 0
    read_count = 0
    
    for read in files.input_bam:
        read_count += 1
        # if (read_count % 100000) == 0:
        #     sys.stderr.write("\nread_count: %d\n" % read_count)
        #     sys.stderr.write("cache_size: %d\n" % cache_size)

        # TODO: need to change this to use new pysam API calls
        # but need to check pysam version for backward compatibility
        if read.tid == -1:
            # unmapped read
            read_stats.discard_unmapped += 1
            continue
        
        if (cur_tid is None) or (read.tid != cur_tid):
            # this is a new chromosome
            cur_chrom = files.input_bam.getrname(read.tid)
            if len(read_pair_cache) != 0:
                sys.stderr.write("WARNING: failed to find pairs for %d "
                                 "reads on this chromosome\n" %
                                 len(read_pair_cache))
                read_stats.discard_missing_pair += len(read_pair_cache)
            read_pair_cache = {}
            cache_size = 0
            read_count = 0
            
            if cur_chrom in seen_chrom:
                # sanity check that input bam file is sorted
                raise ValueError("expected input BAM file to be sorted "
                                 "but chromosome %s is repeated\n" % cur_chrom)
            seen_chrom.add(cur_chrom)
            cur_tid = read.tid
            sys.stderr.write("starting chromosome %s\n" % cur_chrom)

            # use HDF5 files if they are provided, otherwise use text
            # files from SNP dir
            
            snp_filename = "%s/%s.snps.txt.gz" % (files.snp_dir, cur_chrom)
            sys.stderr.write("reading SNPs from file '%s'\n" % snp_filename)
            snp_tab.read_file(snp_filename)
            
            sys.stderr.write("processing reads\n")

        if read.is_secondary:
            # this is a secondary alignment (i.e. read was aligned more than
            # once and this has align score that <= best score)
            read_stats.discard_secondary += 1
            continue


        process_single_read(read, read_stats, files, snp_tab,
                            max_seqs, max_snps, cur_chrom)
        
    read_stats.write(sys.stderr)
                     

def process_single_read(read, read_stats, files, snp_tab, max_seqs,
                        max_snps, cur_chrom):
    """Check if a single read overlaps SNPs or indels, and writes
    this read (or generated read pairs) to appropriate output files"""
                
    # check if read overlaps SNPs or indels
    snp_idx, snp_read_pos, \
        indel_idx, indel_read_pos = snp_tab.get_overlapping_snps(read)

    
    if len(indel_idx) > 0:
        # for now discard this read, we want to improve this to handle
        # the indel reads appropriately
        read_stats.discard_indel += 1
        # TODO: add option to handle indels instead of throwing out reads
        return

    if len(snp_idx) > 0:
        mat_alleles = snp_tab.snp_allele1[snp_idx]
        pat_alleles = snp_tab.snp_allele2[snp_idx]

        count_ref_alt_matches(read, read_stats, snp_tab, snp_idx,
                              snp_read_pos, files, cur_chrom)

        # limit recursion here by discarding reads that
        # overlap too many SNPs
        if len(snp_read_pos) > max_snps:
            read_stats.discard_excess_snps += 1
            return

#        mat_seqs, pat_seqs = generate_reads(read.query_sequence,  0)

        # make set of unique reads, we don't want to remap
        # duplicates, or the read that matches original
#        unique_reads = set(read_seqs)
#        if read.query_sequence in unique_reads:
#            unique_reads.remove(read.query_sequence)
        
#        if len(unique_reads) == 0:
            # only read generated matches original read,
            # so keep original
#            files.maternal_bam.write(mat_seqs)
#            read_stats.maternal_single += 1
#        elif len(unique_reads) < max_seqs:
#            # write read to fastq file for remapping
#            write_fastq(files.fastq_single, read, unique_reads)

            # write read to 'to remap' BAM
            # this is probably not necessary with new implmentation
            # but kept for consistency with previous version of script
#            files.paternal_bam.write(pat_seqs)
#            read_stats.paternal_single += 1
#        else:
            # discard read
#            read_stats.discard_excess_reads += 1
 #           return

    else:
        # no SNPs overlap read, write to keep file
        files.hom_bam.write(read)
        read_stats.hom_single += 1
            



        
def main(bam_filenames,
         is_sorted=False, max_seqs=MAX_SEQS_DEFAULT,
         max_snps=MAX_SNPS_DEFAULT, output_dir=None,
         snp_dir=None):

    files = DataFiles(bam_filenames,  is_sorted, 
                      output_dir=output_dir,
                      snp_dir=snp_dir)
    
    filter_reads(files, max_seqs=max_seqs, max_snps=max_snps)

    files.close()
    
    

if __name__ == '__main__':
    sys.stderr.write("command line: %s\n" % " ".join(sys.argv))
    sys.stderr.write("python version: %s\n" % sys.version)
    sys.stderr.write("pysam version: %s\n" % pysam.__version__)

    util.check_pysam_version()
        
    options = parse_options()
    
    main(options.bam_filename,
         is_sorted=options.is_sorted,
         max_seqs=options.max_seqs, max_snps=options.max_snps,
         output_dir=options.output_dir,
         snp_dir=options.snp_dir)
         
    
