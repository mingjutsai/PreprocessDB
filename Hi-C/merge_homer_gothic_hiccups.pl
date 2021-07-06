#!/usr/bin/perl
use strict;
use warnings;
my $homer = $ARGV[0];
my $gothic = $ARGV[1];
my $hiccups = $ARGV[2];
if(@ARGV < 3){
    print STDERR "perl merge_homer_gothic_hiccups.pl homer gothic hiccups\n";die;
}
my %homer;
my %gothic;
my %hiccups;
my %merge;
print STDERR "reading HOMER...\n";
open HOMER,"<",$homer;
while(my $line=<HOMER>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $id = $ele[0];
    $homer{$id} = "HOMER:readcount:".$ele[1].",qvalue:".$ele[2];
    $merge{$id}++;
}
close HOMER;

print STDERR "reading GOTHIC...\n";
open GOTHIC,"<",$gothic;
while(my $line=<GOTHIC>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $id = $ele[0];
    $gothic{$id} = "GOTHIC:readcount:".$ele[1].",qvalue:".$ele[2];
    $merge{$id}++;

}
close GOTHIC;

print STDERR "reading HICCUPS...\n";
open HICCUPS,"<",$hiccups;
while(my $line=<HICCUPS>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $id = $ele[0];
    $hiccups{$id} = "HICCUPS:readcount:".$ele[1].",qvalue:".$ele[2];
    $merge{$id}++;
}
close HICCUPS;

print STDERR "starting mapping...\n";
my $output = "merge_results.txt";
open OUT,">",$output;

my @uniq_id = keys %merge;
foreach my $i (@uniq_id){
    my $info;
    if($homer{$i}){
        $info .= $homer{$i}."|";
    }
    if($gothic{$i}){
        $info .= $gothic{$i}."|";
    }
    if($hiccups{$i}){
        $info .= $hiccups{$i}."|";
    }
    $info =~ s/\|$//;
    #print STDERR $info."\n";die;
    my @pos = split(/:/,$i);
    my $chr = $pos[0];
    my $start_bin1 = $pos[1];
    if(!$start_bin1){
       $start_bin1 = 0;
    }
    my $end_bin1 = $start_bin1 + 2000;
    my $bin1 = $chr.":".$start_bin1.":".$end_bin1;
    my $start_bin2 = $pos[2];
    if(!$start_bin2){
       $start_bin2 = 0;
    }
    my $end_bin2 = $start_bin2 + 2000;
    my $bin2 = $chr.":".$start_bin2.":".$end_bin2;
    my $final_info = "P:".$bin1.";D:".$bin2.";".$info;
    print OUT $chr."\t".$start_bin1."\t".$end_bin1."\t".$final_info."\n";
}
close OUT;

