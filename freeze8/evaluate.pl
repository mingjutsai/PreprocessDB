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
my $svm_undefined=0;

my $lr_tp=0;
my $lr_tn=0;
my $lr_fp=0;
my $lr_fn=0;
my $lr_undefined=0;

my $cadd_tp=0;
my $cadd_tn=0;
my $cadd_fp=0;
my $cadd_fn=0;
my $cadd_undefined=0;

my $revel_tp=0;
my $revel_tn=0;
my $revel_fp=0;
my $revel_fn=0;
my $revel_undefined=0;

my $add_tp=0;
my $add_tn=0;
my $add_fp=0;
my $add_fn=0;
my $add_undefined=0;

my $or_tp=0;
my $or_tn=0;
my $or_fp=0;
my $or_fn=0;
my $or_undefined=0;

my $clinvar_tp=0;
my $clinvar_tn=0;
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
    }else{
        next;
    }
    #print STDERR $ans."\n";
    if($ans eq 'TN'){
        $clinvar_tn++;
        #metasvm
        if($svm eq 'T'){
            $svm_tn++;
        }elsif($svm eq 'D'){
            $svm_fp++;
        }else{
            $svm_undefined++;
        }
        #metaLR
        if($lr eq 'T'){
            $lr_tn++;
        }elsif($lr eq 'D'){
            $lr_fp++;
        }else{
            $lr_undefined++;
        }
        #CADD
        if($cadd eq 'T'){
            $cadd_tn++;
        }elsif($cadd eq 'D'){
            $cadd_fp++;
        }else{
            $cadd_undefined++;
        }
        #REVEL
        if($revel eq 'T'){
            $revel_tn++;
        }elsif($revel eq 'D'){
            $revel_fp++;
        }else{
            $revel_undefined++;
        }
        #OR
        if(($svm eq 'D')or($lr eq 'D')or($cadd eq 'D')or($revel eq 'D')){
            $or_fp++;
        }elsif(($svm eq '.')and($lr eq '.')and($cadd eq '.')and($revel eq '.')){
            $or_undefined++;
        }else{
	    $or_tn++;
	}
        #ADD
        if(($svm eq 'T')and($lr eq 'T')and($cadd eq 'T')and($revel eq 'T')){
            $add_tn++;
        }elsif(($svm eq 'D')and($lr eq 'D')and($cadd eq 'D')and($revel eq 'D')){
            $add_fp++;
        }else{
            $add_undefined++;
        }
    }else{#TP
        $clinvar_tp++;
        #metasvm
        if($svm eq 'T'){
            $svm_fn++;
        }elsif($svm eq 'D'){
            $svm_tp++;
        }else{
            $svm_undefined++;
        }
        #metaLR
        if($lr eq 'T'){
            $lr_fn++;
        }elsif($lr eq 'D'){
            $lr_tp++;
        }else{
            $lr_undefined++;
        }
        #CADD
        if($cadd eq 'T'){
            $cadd_fn++;
        }elsif($cadd eq 'D'){
            $cadd_tp++;
        }else{
            $cadd_undefined++;
        }
        #REVEL
        if($revel eq 'T'){
            $revel_fn++;
        }elsif($revel eq 'D'){
            $revel_tp++;
        }else{
            $revel_undefined++;
        }
        #OR
        if(($svm eq 'D')or($lr eq 'D')or($cadd eq 'D')or($revel eq 'D')){
            $or_tp++;
        }elsif(($svm eq '.')and($lr eq '.')and($cadd eq '.')and($revel eq '.')){
	    $or_undefined++;
	}
	else{
            $or_fn++;
        }
        #ADD
        if(($svm eq 'T')and($lr eq 'T')and($cadd eq 'T')and($revel eq 'T')){
            $add_fn++;
        }elsif(($svm eq 'D')and($lr eq 'D')and($cadd eq 'D')and($revel eq 'D')){
            $add_tp++;
        }else{
            $add_undefined++;
        }
    }
}
close IN;
my $clinvar_total = $clinvar_tn+$clinvar_tp;

my $svm_sen = $svm_tp/($svm_tp+$svm_fn);
my $svm_spe = $svm_tn/($svm_tn+$svm_fp);
my $svm_total = $svm_tn+$svm_tp+$svm_fn+$svm_fp;
my $svm_acc = ($svm_tp+$svm_tn)/$svm_total;
my $svm_cov = $svm_total/$clinvar_total;
my $svm_mcc = ($svm_tp*$svm_tn-$svm_fp*$svm_fn)/sqrt(($svm_tp+$svm_fp)*($svm_tp+$svm_fn)*($svm_tn+$svm_fp)*($svm_tn+$svm_fn));

my $lr_sen = $lr_tp/($lr_tp+$lr_fn);
my $lr_spe = $lr_tn/($lr_tn+$lr_fp);
my $lr_total = $lr_tn+$lr_tp+$lr_fn+$lr_fp;
my $lr_acc = ($lr_tp+$lr_tn)/$lr_total;
my $lr_cov = $lr_total/$clinvar_total;
my $lr_mcc = ($lr_tp*$lr_tn-$lr_fp*$lr_fn)/sqrt(($lr_tp+$lr_fp)*($lr_tp+$lr_fn)*($lr_tn+$lr_fp)*($lr_tn+$lr_fn));

my $cadd_sen = $cadd_tp/($cadd_tp+$cadd_fn);
my $cadd_spe = $cadd_tn/($cadd_tn+$cadd_fp);
my $cadd_total = $cadd_tn+$cadd_tp+$cadd_fn+$cadd_fp;
my $cadd_acc = ($cadd_tp+$cadd_tn)/$cadd_total;
my $cadd_cov = $cadd_total/$clinvar_total;
my $cadd_mcc = ($cadd_tp*$cadd_tn-$cadd_fp*$cadd_fn)/sqrt(($cadd_tp+$cadd_fp)*($cadd_tp+$cadd_fn)*($cadd_tn+$cadd_fp)*($cadd_tn+$cadd_fn));


my $revel_sen = $revel_tp/($revel_tp+$revel_fn);
my $revel_spe = $revel_tn/($revel_tn+$revel_fp);
my $revel_total = $revel_tn+$revel_tp+$revel_fn+$revel_fp;
my $revel_acc = ($revel_tp+$revel_tn)/$revel_total;
my $revel_cov = $revel_total/$clinvar_total;
my $revel_mcc = ($revel_tp*$revel_tn-$revel_fp*$revel_fn)/sqrt(($revel_tp+$revel_fp)*($revel_tp+$revel_fn)*($revel_tn+$revel_fp)*($revel_tn+$revel_fn));

my $or_sen = $or_tp/($or_tp+$or_fn);
my $or_spe = $or_tn/($or_tn+$or_fp);
my $or_total = $or_tn+$or_tp+$or_fn+$or_fp;
my $or_acc = ($or_tp+$or_tn)/$or_total;
my $or_cov = $or_total/$clinvar_total;
my $or_mcc = ($or_tp*$or_tn-$or_fp*$or_fn)/sqrt(($or_tp+$or_fp)*($or_tp+$or_fn)*($or_tn+$or_fp)*($or_tn+$or_fn));


my $add_sen = $add_tp/($add_tp+$add_fn);
my $add_spe = $add_tn/($add_tn+$add_fp);
my $add_total = $add_tn+$add_tp+$add_fn+$add_fp;
my $add_acc = ($add_tp+$add_tn)/$add_total;
my $add_cov = $add_total/$clinvar_total;
my $add_mcc = ($svm_tp*$svm_tn-$svm_fp*$svm_fn)/sqrt(($svm_tp+$svm_fp)*($svm_tp+$svm_fn)*($svm_tn+$svm_fp)*($svm_tn+$svm_fn));

print STDERR "P:".$clinvar_tp."\n";
print STDERR "N:".$clinvar_tn."\n";
print STDERR "====MetaSVM====\n";
print STDERR "Sen:".$svm_sen."\n";
print STDERR "Spe:".$svm_spe."\n";
print STDERR "Acc:".$svm_acc."\n";
print STDERR "Cov:".$svm_cov."\n";
print STDERR "MCC:".$svm_mcc."\n";

print STDERR "====MetaLR====\n";
print STDERR "Sen:".$lr_sen."\n";
print STDERR "Spe:".$lr_spe."\n";
print STDERR "Acc:".$lr_acc."\n";
print STDERR "Cov:".$lr_cov."\n";
print STDERR "MCC:".$lr_mcc."\n";

print STDERR "====CADD====\n";
print STDERR "Sen:".$cadd_sen."\n";
print STDERR "Spe:".$cadd_spe."\n";
print STDERR "Acc:".$cadd_acc."\n";
print STDERR "Cov:".$cadd_cov."\n";
print STDERR "MCC:".$cadd_mcc."\n";

print STDERR "====REVEL====\n";
print STDERR "Sen:".$revel_sen."\n";
print STDERR "Spe:".$revel_spe."\n";
print STDERR "Acc:".$revel_acc."\n";
print STDERR "Cov:".$revel_cov."\n";
print STDERR "MCC:".$revel_mcc."\n";

print STDERR "====ADD====\n";
print STDERR "Sen:".$add_sen."\n";
print STDERR "Spe:".$add_spe."\n";
print STDERR "Acc:".$add_acc."\n";
print STDERR "Cov:".$add_cov."\n";
print STDERR "MCC:".$add_mcc."\n";


print STDERR "====OR====\n";
print STDERR "Sen:".$or_sen."\n";
print STDERR "Spe:".$or_spe."\n";
print STDERR "Acc:".$or_acc."\n";
print STDERR "Cov:".$or_cov."\n";
print STDERR "MCC:".$or_mcc."\n";
#my @uniq = keys %sig;
#foreach my $i (@uniq){
#    print $i."\n";
#}
