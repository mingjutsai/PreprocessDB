#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $output = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl pairs2homer.pl pair1,pair2,pair3,...,pairN outputName\n";die;
}
my @in = split(/,/,$input);
my $no = 1;

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
	my $chr1 = $ele[1];
        my $pos1 = $ele[2];
	my $chr2 = $ele[3];
	my $pos2 = $ele[4];
	if($chr1 ne $chr2){
	    next;
	}
	if(($chr1 eq "chr1")or($chr1 eq "chr2")or($chr1 eq "chr3")or($chr1 eq "chr4")or($chr1 eq "chr5")or($chr1 eq "chr6")or($chr1 eq "chr7")or($chr1 eq "chr8")or($chr1 eq "chr9")or($chr1 eq "chr10")or($chr1 eq "chr11")or($chr1 eq "chr12")or($chr1 eq "chr13")or($chr1 eq "chr14")or($chr1 eq "chr15")or($chr1 eq "chr16")or($chr1 eq "chr17")or($chr1 eq "chr18")or($chr1 eq "chr19")or($chr1 eq "chr20")or($chr1 eq "chr21")or($chr1 eq "chr22")or($chr1 eq "chrX")or($chr1 eq "chrY")){
		my $strand1 = $ele[5];
		my $strand2 = $ele[6];
		print OUT $no."\t".$chr1."\t".$pos1."\t".$strand1."\t".$chr2."\t".$pos2."\t".$strand2."\n";
		$no++;
	}
    }

}
close IN;
close OUT;
