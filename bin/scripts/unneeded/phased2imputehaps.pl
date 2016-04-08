#!usr/bin/env/perl

use strict;
use warnings;

my %ref;
my %alt;
my %rs;

#for CRI
#open (COD, "/group/ober-resources/users/smozaffari/POeQTL/data/ASE/recodealt.txt") || die "nope: $!";
#for Beagle2
open (COD, "/lustre/beagle2/ober/users/smozaffari/ASE/data/recodealt.txt") || die "nope: $!;
while (my $line = <COD>) {
    my @line = split " ", $line;
    my $snp = $line[0];
    $ref{$snp} = $line[1];
    $alt{$snp} = $line[2];
    $rs{$snp} = $line[3];
}

for (my $i=1; $i<=2; $i++) {
    my $chr = join "", "chr", $i, "_phased";
#   for CRI:
#   open (APED, "/group/ober-resources/users/smozaffari/POeQTL/data/ASE/phased_2_impute/$chr") || die "nope: $!";
#   for Beagle:
    open (APED, "/lustre/beagle2/ober/users/smozaffari/ASE/data/Impute2/haplotypes/$chr") || die "nope: $!;
    my $out = join "", "chr", $i, "_imputehaps";
    open (OUT, ">$out") || die "nope: $!";
    while (my $line = <APED>) {
	my @line = split " ", $line;
	my $length = $#line;
	my $snp = $line[0];
	my $loc = $line[1];
	if ($ref{$snp}) {
	    print OUT ("$snp $rs{$snp} $snp $loc $ref{$snp} $alt{$snp} ");
	    for (my $j=2; $j <= $length; $j++) {
		if ($line[$j]) {
		    if ($line[$j] eq $ref{$snp}) {
			print OUT "0 ";
		    } elsif ($line[$j] eq $alt{$snp}) {
			print OUT "1 ";
		    }
		} else {
		    print OUT "0 ";
		}
	    }
	    print OUT "\n";
	}
    }
}
