#!/usr/bin/perl
use strict;
use warnings;
my $hacer = $ARGV[0];
my $crossmap = $ARGV[1];
if(@ARGV<2){
    print STDERR "perl program hacer crossmap_results(T1_hg19ToHg38.bed3)\n";die;
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
    my $info = $FANTOM5."\t".$VISTA."\t".$Ensembl."\t".$Encode."\t".$ChromHMM."\t";
    $info .= $associated_gene_FANTOM5."\t".$associated_gene_50kb."\t".$associated_gene_4DGenome."\t";
    $info .= $cell_tissue_gene."\t".$Detection_method."\t".$PMID."\t".$closest_gene."\t".$distance."\t";
    $info .= $Technique_enhancer."\t".$celltype_enhancer."\t".$source_enhancer."\t".$Normalized_count."\t".$density;
    $hacer_mapping{$id} = $info;
}
close HACER;

#output
#Chr Start End Enhancer_ID
my $output = $crossmap."_annotation_DB";
open OUT,">",$output;
print OUT "Chr\tStart\tEnd\tHacer_ID\tFANTOM5\tVISTA\tEnsembl\tEncode\tChromHMM\t";
print OUT "associated_gene_FANTOM5\tassociated_gene_50kb\tassociated_gene_4DGenome\t";
print OUT "cell_tissue_gene\tDetection_method\tPMID\tclosest_gene\tdistance\t";
print OUT "Technique_enhancer\tcelltype_enhancer\tsource_enhancer\tNormalized_count\tdensity\n";
open CROSSMAP,"<",$crossmap;
while($line=<CROSSMAP>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    my $start;
    my $end;
    my $id;
    my $hacer_info;
    if(($chr ne 'chr1')and($chr ne 'chr2')and($chr ne 'chr3')and($chr ne 'chr4')and($chr ne 'chr5')and($chr ne 'chr6')
    and($chr ne 'chr7')and($chr ne 'chr8')and($chr ne 'chr9')and($chr ne 'chr10')and($chr ne 'chr11')and($chr ne 'chr12')
    and($chr ne 'chr13')and($chr ne 'chr14')and($chr ne 'chr15')and($chr ne 'chr16')and($chr ne 'chr17')and($chr ne 'chr18')
    and($chr ne 'chr19')and($chr ne 'chr20')and($chr ne 'chr21')and($chr ne 'chr22')and($chr ne 'chrX')and($chr ne 'chrY')
    and($chr ne 'chrM')){
        next;
    }else{
        $start = $ele[1];
        $end = $ele[2];
        $id = $ele[3];
        if($hacer_mapping{$id}){
            $hacer_info = $hacer_mapping{$id};
            print OUT $chr."\t".$start."\t".$end."\t".$id."\t".$hacer_info."\n";
        }
    }
}
close CROSSMAP;
close OUT;

