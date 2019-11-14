#!/usr/bin/perl
use strict;
use warnings;
my $hacer = $ARGV[0];
my $crossmap = $ARGV[1];
if(@ARGV<2){
    print STDERR "perl program hacer crossmap_results\n";die;
}
my %hacer_mapping;
open HACER,"<",$hacer;
my $line=<HACER>;
chomp $line;
my @ele = split(/\t/,$line);
while($line=<HACER>){
    chomp $line;
    @ele = split(/\t/,$line);
    my $id = $ele[0];
    my $FANTOM5 = $ele[5];
    my $VISTA = $ele[20];
    my $Ensembl = $ele[21];
    my $Encode = $ele[22];
    my $ChromHMM = $ele[23];
    my $associated_gene_FANTOM5 = $ele[6];
    my $associated_gene_50kb = $ele[7];
    my $associated_gene_4DGenome = $ele[8];
    my $cell_tissue_gene = $ele[9];
    my $Detection_method = $ele[10];
    my $PMID = $ele[11];
    my $closest_gene = $ele[12];
    my $distance = $ele[13];
    my $Technique_enhancer = $ele[14];
    my $celltype_enhancer = $ele[15];
    my $source_enhancer = $ele[17];
    my $Normalized_count = $ele[18];
    my $density = $ele[19];
    my $info = 

}
close HACER;

#output
#Chr Start End Enhancer_ID 
