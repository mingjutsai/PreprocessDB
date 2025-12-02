#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl clinvar2Annovar.pl vcf\n";die;
}
my $output = $input."_Annovar";
open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\tCLNSIG\n";
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    my $pos = $ele[1];
    my $ref = $ele[3];
    my $alt = $ele[4];
    if($alt =~ /,/){
        print STDERR $line."\n";die;
    }
    my $pos_end = $pos + length($ref) - 1;
    my $info = $ele[7];
    my @tmp = split(/;/,$info);
    my $sig;
    foreach my $i (@tmp){
        if($i =~ /CLNSIG=/){
            my @sigtmp = split(/=/,$i);
            $sig = $sigtmp[1];
	    if($sig){
		print OUT $chr."\t".$pos."\t".$pos_end."\t".$ref."\t".$alt."\t".$sig."\n";
	    }
        }
    }
}
close IN;
close OUT;
