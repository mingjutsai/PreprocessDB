#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $filter_chr = $ARGV[1];
if(@ARGV<2){
    print STDERR "perl Chr_filter.pl input filter_chr\n";die;
}

my $filter = $input.".Chr_mapped";
open FILTER,">",$filter;

my $unmap = $input.".Chr_unmapped";
open UNMAP,">",$unmap;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^##/){
        next;
    }elsif($line =~ /^#Chr/){
        print FILTER $line."\n";
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    if($chr eq $filter_chr){
        print FILTER $line."\n";
    }else{
        print UNMAP $line."\n";
    }
}
close IN;
