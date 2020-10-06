#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $indSigSNP_idx = $ARGV[1];
my $fuma_gene = $ARGV[2];
if(@ARGV < 3){
    print STDERR "perl mapping_fuma_genes.pl input indSigSNP_idx fuma_gene\n";die;
}

my $output = $input."_mapping_genes.txt";
open OUT,">",$output;
my %snp_gene;
open GENE,"<",$fuma_gene;
my $line=<GENE>;
while($line=<GENE>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $gene = $ele[1];
    my @snp = split(/;/,$ele[21]);
    foreach my $i (@snp){
       if(!$snp_gene{$i}){
           $snp_gene{$i} = $gene;
       }elsif($snp_gene{$i} !~ /$gene/){
           $snp_gene{$i} .= ",".$gene;
       }
    }
}
close GENE;
open IN,"<",$input;
$line=<IN>;
chomp $line;
print OUT $line."\teQTL_mapping_genes\n";
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $indSigSNP = $ele[$indSigSNP_idx];
    my $mapping_gene;
    if($snp_gene{$indSigSNP}){
        $mapping_gene = $snp_gene{$indSigSNP};
    }else{
        $mapping_gene = "NA";
    }
    print OUT $line."\t".$mapping_gene."\n";
}
close IN;
close OUT;
