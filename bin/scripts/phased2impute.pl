#!usr/bin/env/perl

use strict;
use warnings;


open (IMP, ">fakeimpute.txt") || die  "nope: $!";

open (RAW, "/group/ober-resources/users/smozaffari/POeQTL/data/ASE/ ") || die "nope: $!";
my $line1 = <RAW>;
while (my $line = <RAW>) {
    my @line = split " ", $line;
    foreach my $snp (6 .. $#line) {
	if ($snp = 2) {
	    print IMP ("1 0 0 ");
	} elsif ($snp = 1) {
	    print IMP ("0 1 0 ");
	} elsif ($snp = 0) {
	    print IMP ("0 0 2 0");
	}
    }
}
