#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl gothic2bed.pl input\n";die;
}
my $output = $input."_peak1_peak2_res.".$res.".bed";
open OUT,">",$output;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr_bin1 = $ele[0];
    my $chr_bin2 = $ele[3];
    $chr_bin1 =~ s/chr//;
    $chr_bin2 =~ s/chr//;
    $chr_bin1 =~ s/"//g;
    $chr_bin2 =~ s/"//g;
    if($chr_bin2 ne $chr_bin1){
        next;
    }
    my $start_bin1 = $ele[1] + 0;
    my $end_bin1 = $start_bin1 + $res;
    my $start_bin2 = $ele[4] + 0;
    my $end_bin2 = $start_bin2 + $res;
    my $bin1_id = $chr_bin2.":".$start_bin1.":".$start_bin2;
    my $bin2_id = $chr_bin2.":".$start_bin2.":".$start_bin1;
    my $readcount = $ele[8];
    if($readcount < 10){
        next;
    }
    my $qvalue = sprintf("%.2e",$ele[10]);
    if($qvalue > 0.05){
        next;
    }
    my $id = $chr_bin1.":".$start_bin1.":".$start_bin2;
    print OUT $bin1_id."\t".$readcount."\t".$qvalue."\n";
    print OUT $bin2_id."\t".$readcount."\t".$qvalue."\n";
}
close IN;
close OUT;
