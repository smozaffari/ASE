#!usr/bin/env/perl

use strict;
use warnings;

my $inputfile=$ARGV[0];


my %chr;
my %start;
my %stop;

open (ANN, "/lustre/beagle2/ober/users/smozaffari/ASE/data/all12_imputed_cgi.annovar_plink_annotations.hg19_multianno.txt") || die "nope: $!";
my $f = <ANN>;
while (my $line = <ANN>) {
    my @line = split "\t", $line;
    my $chr = $line[0];
    my $start = $line[1];
    my $stop = $line[2];
    my $gene = $line[6];
#    if ($gene =~ m/,/) {
    my @genes = split ",", $gene;
    
    foreach my $genex (@genes) {
	if ($genex !~ m/NONE/) {
	    if ($start{$genex}) {
		if ($start < $start{$genex}) {
		    $start{$genex} = $start;
		}
	    } else {
		$start{$genex} = $start;
		$chr{$genex} = $chr;
	    }
	    if ($stop{$genex}) {
		if ($stop > $stop{$genex}) {
		    $stop{$genex} = $stop;
		}
	    } else {
		$stop{$genex} = $stop;
	    }
	}
    }
}
close (ANN);

open (GENE, ">gene_start_stop.txt") || die "nope: $!";
for my $current_gene (keys %start) {
    print GENE (join "\t", $current_gene, $chr{$current_gene}, $start{$current_gene}, $stop{$current_gene}, "\n");
}
close (GENE);

