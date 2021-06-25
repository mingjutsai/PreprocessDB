#!/usr/bin/perl
use strict;
use warnings;
use Number::FormatEng qw(:all);
use bignum;
use Statistics::Multtest qw(bonferroni holm hommel hochberg BH BY qvalue);
use Statistics::Multtest qw(:all);

my $homer_inter = $ARGV[0];
my $fdr_cutoff = $ARGV[1];
if(@ARGV<2){
    print STDERR "perl program Homer_SigInteraction fdr_cutoff\n";die;
}
my @pvalue;
my $no = 1;
my %loc1;
my %loc2;
my $origin_no = 0;
my $filter_no = 0;
my $output_bed = $homer_inter."_peak1_peak2_FDR".$fdr_cutoff.".bed";
open OUT,">",$output_bed;
open INTER,"<",$homer_inter;
my $line=<INTER>;
while($line=<INTER>){
    chomp $line;
    $origin_no++;
    my @ele = split(/\t/,$line);
    my $fdr = $ele[18];
    #if($fdr > $fdr_cutoff){
    #    next;
    #}
    #$filter_no++;
    #my $id = $ele[0];
    my $chr_peak1 = $ele[2];
    $chr_peak1 =~ s/chr//;
    my $start_peak1 = $ele[3];
    my $end_peak1 = $ele[4];
    #my $peak1_id = $id."_".$chr_peak1."_bin1";
    #my $peak1_id = $chr_peak1.":".$start_peak1.":".$end_peak1;
    my $chr_peak2 = $ele[8];
    $chr_peak2 =~ s/chr//;
    my $start_peak2 = $ele[9];
    my $end_peak2 = $ele[10];
    #my $peak2_id = $chr_peak2.":".$start_peak2.":".$end_peak2;
    #my $id = $chr_peak1.":".$start_peak1.":".$end_peak1."-".$chr_peak2.":".$start_peak2.":".$end_peak2;
    my $id_bin1 = $chr_peak1.":".$start_peak1.":".$start_peak2;
    my $id_bin2 = $chr_peak2.":".$start_peak2.":".$start_peak1;
    #my $qvalue = format_eng($ele[18]);
    my $pvalue = sprintf("%.2e",exp $ele[17]);
    $pvalue[$no] = $pvalue;
    #print STDERR "logP:".$ele[17]."\tP:".$pvalue."\n";die;
    #print STDERR $ele[18]."\t".$qvalue."\t".format_eng($ele[18])."\n";
    #my $qvalue = sprintf("%.2e",$ele[18]).",".$pvalue;
    #print STDERR "qvalue:".$qvalue."\n";
    #my $peak2_id = $id."_".$chr_peak2."_bin2";
    my @readcount = split(/\./,$ele[14]);
    #my $info = "InteractionID:".$id."\tReadCounts:".$readcount[0];
    #my $info2 = "InteractionID:".$id.",InteractionReads:".$ele[14].",LogP:".$ele[17].",FDR:".$ele[18];
    #$loc1{$no} = $chr_peak1."\t".$start_peak1."\t".$end_peak1."\t".$peak1_id."\t".$peak2_id."\t".$info;
    #$loc2{$no} = $chr_peak2."\t".$start_peak2."\t".$end_peak2."\t".$peak2_id."\t".$peak1_id."\t".$info;
    $loc1{$no} = $id_bin1."\t".$readcount[0];
    $loc2{$no} = $id_bin2."\t".$readcount[0];
    #print OUT $chr_peak1."\t".$start_peak1."\t".$end_peak1."\t".$peak1_id."\t".$peak2_id."\t".$info."\n";
    #print OUT $chr_peak2."\t".$start_peak2."\t".$end_peak2."\t".$peak2_id."\t".$peak1_id."\t".$info."\n";
    $no++;
}
close INTER;
#close OUT;

my %hic_filter;
my $p_value = \@pvalue;
my $res = BH($p_value);
#my @res = BH($p_value);
for(my $i=1;$i<@{$res};$i++){
    my $qvalue = sprintf("%.2e",$res->[$i]);
    if($qvalue <= $fdr_cutoff){
	if(!$loc1{$i}){
	    print $i."\n";
	}
	my @loc1_info = split("\t",$loc1{$i});
	my $readcount = $loc1_info[1];
	if($readcount >= 10){
		#$hic_filter{$id}++;
            print OUT $loc1{$i}."\t".$qvalue."\n";
	    print OUT $loc2{$i}."\t".$qvalue."\n";
        }
    }
}
#my @uniq_Hic_filter = keys %hic_filter;
#$filter_no = scalar @uniq_Hic_filter;
#print join "\n", @$res;
#print STDERR "origin:".$origin_no."\n";
#print STDERR "filter:".$filter_no."\n";
