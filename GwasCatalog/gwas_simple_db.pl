#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl gwas_simple_db.pl input\n";die;
}
my $output = $input."_SNP-Table";
open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\tGWAS_Catalog\n";
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^Chr/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $pubmed = $ele[11];
    my $risk_allele = $ele[9];
    my $disease_trait = $ele[12];
    my $reported_gene = $ele[13];
    my $pvalue = $ele[15];
    my $gwas_info = "Pubmed:".$pubmed.",Risk_allele:".$risk_allele.",Disease_trait:".$disease_trait.",Reported_gene:".$reported_gene.",P-value:".$pvalue;
    my $info = join("\t",$ele[0],$ele[1],$ele[2],$ele[3],$ele[4],$gwas_info);
    print OUT $info."\n";
}
close IN;
close OUT;
