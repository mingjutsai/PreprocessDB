#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $res = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl hiccups2bed.pl input res(ex: 2000)\n";die;
}
my $output = $input."_peak1_peak2_res.".$res.".bed";
open OUT,">",$output;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if(($line =~ /^chr1/)or ($line =~ /^#/)){
        next;
    }

    my @ele = split(/\t/,$line);
    my $chr_bin1 = $ele[0];
    my $chr_bin2 = $ele[3];
    if($chr_bin2 ne $chr_bin1){
        next;
    }
    my $start_bin1 = $ele[1] + 0;
    my $end_bin1 = $ele[2] + 0;
    my $start_bin2 = $ele[4] + 0;
    my $end_bin2 = $ele[5] + 0;
    my $bin1_id = $chr_bin1.":".$start_bin1.":".$end_bin1;
    my $bin2_id = $chr_bin2.":".$start_bin2.":".$end_bin2;
    my @read = split(/\./,$ele[11]);
    my $readcount = $read[0];
    if($readcount < 10){
        next;
    }
    my $qvalue = sprintf("%.2e",$ele[17]);
    if($qvalue > 0.05){
        next;
    }
    my $id_bin1 = $chr_bin1.":".$start_bin1.":".$start_bin2;
    my $id_bin2 = $chr_bin2.":".$start_bin2.":".$start_bin1;
    print OUT $id_bin1."\t".$readcount."\t".$qvalue."\n";
    print OUT $id_bin2."\t".$readcount."\t".$qvalue."\n";
}
close IN;
close OUT;
