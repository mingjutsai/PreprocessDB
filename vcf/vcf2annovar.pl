#!/usr/bin/perl
use strict;
use warnings;
my $vcf = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl vcf2annovar.pl vcf\n";die;
}
my $output = $vcf."_annovar";
open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\tRSID\n";

if($vcf =~ /\.gz$/){
    open(VCF, "gunzip -c $vcf |") || die "can't open pipe to ".$vcf."\n";
}else{
    open VCF,"<",$vcf;
}

while(my $line=<VCF>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    $chr =~ s/chr//;
    my $start = $ele[1];
    my $rsid = $ele[2];
    my $ref = $ele[3];
    my $alt = $ele[4];
    my $end = $start + length ($ref) -1;
    print OUT $chr."\t".$start."\t".$end."\t".$ref."\t".$alt."\t".$rsid."\t".$line."\n";
}
close VCF;
close OUT;
