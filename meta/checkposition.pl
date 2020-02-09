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
    my $start = $ele[1];
    my $end = $ele[2];
    if($start =~ /e+/){
       $start = $end; 
       print STDERR $ele[0]."\t".$start."\t".$end."\t".$ele[3]."\t".$ele[4]."\n";
       my $no = scalar @ele;
       $line = $ele[0]."\t".$start."\t";
       for(my $i=2; $i<$no; $i++){
           $line .= $ele[$i]."\t";
       }
       $line =~ s/\t$//;
    }
    print OUT $line."\n";
}
close IN;
close OUT;
