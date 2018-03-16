#!usr/bin/env/perl

use strict;
use warnings;

my %gene;
my %rs;
my %ann;

open (ANN, "/lustre/beagle2/ober/users/smozaffari/vepannotation_genes") || die "nope: $!";
my $f = <ANN>;
while (my $line = <ANN>) {
    my @line = split "\t", $line;
    my $loc = $line[1];
    $rs{$loc} = $line[12];
    $gene{$loc} =$line[14];
    chomp $gene{$loc};
    $ann{$loc} = $line[6];
}

open (FILES, "/lustre/beagle2/ober/users/smozaffari/ASE/results/989_ASE_info_v19") || die "nope: $!";
while (my $fileline = <FILES>) {
    my @findiv_lane = split "/", $fileline;
    my $name = $findiv_lane[3];
    my $fc = $findiv_lane[1];
    chomp $name;
    my $outfile = "out_${fc}_${name}.txt";
    open (OUT, ">ASE_info/$outfile") || die "nope: $!";
    open (ASE, $fileline) || die "nope: $!";
#open (ASE, "/lustre/beagle2/ober/users/smozafari/ASE/results/withoutsaved/FlowCell8/122462/122462_lane_5_ASE_info") || die "nope: $!";
#open (ASE, "test_5") || die "nope: $!";                                                                                                        
    while (my $line = <ASE>) {
	my @line = split " ", $line;
	if ($line[1] =~ m/chr/ ) {
	    my $chr = $line[1];
	    $chr =~ s/\D//g;
	    my $snp = $line[3];
	    my $newsnp = join (":", $chr, $snp);
#	    print $newsnp;
	    print OUT ( join "\t", $fc, $name, $chr, $snp, $rs{$newsnp}, $gene{$newsnp}, $ann{$newsnp}, $line[4], $line[5], $line[7], "\n");
	}
    }
    close (OUT);
    close (ASE);
}
close(FILES);

