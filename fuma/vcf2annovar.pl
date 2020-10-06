#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $chr_idx = $ARGV[1];
my $pos_idx = $ARGV[2];
my $ref_idx = $ARGV[3];
my $alt_idx = $ARGV[4];
if(@ARGV < 5){
    print STDERR "perl vcf2annovar.pl input chr_index pos_index ref_index alt_index\n";die;
}
my $output = $input."_annovar";
open IN,"<",$input;
my $line=<IN>;

open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\t".$line;
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[$chr_idx];
    $chr =~ s/chr//;
    my $start = $ele[$pos_idx];
    my $ref = $ele[$ref_idx];
    my $alt = $ele[$alt_idx];
    my $end = $start + length ($ref) -1;
    print OUT $chr."\t".$start."\t".$end."\t".$ref."\t".$alt."\t".$line."\n";
}
close IN;
close OUT;
