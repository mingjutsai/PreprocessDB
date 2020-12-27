#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl mapping_pos.pl input\n";die;
}
my $output = $input."_annovar_v2";
open OUT,">",$output;

my $orig_count = 0;
my $mapping_count = 0;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    if($chr eq 'X'){
        $chr = '23';
    }elsif($chr eq 'Y'){
        $chr = '24';
    }
    my $rsid = $ele[1];
    my $risk_allele = $ele[2];
    print STDERR "risk_allele:".$risk_allele."\n";
    my $cmd = "grep -w ".$rsid." /home/kacy/wdc.4t/ifar/databases/hg38/dbSNP/GCF_000001405.38.gz_Chr".$chr."_annovar";
    my $results = `$cmd`;
    my @results = split(/\n/,$results);
    my $results_no = scalar @results;
    if($results_no > 0 and ($risk_allele eq 'NA')){
        $mapping_count++;
    }elsif($results_no == 0){
        next;
    }
    foreach my $i (@results){
	if($risk_allele eq 'NA'){
	    print OUT $i."\t".$line."\n";
	}else{
            my @dbSNP = split(/\t/,$i);
	    my $dbSNP_ref = $dbSNP[3];
	    my $dbSNP_alt = $dbSNP[4];
	    if($risk_allele eq $dbSNP_alt){
	        print OUT $i."\t".$line."\n";
		$mapping_count++;
		last;
            }elsif($risk_allele eq $dbSNP_ref){
	        print OUT $i."\t".$line."\n";
		$mapping_count++;
		last;
	    }
       }
    }
    $orig_count++;
}

my $mapping = $mapping_count/$orig_count;
print STDERR "mapping:".$mapping."\n";
close IN;
close OUT;
