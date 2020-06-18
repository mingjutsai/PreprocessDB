#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl narrowpeak2bed.pl narrowpeak\n";die;
}
my %atac;
my $bed = $input."_annovardb";
open BED,">",$bed;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    my $start = $ele[1];
    my $end = $ele[2];
    my $qvalue = $ele[8];
    my $peak_region = $chr.":".$start."-".$end;
    if(!$atac{$peak_region}){
        $atac{$peak_region} = $qvalue;
    }else{
        if($qvalue > $atac{$peak_region}){
	    $atac{$peak_region} = $qvalue;	
	}
    }
}
my @keys = keys %atac;
foreach my $i (@keys){
    my @pos = split(/:/,$i);
    my $chr = $pos[0];
    my @range = split(/-/,$pos[1]);
    my ($start,$end) = ($range[0],$range[1]);
    my $info = $i.",qValue(-log10):".$atac{$i};
    print BED $chr."\t".$start."\t".$end."\t".$info."\n";
}
close IN;
close BED;
