#!usr/bin/env/perl

use strict;
use warnings;

#my %chr;
#my %bp;
#my %snp;

my $input = $ARGV[0];
my $output = $ARGV[1];

open (BIM, "$input.bim") || die "couldn't open: $!";
open (LBED, ">liftover.bed") || die "nope: $!";
while (my $line = <BIM>) {
    my @line = split "\t", $line;
    my $chr = $line[0];
    my $loc = $line[3];
    my $CGI = $line[1];
#    $snp{$chr}{$loc} = $CGI;
    print LBED ("chr",$chr,"\t",$loc,"\t", $loc+1,"\t", $CGI, "\t", $line[2],"\t", $line[4], "\t", $line[5],"\n");
}
close (BIM);
close (LBED);

system('liftOver liftover.bed /home/smozaffari/hg19ToHg38.over.chain.gz lifted.bed unlifted.bed');
#system('grep -v alt lifted.bed | grep -v random | grep -v Un | cut -f4  > snps_extract');
#my @cmd =("plink --bfile $input --extract snps_extract --make-bed --out $output");
#system(@cmd);

open (LIFT, "lifted.bed") || die "nope: $!";
#open (NEWBIM, ">$output.bim") || die "nope: $!";
open (EXTR, ">build38.txt") || die "nope: $!";
open (CHR, ">chr-codes.txt") || die "nope: $!";
while (my $line = <LIFT>) {
    my @line = split "\t", $line;
    my $chr = substr($line[0], 3);
#    print NEWBIM ( join "\t", $chr, $line[3], 0, $line[1], $line[5], $line[6]);
    print EXTR ($line[3],"\t", $line[1],"\n");
    print CHR ($line[3], "\t", $chr, "\n");
}    

my @cmd = ("plink --bfile $input --update-map build38.txt --update-chr chr-codes.txt --make-bed --allow-extra-chr --out $output");
print @cmd;
system(@cmd);

#my @cmd2 = ("plink --bfile $output --update-map chr-codes.txt --update-cm --make-bed --out $output_2");
#system(@cmd2);
