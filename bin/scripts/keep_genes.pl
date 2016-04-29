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
    if ($gene =~ m/;/) {
	my @genes = split ";", $gene;
	my $gene1 = $genes[0];
	my $gene2 = $genes[1];
	if ($start{$gene1}) {
	    if ($start < $start{$gene1}) {
		$start{$gene1} = $start;
	    }
	} else {
	    $start{$gene1} = $start;
	    $chr{$gene1} = $chr;
	}
	if ($stop{$gene1}) {
	    if ($stop > $stop{$gene1}) {
		$stop{$gene1} = $stop;
	    }
	} else {
	    $stop{$gene1} = $stop;
	}


	if ($start{$gene2}) {
            if ($start < $start{$gene2}) {
		$start{$gene2} = $start;
            }
	} else {
	    $start{$gene2} = $start;
	    $chr{$gene1} = $chr;
	}


	if ($stop{$gene2}) {
            if ($stop > $stop{$gene1}) {
		$stop{$gene2} = $stop;
            }
	} else {
	    $stop{$gene2} = $stop;
	}

    } else {
	if ($start{$gene}) {
            if ($start < $start{$gene}) {
		$start{$gene} = $start;
            }
	} else {
	    $start{$gene} = $start;
	    $chr{$gene} = $chr;
	}

	if ($stop{$gene}) {
            if ($stop > $stop{$gene}) {
		$stop{$gene} =$stop;
            }
	} else {
	    $stop{$gene} = $stop;
	}
    }
}
close (ANN);

open (GENE, ">gene_start_stop.txt") || die "nope: $!";
for my $current_gene (keys %start) {
    print GENE (join "\t", $current_gene, $chr{$current_gene}, $start{$current_gene}, $stop{$current_gene}, "\n");
}
close (GENE);

