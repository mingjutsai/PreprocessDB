#!/usr/bin/perl
use strict;
use warnings;
my $in = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl annovar2gcta.pl annovar\n";die;
}
my $out = $in.".gcta";
open OUT,">",$out;
print OUT "SNP\tA1\tA2\tEAF\tBeta\tSE\tP\tN\n";
open IN,"<",$in;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#Chr/) {
         next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    my $pos = $ele[1];
    my $a1 = $ele[3];
    my $a2 = $ele[4];
    my $eaf = $ele[6];
    my $beta = $ele[7];
    my $se = $ele[8];
    my $p = $ele[9];
    my $n = $ele[10];
    my $snp = $chr.":".$pos."_".$a1."_".$a2;
    #my $end = $pos + length($ref) - 1;
    print OUT $snp."\t".$a1."\t".$a2."\t".$eaf."\t".$beta."\t".$se."\t".$p."\t".$n."\n";

}
close IN;
close OUT;
