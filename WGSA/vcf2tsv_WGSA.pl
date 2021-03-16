#!/usr/bin/perl
use strict;
use warnings;
my $vcf = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl vcf2tsv_WGSA.pl vcf\n";die;
}
my $output = $vcf.".tsv";
open OUT,">",$output;
print OUT "#chr\tpos\tref\talt\tid\n";

open IN,"<",$vcf;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    my $pos = $ele[1];
    my $id = $ele[2];
    my $ref = $ele[3];
    my $alt = $ele[4];
    print OUT $chr."\t".$pos."\t".$ref."\t".$alt."\t".$id."\n";
}
close IN;
close OUT;
