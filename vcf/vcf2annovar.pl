#!/usr/bin/perl
use strict;
use warnings;
my $vcf = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl vcf2annovar.pl vcf\n";die;
}
my $output = $vcf."_annovar";
open OUT,">",$output;

if($vcf =~ /\.gz$/){
    open(VCF, "gunzip -c $vcf |") || die "can't open pipe to ".$vcf."\n";
}else{
    open VCF,"<",$vcf;
}

while(my $line=<VCF>){
    chomp $line;
    if($line =~ /^#CHROM/ or $line =~ /CHR/){
	print OUT "#Chr\tStart\tEnd\tRef\tAlt\t".$line."\n";
        next;
    }elsif($line =~ /^##/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    $chr =~ s/chr//;
    my $start = $ele[1] + 0;
    my $rsid = $ele[2];
    my $ref = uc($ele[3]);
    my $alt = uc($ele[4]);
    my @alt = split(/,/,$alt);
    my $end = $start + length ($ref) -1;
    foreach my $i (@alt){
        print OUT $chr."\t".$start."\t".$end."\t".$ref."\t".$i."\t".$line."\n";
    }
}
close VCF;
close OUT;
