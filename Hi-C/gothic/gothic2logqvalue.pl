#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl gothic2bed.pl input\n";die;
}

sub log10{
    my $n = shift;
    return log($n)/log(10);
}

my $output = $input."_logqvalue.bed";
my $res = 5000;
my $pvalue_zero = $input."_pvalue_zero";
my $max_logqvalue = 1;
open OUT,">",$output;
open IN,"<",$input;
my $line = <IN>;
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr_bin1 = $ele[0];
    my $chr_bin2 = $ele[2];
    $chr_bin1 =~ s/chr//;
    $chr_bin2 =~ s/chr//;
    $chr_bin1 =~ s/"//g;
    $chr_bin2 =~ s/"//g;
    my $readcount = $ele[8];
    #print STDERR "read:".$readcount."\n";
    #if($readcount < 10){
    #    next;
    #}
    my $qvalue = $ele[10];
    #if($qvalue > 0.05){
    #    next;
    #}
    my $logqvalue;
    if($ele[10] == 0){
        $logqvalue = 0;
    }else{
        $logqvalue = -log($qvalue);
    }
    if($logqvalue > $max_logqvalue){
        $max_logqvalue = $logqvalue;
    }
    #print STDERR "read:".$readcount."\tpvalue:".$logpvalue."\n";die;
    my $start_bin1 = $ele[1] + 0;
    my $end_bin1 = $start_bin1 + $res;
    my $start_bin2 = $ele[3] + 0;
    my $end_bin2 = $start_bin2 + $res;
    #
    print OUT $chr_bin1."\t".$start_bin1."\t".$end_bin1."\t".$chr_bin2."\t".$start_bin2."\t".$end_bin2."\t".$readcount."\t".$logqvalue."\n";
}

print STDERR "Max -log qvalue:".$max_logqvalue."\n";
close IN;
close OUT;
