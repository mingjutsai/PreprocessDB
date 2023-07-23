#!/usr/bin/perl
use strict;
use warnings;
my $chr_idx = $ARGV[0];
my $pos_idx = $ARGV[1];
my $ref_idx = $ARGV[2];
my $alt_idx = $ARGV[3];
my $pvalue_idx = $ARGV[4];
my $size_idx = $ARGV[5];
my $input = $ARGV[6];
if(@ARGV < 7){
    print STDERR "perl locuszoom_input chr pos ref alt pvalue size input\n";die;
}
my $output = $input."_locuszoom_input.txt";
open OUT,">",$output;
open(IN, "gunzip -c $input |");
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[$chr_idx];
    my $pos = $ele[$pos_idx];
    my $ref = $ele[$ref_idx];
    my $alt = $ele[$alt_idx];
    my $pvalue = $ele[$pvalue_idx];
    my $size = $ele[$size_idx];
    print OUT $chr."\t".$pos."\t".$ref."\t".$alt."\t".$pvalue."\t".$size."\n";
        
    
}
close IN;
close OUT;
