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

my $output = $input."_sig.bed";
my $res = 5000;
my $pvalue_zero = $input."_pvalue_zero";
my $min_p = -100;
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
    if($readcount < 10){
        next;
    }
    my $qvalue = $ele[10];
    if($qvalue > 0.05){
        next;
    }
    my $logpvalue;
    if($ele[9] == 0){
        $logpvalue = -1000;
    }else{
        $logpvalue = log($ele[9]);
    }
    if($logpvalue < $min_p){
        $min_p = $logpvalue;
    }
    #print STDERR "read:".$readcount."\tpvalue:".$logpvalue."\n";die;
    my $start_bin1 = $ele[1] + 0;
    my $end_bin1 = $start_bin1 + $res;
    my $start_bin2 = $ele[3] + 0;
    my $end_bin2 = $start_bin2 + $res;
    #
    print OUT $chr_bin1."\t".$start_bin1."\t".$end_bin1."\t".$chr_bin2."\t".$start_bin2."\t".$end_bin2."\t".$readcount."\t".$logpvalue."\n";
}

#print STDERR "Min pvalue:".$min_p."\n";
close IN;
close OUT;
