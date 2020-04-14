#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl evaluate.pl annotation\n";die;
}
my %sig;
my $svm_tp=0;
my $svm_tn=0;
my $svm_fp=0;
my $svm_fn=0;

my $lr_tp=0;
my $lr_tn=0;
my $lr_fp=0;
my $lr_fn=0;

my $cadd_tp=0;
my $cadd_tn=0;
my $cadd_fp=0;
my $cadd_fn=0;

my $revel_tp=0;
my $revel_tn=0;
my $revel_fp=0;
my $revel_fn=0;

my $add_tp=0;
my $add_tn=0;
my $add_fp=0;
my $add_fn=0;

my $or_tp=0;
my $or_tn=0;
my $or_fp=0;
my $or_fn=0;
open IN,"<",$input;
my $line;
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $svm = $ele[6];
    my $lr = $ele[7];
    my $cadd = $ele[8];
    my $revel = $ele[9];
    my $clinvar = $ele[10];
    my $ans;
    if(($clinvar eq "Pathogenic/Likely_pathogenic")or($clinvar eq "Pathogenic")or($clinvar eq "Likely_pathogenic")or($clinvar eq "Pathogenic,_risk_factor")or($clinvar eq "Pathogenic/Likely_pathogenic,_other")or($clinvar eq "Pathogenic,_other")or($clinvar eq "Likely_pathogenic,_risk_factor")){
        $ans = 'TP';
    }elsif(($clinvar eq "Benign/Likely_benign")or($clinvar eq "Likely_benign")or($clinvar eq "Benign/Likely_benign,_other")or($clinvar eq "Benign")or($clinvar eq "Likely_benign,_other")){
        $ans = 'TN';
    }

    if($svm eq 'T'){
	if($clinvar eq 'TN'){
            $svm_tn++;
        }else{
	    $svm_fn++;
        }
    }elsif($svm eq 'D'){
	if($clinvar eq 'TP'){
	    $svm_tp++;
	}else{
	    $svm_
	}
    }
    $sig{$clinvar}++;
}
close IN;
my @uniq = keys %sig;
foreach my $i (@uniq){
    print $i."\n";
}
