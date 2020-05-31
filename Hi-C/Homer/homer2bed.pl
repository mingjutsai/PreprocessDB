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
    my $peak1_id = $id."_".$chr_peak1."_bin1";
    my $chr_peak2 = $ele[8];
    my $start_peak2 = $ele[9];
    my $end_peak2 = $ele[10];
    my $peak2_id = $id."_".$chr_peak2."_bin2";
    my $info1 = "InteractionBin:".$chr_peak2.":".$start_peak2.":".$end_peak2.",InteractionID:".$id."_".$chr_peak2."_bin2,InteractionReads:".$ele[14].",LogP:".$ele[17].",FDR:".$ele[18];
    my $info2 = "InteractionBin:".$chr_peak1.":".$start_peak1.":".$end_peak1.",InteractionID:".$id."_".$chr_peak1."_bin1,InteractionReads:".$ele[14].",LogP:".$ele[17].",FDR:".$ele[18];
    print OUT $chr_peak1."\t".$start_peak1."\t".$end_peak1."\t".$peak1_id."\t".$info1."\n";
    print OUT $chr_peak2."\t".$start_peak2."\t".$end_peak2."\t".$peak2_id."\t".$info2."\n";
}
close INTER;
close OUT;