#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl mbps2bed.pl mbps.input\n";die;
}
my $output = $input."_annovardb";
open OUT,">",$output;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    my $start = $ele[1];
    my $end = $ele[2];
    my $mbps = $ele[3];
    my $score = $ele[4];
    my $mbps_pos = $chr.":".$start."-".$end;
    my $info = "mbps_region:".$mbps_pos.",mbps:".$mbps.",bit-score:".$score;
    print OUT $chr."\t".$start."\t".$end."\t".$info."\n";

    
}
close IN;
close OUT;
