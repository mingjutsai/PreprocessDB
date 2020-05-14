#!/usr/bin/perl
use strict;
use warnings;
my $homer_inter = $ARGV[0];
if(@ARGV<1){
    print STDERR "perl program Homer_SigInteraction\n";die;
}
my $output_bed = $homer_inter."_peak1_peak2.bed";
open OUT,">",$output_bed;
open INTER,"<",$homer_inter;
my $line=<INTER>;
while($line=<INTER>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $id = $ele[0];
    my $chr_peak1 = $ele[2];
    my $start_peak1 = $ele[3];
    my $end_peak1 = $ele[4];
    my $peak1_id = $id."_peak1";
    my $chr_peak2 = $ele[8];
    my $start_peak2 = $ele[9];
    my $end_peak2 = $ele[10];
    my $peak2_id = $id."_peak2";
    my $info = "InteractionReads:".$ele[14].",LogP:".$ele[17].",FDR:".$ele[18];
    print OUT $chr_peak1."\t".$start_peak1."\t".$end_peak1."\t".$peak1_id."\t".$info."\n";
    print OUT $chr_peak2."\t".$start_peak2."\t".$end_peak2."\t".$peak2_id."\t".$info."\n";
}
close INTER;
close OUT;
