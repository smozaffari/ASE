#!usr/bin/env/perl

use strict;
use warnings;

my %start;
my %stop;
my %chr;

open (ANN, "/lustre/beagle2/ober/users/smozaffari/ASE/results/txstartstop") || die "nope: $!";
while (my $line = <ANN>) {
    my @line = split "\t", $line;
    my $gene = $line[0];
    my $chr = $line[1]
    my $start = $line[2];
    my $stop = $line[3];

    $chr{$gene} = $chr;
    if $start{$gene} {
	if ($start < $start{$gene}) {
	    $start{$gene} = $start;
	}
    } else {
	$start{$gene} = $start;
    }
    if $stop{$gene} {
	if ($stop > $stop{$gene}) {
	    $stop{$gene} = $stop;
	}
    } else {
	$stop{$gene} = $stop;
    }
}
close(ANN);

open (ANN, "/group/ober-resources/users/cigartua/Hutterite_annotation/all_imputed_cgi.annovar_plink_annotations.hg19_multianno.txt") || die "nope: $!";
my $f = <ANN>;
while (my $line = <ANN>) {
    my @line = split "\t", $line;
    my $fakers = $line[44];
    $rs{$fakers} = $line[14];
    $maf{$fakers} = $line[48];
}




open (ASE, "/lustre/beagle2/ober/users/smozafari/ASE/results/withoutsaved/FlowCell8/122462/122462_lane_5_ASE_info") || die "nope: $!";
while (my $line = <ASE>) {
    my @line = split "\t", $line;
    my $chr = $line[0];
    my $snp = $line[1];
    
