#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl gh2annovar.pl input.bed\n";die;
}
my $trans_no = 0;
my $fh;
my $output = $input."_Annovar.txt";
my %gh;
open OUT,">",$output;
open $fh,"<",$input;
while(my $line=<$fh>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $score = $ele[5];
    my $method = $ele[6];
    my $id = $ele[3];
    my $reg_chr = $ele[8];
    my $reg_start = $ele[9];
    my $reg_end = $ele[10];
    my $prom_chr = $ele[13];
    my $prom_start = $ele[14];
    my $prom_end = $ele[15];
    my $gene = $ele[16];
    my $strand = $ele[17];
    if($reg_chr ne $prom_chr){
        $trans_no++;
	next;
    }
    my $info = "reg_range:".$reg_chr.":".$reg_start."-".$reg_end.",score:".$score.",method:".$method.",id:".$id.",gene:".$gene.",gene_range:".$prom_chr.":".$prom_start."-".$prom_end;
    my $pos = $reg_chr."\t".$reg_start."\t".$reg_end;
    if($gh{$pos}){
        $gh{$pos} .= ";".$info;
    }else{
        $gh{$pos} = $info;
    }
}
close $fh;

print STDERR "trans:".$trans_no."\n";
my @key = keys %gh;
foreach my $i (@key){
    print OUT $i."\t".$gh{$i}."\n";
}
