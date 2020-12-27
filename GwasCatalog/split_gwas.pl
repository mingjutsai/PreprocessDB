#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl split_gwas.pl input(ex:gwas_catalog_v1.0.2-associations_e100_r2020-12-15.tsv)\n";die;
}
my %chr;
my $err = $input."_error";
open ERR,">",$err;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^DATE/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $pubmed = $ele[1];
    my $disease_trait = $ele[7];
    my $chr = $ele[11];
    if(!$chr or (($chr ne '1')and($chr ne '2')and($chr ne '3')and($chr ne '4')and($chr ne '5')and($chr ne '6')and($chr ne '7')and($chr ne '8')
	and($chr ne '9')and($chr ne '10')and($chr ne '11')and($chr ne '12')and($chr ne '13')and($chr ne '14')and($chr ne '15')and($chr ne '16')
        and($chr ne '17')and($chr ne '18')and($chr ne '19')and($chr ne '20')and($chr ne '21')and($chr ne '22')and($chr ne 'X')and($chr ne 'Y'))
      ){
        print ERR $line."\n";
	next;
    }
    my $reported_gene = $ele[13];
    my $mapped_gene = $ele[14];
    my @risk_allele = split(/\-/,$ele[20]);
    my $rsid = $risk_allele[0];
    my $risk_allele = $risk_allele[1];
    if(!$risk_allele or $risk_allele eq '?'){
        $risk_allele = 'NA';
    }
    my $risk_allele_freq = $ele[26];
    my $pvalue = $ele[27];
    my $or_beta = $ele[30];
    my $ci_95 = $ele[31];
    my $mapped_trait = $ele[34];
    my $mapped_trait_url = $ele[35];
    my $study_accession = $ele[36];
    my $info = join("\t",$chr,$rsid,$risk_allele,$risk_allele_freq,$pubmed,$disease_trait,$reported_gene,$mapped_gene,$pvalue,$or_beta,$ci_95,$mapped_trait,$mapped_trait_url,$study_accession);
    my $of;
    if(!$chr{$chr}){
        my $split = $input."_chr".$chr;
        open $of,">",$split;
	print $of $info."\n";
    }else{
        my $split = $input."_chr".$chr;
        open $of,">>",$split;
	print $of $info."\n";
	
    }
    $chr{$chr}++;
}
close IN;
