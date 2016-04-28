#!usr/bin/env/perl

use strict;
use warnings;

my %gene;
my %rs;
my %ann;

open (ANN, "/lustre/beagle2/ober/users/smozaffari/ASE/data/all12_imputed_cgi.annovar_plink_annotations.hg19_multianno.txt") || die "nope: $!";
my $f = <ANN>;
while (my $line = <ANN>) {
    my @line = split "\t", $line;
    my $chr = $line[0];
    my $loc = $line[1];
    $rs{$chr}{$loc} = $line[14];
    $gene{$chr}{$loc} = $line[6];
    $ann{$chr}{$loc} = $line[5];
}


#open (ASE, "/lustre/beagle2/ober/users/smozafari/ASE/results/withoutsaved/FlowCell8/122462/122462_lane_5_ASE_info") || die "nope: $!";
open (ASE, "test_5") || die "nope: $!";                                                                                                        
while (my $line = <ASE>) {
    my @line = split "\t", $line;
    my $chr = $line[0];
    my $snp = $line[1];
    print ( join "\t", $chr, $snp, $rs{$chr}{$snp}, $gene{$chr}{$snp}, $ann{$chr}{$snp}, @line, "\n");
}
close(ASE);
