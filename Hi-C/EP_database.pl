#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl EP_database.pl merge_results.bed\n";die;
}
my $output = $input."_EP.bed";
open OUT,">",$output; 
my %EP;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my @info = split(/;/,$ele[3]);
    my $distal = $info[1];
    my $promoter = $info[0];
    #print STDERR "distal:".$distal."\tpromoter:".$promoter."\n";die;
    if(!$EP{$distal}){
        $EP{$distal} = $promoter;
    }elsif($EP{$distal} !~ /$promoter/){
        $EP{$distal} .= ",".$promoter;
    }
}
close IN;

my @uniq_EP = keys %EP;
foreach my $i (@uniq_EP){
    #print STDERR "distal:".$i."\n";
    my @distal = split(/:/,$i);
    #print STDERR "promoter:".$EP{$i}."\n";
    my @promoter = split(/,/,$EP{$i});
    my $chr_d = $distal[1];
    my $start_d = $distal[2];
    my $end_d = $distal[3];
    my $promoter_info;
    foreach my $p (@promoter){
	    #print STDERR "promoter:".$p."\n";die;
	my @promoter_info = split(/:/,$p);
	my $chr_p = $promoter_info[1];
        my $start_p = $promoter_info[2];
        my $end_p = $promoter_info[3];
        $promoter_info .= $chr_p.":".$start_p.":".$end_p.",";
    }
    $promoter_info =~ s/,$//;
    my $final = "RegulatoryBin:".$chr_d.":".$start_d.":".$end_d.";PromoterBin:".$promoter_info;
    print OUT $chr_d."\t".$start_d."\t".$end_d."\t".$final."\n";
}

