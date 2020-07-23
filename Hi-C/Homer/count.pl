#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $promoter_index = $ARGV[1];
my $anno_index = $ARGV[2];
my $gene_index = $ARGV[3];
if(@ARGV < 4){
    print STDERR "perl count.pl input promoter_index anno_index gene_index\n";die;
}
my %uniq;
my %pos;
my $output = $input."_uniq";
my %gene;
my %coding_gene;
open OUT,">",$output;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[$promoter_index-3];
    my $start = $ele[$promoter_index-2];
    my $end = $ele[$promoter_index-1];
    my $gene = $ele[$gene_index];
    my $id = $ele[$promoter_index];
    $gene{$id} = $gene;
    $coding_gene{$gene}++;
    my $pos = $chr."\t".$start."\t".$end;
    $pos{$id} = $pos;
    if(!$uniq{$id}){
        $uniq{$id} = $ele[$anno_index];
    }else{
	if($uniq{$id} =~ /$ele[$anno_index]/){
	
	}else{
            $uniq{$id} .= ",".$ele[$anno_index];
        }
    }
    

}
close IN;

my @uniq = keys %uniq;
my $no = scalar @uniq;
my @uniq_gene = keys %coding_gene;
my $gene_no = scalar @uniq_gene;
#my %hic;
print STDERR "promoter no:".$no."\n";
print STDERR "Protein Coding Gene:".$gene_no."\n";
foreach my $i (@uniq){
    my $anno = $uniq{$i};
    #$anno =~ s/,$//;
    print OUT $pos{$i}."\t".$i."\t".$anno."\t".$gene{$i}."\n";
}
close OUT;

