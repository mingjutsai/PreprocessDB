#!/usr/bin/perl
use strict;
use warnings;
my $in = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl sumstats2annovar.pl sumstats\n";die;
}
my $out = $in.".annovar";
open OUT,">",$out;
print OUT "#Chr\tPos\tEnd\tRef\tAlt\tSNP\tEAF\tBeta\tSE\tP\tN\n";
open IN,"<",$in;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^SNP/) {
         next;
    }
    my @ele = split(/\t/,$line);
    my $snp = $ele[0];
    my $chr = $ele[1];
    my $pos = $ele[2];
    my $a1 = $ele[3];
    my $a2 = $ele[4];
    my $ref = $ele[5];
    my $eaf = $ele[6];
    my $beta = $ele[7];
    my $se = $ele[8];
    my $p = $ele[9];
    my $n = $ele[10];
    my $alt;
    if($ref eq $a1){
        $alt = $a2;
    }else{
        $alt = $a1;
    }
    my $end = $pos + length($ref) - 1;
    print OUT $chr."\t".$pos."\t".$end."\t".$ref."\t".$alt."\t".$snp."\t".$eaf."\t".$beta."\t".$se."\t".$p."\t".$n."\n";

}
close IN;
