#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $gene_name_idx = $ARGV[1];
my $gene_dist_idx = $ARGV[2];
my $gene_region_idx = $ARGV[3];
if(@ARGV < 4){
    print STDERR "perl nearest_gene.pl input gene_idx gene_dist_idx gene_region\n";die;
}
my $output = $input."_nearest_gene";
open OUT,">",$output;
open IN,"<",$input;
my $line=<IN>;
chomp $line;
print OUT $line."\tNearest_gene\n";
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $gene = $ele[$gene_name_idx];
    my $region = $ele[$gene_region_idx];
    my $dist = $ele[$gene_dist_idx];
    $dist =~ s/dist=//g;
    my $nearest_gene;
    if($region eq 'intergenic'){
        my @dist = split(/;/,$dist);
        my @gene = split(/,/,$gene);
        if($gene[0] eq "NONE"){
            $nearest_gene = $gene[1];
        }elsif($gene[1] eq "NONE"){
            $nearest_gene = $gene[0];
        }elsif($dist[0] > $dist[1]){
            $nearest_gene = $gene[1];
       }else{
           $nearest_gene = $gene[0];
       }
    }else{
        $nearest_gene = $gene;
    }
   print OUT $line."\t".$nearest_gene."\n";
}
close IN;
