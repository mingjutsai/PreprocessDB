#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $output = $ARGV[1];
if(@ARGV < 1){
    print STDERR "perl pairs2gothic.pl pair1,pair2,pair3,...,pairN outputName\n";die;
}
my @in = split(/,/,$input);

open OUT,">",$output;
foreach my $i (@in){
    print STDERR $i."\n";
    open IN,"<",$i;
    while(my $line=<IN>){
        chomp $line;
	if($line =~ /^#/){
	    next;
	}
	my @ele = split(/\t/,$line);
	my $mapq1 = $ele[8];
	my $mapq2 = $ele[9];
	if($mapq1<30 or $mapq2<30){
	    next;
	}
	my $id = $ele[0];
	my $chr1 = $ele[1];
        my $pos1 = $ele[2];
	my $chr2 = $ele[3];
	my $pos2 = $ele[4];
	if($chr1 ne $chr2){
	    next;
	}
	my $strand1 = $ele[5];
	my $strand2 = $ele[6];
	print OUT $no."\t".$chr1."\t".$pos1."\t".$strand1."\t".$chr2."\t".$pos2."\t".$strand2."\n";
	$no++;
    }

}
close IN;
close OUT;
