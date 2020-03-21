#!/usr/bin/perl
use strict;
use warnings;
my $in = $ARGV[0];
if(@ARGV<1){
    print STDERR "perl trim.pl input(annovar format)\n";die;
}
my $out = $in."_trim";
open OUT,">",$out;
open IN,"<",$in;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[5];
    #if($chr eq '23'){
    #	$chr = 'X'
    #}
    my $start = $ele[1];
    my $end = $ele[2];
    if($start =~ /e+/){
       $start = $end; 
       print STDERR $chr."\t".$start."\t".$end."\t".$ele[3]."\t".$ele[4]."\n";
    }  
    my $no = scalar @ele;
    $line = $chr."\t".$start."\t";
    for(my $i=2; $i<$no; $i++){
       $line .= $ele[$i]."\t";
    }
    $line =~ s/\t$//;
    print OUT $line."\n";
}
close IN;
close OUT;
