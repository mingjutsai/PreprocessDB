#!/usr/bin/perl
use strict;
use warnings;
my $hommer_inter = $ARGV[0];
if(@ARGV<1){
    print STDERR "perl program hommer_SigInteraction\n";die;
}
my $peak1 = $hommer_inter."_peak1.bed";
my $peak2 = $hommer_inter."_peak2.bed";
open PEAK1,">",$peak1;
open PEAK2,">",$peak2;
open INTER,"<",$hommer_inter;
my $line=<INTER>;
while($line=<INTER>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr_peak1 = $ele[2];
    my $start_peak1 = $ele[3];
    my $end_peak1 = $ele[4];
    my $strand_peak1 = $ele[5];
    my $id = $ele[0];
    print PEAK1 $chr_peak1."\t".$start_peak1."\t".$end_peak1."\t".$strand_peak1."\t".$id."\n";
    my $chr_peak2 = $ele[8];
    my $start_peak2 = $ele[9];
    my $end_peak2 = $ele[10];
    my $strand_peak2 = $ele[11];
    print PEAK2 $chr_peak2."\t".$start_peak2."\t".$end_peak2."\t".$strand_peak2."\t".$id."\n";
}
close INTER;
close PEAK1;
close PEAK2;
