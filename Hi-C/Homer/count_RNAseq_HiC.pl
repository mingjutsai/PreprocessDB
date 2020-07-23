#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $promoter_index = $ARGV[1];
my $anno_index = $ARGV[2];
my $gene_index = $ARGV[3];
my $rnaseq_gene_list = $ARGV[4];
if(@ARGV < 5){
    print STDERR "perl count.pl input promoter_index anno_index gene_index RNAseq_genelist\n";die;
}

my %rnaseq_genes;
my %hic_genes;
my %hic_regions;
my %gene;
my %uniq;
my %pos;
open RNA,"<",$rnaseq_gene_list;
while(my $line=<RNA>){
    chomp $line;
    $rnaseq_genes{$line}++;
}
close RNA;
my $output = $input."_uniq";
open OUT,">",$output;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[$promoter_index-3];
    my $start = $ele[$promoter_index-2];
    my $end = $ele[$promoter_index-1];
    my $pos = $chr."\t".$start."\t".$end;
    my $anno_chr = $ele[$anno_index-3];
    my $anno_start = $ele[$anno_index-2];
    my $anno_end = $ele[$anno_index-1];
    my $gene_name = $ele[$gene_index];
    #print STDERR "name:".$gene_name."\n";die;
    my $hic_pos = $anno_chr."-".$anno_start."-".$anno_end;
    #print STDERR "region:".$hic_pos."\n";
    my $hic_id = $ele[$anno_index];
    #print STDERR "hic id:".$hic_id."\n";
    $hic_regions{$hic_id} = $hic_pos;
    if(!$hic_genes{$hic_id}){
        $hic_genes{$hic_id} = $gene_name;
    }else{
        if($hic_genes{$hic_id} =~ /$gene_name/){
	
	}else{
	    $hic_genes{$hic_id} = $gene_name.",";
	}
    }
    $pos{$ele[$promoter_index]} = $pos;
    if(!$uniq{$ele[$promoter_index]}){
        $uniq{$ele[$promoter_index]} = $ele[$anno_index];
    }else{
        $uniq{$ele[$promoter_index]} .= ",".$ele[$anno_index];
    }
    my $promoter_id = $ele[$promoter_index];
    if($gene_name =~ /,/){
        my @list = split(/,/,$gene_name);
	$gene{$list[0]}++;    
	$gene{$list[1]}++;
    }elsif($gene_name =~ /;/){
        my @list = split(/;/,$gene_name);
        $gene{$list[0]}++;
        $gene{$list[1]}++;
    }else{
        $gene{$gene_name}++;
    }

}
close IN;


my @uniq_gene = keys %gene;
my $gene_no = scalar @uniq_gene;
print STDERR "Gene no:".$gene_no."\n";

my @uniq = keys %uniq;
my $no = scalar @uniq;
my %hic;
print STDERR "promoter no:".$no."\n";
foreach my $i (@uniq){
    print OUT $pos{$i}."\t".$i."\t".$uniq{$i}."\n";
    if($uniq{$i} =~ /,/){
        my @ele = split(/,/,$uniq{$i});
	foreach my $i (@ele){
            my @info = split(/_/,$i);
	    my $hic_id = $info[0]."_".$info[1];
	    $hic{$hic_id} = $i;
	}
    }else{
        my @info = split(/_/,$uniq{$i});
            my $hic_id = $info[0]."_".$info[1];
            $hic{$hic_id} = $uniq{$i};
    }
}
close OUT;

my @uniq_hic = keys %hic;
my $hic_no = scalar @uniq_hic;
print STDERR "unique hic:".$hic_no."\n";

my%rnaseq_hic;
my %rnaseq_match_gene;

my $uniq_hic = $input."_unique_promoter_hicbin.txt";
my $uniq_hic_rnaseq = $input."_unique_promoter_rnaseq_hicbin.txt";
open HIC,">",$uniq_hic;
open HICRNA,">",$uniq_hic_rnaseq;
foreach my $i (@uniq_hic){
    my $gene_list = $hic_genes{$hic{$i}};
    $gene_list =~ s/,$//;
    print HIC $i."\t".$hic{$i}."\t".$hic_regions{$hic{$i}}."\t".$gene_list."\n";
    if($gene_list =~ /,/){
        my @gene = split(/,/,$gene_list);
	foreach my $g (@gene){
            if($rnaseq_genes{$g}){
	          $rnaseq_hic{$i}++;
                  $rnaseq_match_gene{$g}++;
		  print HICRNA $i."\t".$hic{$i}."\t".$hic_regions{$hic{$i}}."\t".$g."\n";
	    }	        
	}
    }else{
        if($rnaseq_genes{$gene_list}){
	    $rnaseq_hic{$i}++;
	    $rnaseq_match_gene{$gene_list}++;
            print HICRNA $i."\t".$hic{$i}."\t".$hic_regions{$hic{$i}}."\t".$gene_list."\n";
	}
    }
}
close HIC;

my @uniq_hic_rnaseq = keys %rnaseq_hic;
my $uniq_hic_rnaseq_no = scalar @uniq_hic_rnaseq;
print STDERR "overlap rnaseq Hi-C interactions:".$uniq_hic_rnaseq_no."\n";

my @uniq_rnaseq_genes = keys %rnaseq_match_gene;
my $uniq_rnaseq_no_genes = scalar @uniq_rnaseq_genes;
print STDERR "overlap rnaseq genes:".$uniq_rnaseq_no_genes."\n";
