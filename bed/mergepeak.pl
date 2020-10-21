#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $output = $ARGV[1];
my $info_idx = $ARGV[2];
if(@ARGV < 3){
    print STDERR "perl mergepeak.pl peak1:value1,peak2:value2,peak3:value3 outputfile info_idx\n";die;
}
my @peaks = split(/,/,$input);
my %peaks;
foreach my $i (@peaks){
    #print STDERR $i."\n";
    my $in;
    my @tmp = split(/:/,$i);
    print STDERR "file:".$tmp[0]."\tvallue:".$tmp[1]."\n";
    if(!-e $tmp[0]){
        print STDERR $tmp[0]." is not exist\n";die;
    }
    open $in,"<",$tmp[0];
    while(my $line=<$in>){
        chomp $line;
	my @ele = split(/\t/,$line);
	my $chr = $ele[0];
	my $start = $ele[1];
	my $end = $ele[2];
        my $pos = $chr."\t".$start."\t".$end;
        my $info = $tmp[1].":".$ele[$info_idx];
        if(!$peaks{$pos}){
	    $peaks{$pos} = $info;
	}else{
	    if($peaks{$pos} =~ /$info/){
	        next;
	    }else{
	        $peaks{$pos} .= ",".$info;
	    }
	   
	}
    }
    close $in;
}

open OUT,">",$output;
my @uniq_region = keys %peaks;
foreach my $region (@uniq_region){
    my ($chr,$start,$end) = split(/\t/,$region);
    my $pos = $chr."-".$start."-".$end;
    print OUT $region."\t".$peaks{$region}.":".$pos."\n";
}
close OUT;
