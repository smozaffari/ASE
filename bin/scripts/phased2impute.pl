#!usr/bin/env/perl
# Author: SVM

use strict;
use warnings;

my %ref;
my %alt;
my %rs;

open (COD, "/group/ober-resources/users/smozaffari/POeQTL/data/ASE/recodealt.txt") || die "nope: $!";
while (my $line = <COD>) {
    my @line = split " ", $line;
    my $snp = $line[0];
    $ref{$snp} = $line[1];
    $alt{$snp} = $line[2];
    $rs{$snp} = $line[3];
}

for (my $i=1; $i<=2; $i++) {
    my $chr = join "", "chr", $i, "_gtype";
    open (RAW, "/group/ober-resources/users/smozaffari/POeQTL/data/ASE/$chr") || die "nope: $!";
    my $out = join "", "chr", $i, "_impute_gtype";
    open (IMP, ">$out") || die "nope: $!";
    my $line1 = <RAW>;
    while (my $line = <RAW>) {
	my @line = split " ", $line;
	my $length = $#line;
	my $snp = $line[0];
	my $loc = $line[1];
	if ($ref{$snp}) {
	    print IMP ("$snp $rs{$snp} $snp $loc $ref{$snp} $alt{$snp} ");
	}
	foreach my $snp (6 .. $#line) {
	    if ($snp == 2) {
		print IMP ("1 0 0 ");
	    } elsif ($snp == 1) {
		print IMP ("0 1 0 ");
	    } elsif ($snp == 0) {
		print IMP ("0 0 1");
	    }
	}
	print IMP ("\n");
    }
}
