#!usr/bin/env/perl

# Author: Sahar Mozaffari
# Date: 09/20/16
# Purpose: put together ASE for all of the files - file with file path names hardcoded
# reads from 989_star_overhang_ASE_info - but this file may be too big (submit too many jobs here - consider splitting into two)
# Usage: aprun from ASE_count.pbs (qsubbed from ASE_master.sh (look there for directions))


use strict;
use warnings;

my $inputfile=$ARGV[0];


my %gene;
my %rs;
my %ann;

open (ANN, "/lustre/beagle2/ober/users/smozaffari/ASE/data/all12_imputed_cgi.annovar_plink_annotations.hg19_multianno_Hutterite_AAF.txt") || die "nope: $!";
my $f = <ANN>;
while (my $line = <ANN>) {
    my @line = split "\t", $line;
    my $chr = $line[0];
    my $loc = $line[1];
    $rs{$chr}{$loc} = $line[14];
    $gene{$chr}{$loc} = $line[6];
    $ann{$chr}{$loc} = $line[5];
}

#open (FILES, "/lustre/beagle2/ober/users/smozaffari/ASE/results/test_ASE") || die "nope: $!";
#while (my $fileline = <FILES>) {
my @findiv_lane = split "/", $inputfile;
my $findiv = $findiv_lane[2];
print ("$findiv \n");

my $name = $findiv_lane[1].'_'.$findiv_lane[3];
my $outfile = "out_$name.txt";
open (OUT, ">summarystats_star/$outfile") || die "nope: $!";
open (ASE, $inputfile) || die "nope: $!";
#open (ASE, "/lustre/beagle2/ober/users/smozafari/ASE/results/withoutsaved/FlowCell8/122462/122462_lane_5_ASE_info") || die "nope: $!";
#open (ASE, "test_5") || die "nope: $!";                                                                                                        
while (my $line = <ASE>) {
    my @line = split " ", $line;
    if ($line[0] !~ m/D7LYMFP1/ ) {
	my $chr = $line[0];
	my $snp = $line[1];
	print OUT ( join "\t", $findiv, $chr, $snp, $rs{$chr}{$snp}, $gene{$chr}{$snp}, $ann{$chr}{$snp}, $line[2], $line[3], "\n");
    }
}
close (OUT);
close (ASE);
#}
#close(FILES);

