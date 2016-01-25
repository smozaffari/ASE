#!usr/bin/env/perl

use strict;
use warnings;

open (COD, "/group/ober-resources/users/smozaffari/POeQTL/data/ASE/recodealt.txt") || die "nope: $!";
while (my $line = <COD>) {
    my @line = split " ", $line;
    my $snp = $line[0];
    $ref{$snp} = $line[1];
    $alt{$snp} = $line[2];
    $rs{$snp} = $line[3];
}

open (IMP, ">fakeimpute.txt") || die  "nope: $!";

open (RAW, "/group/ober-resources/users/smozaffari/POeQTL/data/ASE/ ") || die "nope: $!";
my $line1 = <RAW>;
while (my $line = <RAW>) {
    my @line = split " ", $line;
	my $length = $#line;
	my $snp = $line[0];
	my $loc = $line[1];
	if ($ref{$snp}) {
	    print IMP ("--- $rs{$snp} $snp $loc $ref{$snp} $alt{$snp} ");
	}
    foreach my $snp (6 .. $#line) {
	if ($snp = 2) {
	    print IMP ("1 0 0 ");
	} elsif ($snp = 1) {
	    print IMP ("0 1 0 ");
	} elsif ($snp = 0) {
	    print IMP ("0 0 2 0");
	}
    }
    print IMP ("\n");
}
