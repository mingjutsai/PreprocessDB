#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $chr_idx = $ARGV[1];
my $pos_idx = $ARGV[2];
if(@ARGV < 3){
    print STDERR "perl vcf2annovar.pl input chr_index pos_index\n";die;
}
my $output = $input."_fuma.txt";
open IN,"<",$input;
my $line=<IN>;

open OUT,">",$output;
print OUT $line;
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[$chr_idx];
    $chr =~ s/chr//;
    $ele[$chr_idx] = $chr;
    my $pos = $ele[$pos_idx] + 0;
    $ele[$pos_idx] = $pos;
    my $output = join("\t",@ele);
    print OUT $output."\n";
}
close IN;
close OUT;
