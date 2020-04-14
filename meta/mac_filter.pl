#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $mac = $ARGV[1];
my $type = $ARGV[2];
if(@ARGV < 2){
    print STDERR "perl mac_filter.pl annovar_input/origin mac_value type(origin, upload)\n";die;
}
my $output = $input."_macfilter".$mac;
open OUT,">",$output;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele;
    my $mac_value;
    if($type eq "origin"){
       @ele = split(/ /,$line);
       $mac_value = $ele[18];
    }else{
       @ele = split(/\t/,$line);
       $mac_value = $ele[22];
    }
    if($type eq "origin"){
       if($ele[0] eq "MarkerName"){
           print OUT $line."\n";
	   next;
       }
       if($mac_value > $mac){
           print OUT $line."\n";
       }
    }else{
        if($mac_value > $mac){
            my $chr = $ele[0];
	    my $pos = $ele[1];
	    my $allele1 = $ele[3];
	    my $allele2 = $ele[4];
	    my $pvalue = $ele[15];
	    my $size = $ele[21];
	    my $end = $pos + length($allele1) -1;
	    print OUT $chr."\t".$pos."\t".$end."\t".$allele1."\t".$allele2."\t".$pvalue."\t".$size."\n";
        }
    }
}
close IN;
close OUT;
