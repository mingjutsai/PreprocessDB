#!/usr/bin/perl
use strict;
use warnings;
my $id_list = $ARGV[0];
my $type = $ARGV[1];
my $homer = $ARGV[2];
if(@ARGV < 3){
    print STDERR "perl extract_interaction.pl ID_list EP/PE homer_sig\nEP: enhancer-promoter, PE: promoter-enhancer\n";die;
}
if(($type ne 'EP')and($type ne 'PE')){
    print STDERR "Type must be EP or PE\n";die;
}
my %id;
open ID,"<",$id_list;
while(my $line=<ID>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $id = $ele[0];
    my $gene = $ele[1];
    $id{$id} = $gene;
}
close ID;

my $output = $id_list."_".$type;
open OUT,">",$output;
open HOMER,"<",$homer;
while(my $line=<HOMER>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $id_bin = $ele[3];
    #print STDERR $id_bin."\n";
    if(!$id{$id_bin}){
        next;
    }
    my $chr = $ele[0];
    my $start = $ele[1];
    my $end = $ele[2];
    my $info = $ele[4];
    if($type eq 'EP'){
        my @info = split(/,/,$info);
	my @pos = split(/:/,$info[0]);
	my @inter_id = split(/:/,$info[1]);
        my $inter_id = $inter_id[1];
	my $inter_reads = $info[2];
	my $log_p = $info[3];
	my $fdr = $info[4];
	my $inter_bin = $chr.":".$start.":".$end;
	my $enh_chr = $pos[1];
	my $enh_start = $pos[2];
	my $enh_end = $pos[3];
	my $promoter_info = "RegulatoryBin:".$enh_chr.":".$enh_start.":".$enh_end.",RegulatoryID:".$inter_id;
	$promoter_info .= ",PromoterBin:".$chr.":".$start.":".$end.",PromoterID:".$id_bin.",".$inter_reads.",".$log_p.",".$fdr.",TargetGene:".$id{$id_bin};
	my $ep_info = join("\t",$enh_chr,$enh_start,$enh_end,$promoter_info);
	print OUT $ep_info."\n";
    }else{#PE
	my @info = split(/,/,$info);
        my @pos = split(/:/,$info[0]);
	my $enh_chr = $pos[1];
        my $enh_start = $pos[2];
        my $enh_end = $pos[3];
        my @inter_id = split(/:/,$info[1]);
        my $inter_id = $inter_id[1];
        my $inter_reads = $info[2];
        my $log_p = $info[3];
        my $fdr = $info[4];
	#print STDERR "TargetGene:".$id{$id_bin}."\n";
	#print STDERR "Info:".$info."\n";die;
	my $promoter_info = "PromoterBin:".$chr.":".$start.":".$end.",PromoterID:".$id_bin.",TargetGene:".$id{$id_bin};
	$promoter_info .= ",RegulatoryBin:".$enh_chr.":".$enh_start.":".$enh_end.",RegulatoryID:".$inter_id.",".$inter_reads.",".$log_p.",".$fdr;
	#my $promoter_info = "TargetGene:".$id{$id_bin}.",".$info;
	my $pe_info = join("\t",$chr,$start,$end,$promoter_info);
	print OUT $pe_info."\n";
    }
}
close HOMER;
close OUT;
